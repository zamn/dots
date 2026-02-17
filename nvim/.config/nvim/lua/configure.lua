vim.o.termguicolors = false
vim.api.nvim_set_hl(0, "floatborder", { link = "winseparator" })
vim.api.nvim_set_hl(0, "normalfloat", { link = "pmenu" })

vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		["+"] = require("vim.ui.clipboard.osc52").paste("+"),
		["*"] = require("vim.ui.clipboard.osc52").paste("*"),
	},
}

require("typescript-tools").setup({
	settings = {
		-- spawn additional tsserver instance to calculate diagnostics on it
		separate_diagnostic_server = true,
		-- "change"|"insert_leave" determine when the client asks the server about diagnostic
		publish_diagnostic_on = "insert_leave",
		-- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
		-- "remove_unused_imports"|"organize_imports") -- or string "all"
		-- to include all supported code actions
		-- specify commands exposed as code_actions
		expose_as_code_action = {},
		-- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
		-- (see 💅 `styled-components` support section)
		tsserver_plugins = {},
		-- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
		-- memory limit in megabytes or "auto"(basically no limit)
		tsserver_max_memory = 12000,
		-- described below
		tsserver_format_options = {},
		tsserver_file_preferences = {
			-- importmodulespecifierpreference = "relative",
			importModuleSpecifierPreference = "non-relative",
		},
		-- locale of all tsserver messages, supported locales you can find here:
		-- https://github.com/microsoft/typescript/blob/3c221fc086be52b19801f6e8d82596d04607ede6/src/compiler/utilitiespublic.ts#l620
		tsserver_locale = "en",
		-- mirror of vscode's `typescript.suggest.completefunctioncalls`
		complete_function_calls = false,
		include_completions_with_insert_text = true,
		-- codelens
		-- warning: experimental feature also in vscode, because it might hit performance of server.
		-- possible values: ("off"|"all"|"implementations_only"|"references_only")
		code_lens = "off",
		-- by default code lenses are displayed on all referencable values and for some of you it can
		-- be too much this option reduce count of them by removing member references from lenses
		disable_member_code_lens = true,
		-- jsxclosetag
		-- warning: it is disabled by default (maybe you configuration or distro already uses nvim-ts-autotag,
		-- that maybe have a conflict if enable this feature. )
		jsx_close_tag = {
			enable = false,
			filetypes = { "javascriptreact", "typescriptreact" },
		},
	},
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- vim.lsp.enable("bashls")

-- set up nvim-cmp.
local cmp = require("cmp")
local luasnip = require("luasnip")

luasnip.filetype_extend("javascript", { "javascriptreact" })
luasnip.filetype_extend("typescript", { "typescriptreact" })

cmp.setup({
	preselect = cmp.PreselectMode.Item,
	completion = {
		completeopt = "menu,menuone,noinsert",
		autocomplete = {
			cmp.TriggerEvent.TextChanged,
			cmp.TriggerEvent.InsertEnter,
		},
	},
	performance = {
		max_view_entries = 20,
		debounce = 150,
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "nvim_lsp_signature_help" },
		{ name = "path" },
		{ name = "crates" },
		{
			name = "buffer",
			keyword_length = 4,
			max_item_count = 10,
			option = {
				get_bufnrs = function()
					local buf = vim.api.nvim_get_current_buf()
					local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
					if byte_size > 1024 * 1024 then
						return {}
					end
					return { buf }
				end,
				indexing_interval = 1000,
			},
		},
	}),
	mapping = cmp.mapping.preset.insert({
		["<tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<s-tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
		["<cr>"] = cmp.mapping.confirm({ select = true }),
	}),
	experimental = {
		ghost_text = true,
	},
})

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		graphql = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = false },
		json = { "prettierd", "prettier", stop_after_first = false },
		-- javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		-- typescriptreact = { "prettierd", "prettier", stop_after_first = true },
	},
	log_level = vim.log.levels.debug,
})

local conform_ns = vim.api.nvim_create_namespace("conform_errors")

vim.api.nvim_create_user_command("Format", function(args)
	local bufnr = vim.api.nvim_get_current_buf()

	-- 1. Handle Range Logic (for Visual Mode)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(bufnr, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line and end_line:len() or 0 },
		}
	end

	-- 2. Clear previous formatting diagnostics
	vim.diagnostic.set(conform_ns, bufnr, {})

	-- 3. Execute Format
	require("conform").format({
		bufnr = bufnr,
		range = range,
		async = false, -- Required to catch errors and display them immediately
		lsp_format = "fallback",
		timeout_ms = 1000,
	}, function(err)
		if err then
			-- 4. Set diagnostic on line 1
			vim.diagnostic.set(conform_ns, bufnr, {
				{
					lnum = 0,
					col = 0,
					severity = vim.diagnostic.severity.ERROR,
					source = "conform.nvim",
					message = "Formatting failed: " .. tostring(err),
				},
			})
			-- 5. Open float for the whole buffer so it's visible regardless of cursor
			vim.diagnostic.open_float({
				scope = "buffer",
				namespace = conform_ns,
				focus = false,
			})
		else
			vim.notify("Formatting successful", vim.log.levels.INFO)
		end
	end)
end, {
	range = true,
	desc = "Format selection or buffer with error highlighting",
})

-- vim.keymap.set({ "n", "v" }, "<leader>p", "<cmd>Format<cr>", { desc = "Run Format command" })

-- Use a slightly different approach to ensure ranges are captured correctly
vim.keymap.set({ "n", "v" }, "<leader>p", function()
	-- If in visual mode, we must escape to save the selection to marks
	local mode = vim.api.nvim_get_mode().mode
	if mode:match("[vV]") then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
		-- This executes the command with the visual range marks automatically
		vim.cmd("'<,'>Format")
	else
		vim.cmd("Format")
	end
end, { desc = "Format buffer or selection" })

-- require("conform").formatters["eslint_d"] = {
--   append_args = {"--fix"}
-- }

require("trouble").setup({
	auto_close = false, -- auto close when there are no items
	auto_open = false, -- auto open when there are items
	auto_preview = true, -- automatically open preview when on an item
	auto_refresh = true, -- auto refresh when open
	auto_jump = false, -- auto jump to the item when there's only one
	focus = false, -- focus the window when opened
	restore = true, -- restores the last location in the list when opening
	follow = true, -- follow the current item
	indent_guides = true, -- show indent guides
	max_items = 200, -- limit number of items that can be displayed per section
	multiline = true, -- render multi-line messages
	pinned = true, -- when pinned, the opened trouble window will be bound to the current buffer
	warn_no_results = true, -- show a warning when there are no results
	open_no_results = false, -- open the trouble window when there are no results
	---@type trouble.window.opts
	-- win = {}, -- window options for the results window. can be a split or a floating window.
	win = { minimal = false },
	-- window options for the preview window. can be a split, floating window,
	-- or `main` to show the preview in the main editor window.
	---@type trouble.window.opts
	preview = {
		type = "main",
		-- when a buffer is not yet loaded, the preview window will be created
		-- in a scratch buffer with only syntax highlighting enabled.
		-- set to false, if you want the preview to always be a real loaded buffer.
		scratch = true,
	},
	-- throttle/debounce settings. should usually not be changed.
	---@type table<string, number|{ms:number, debounce?:boolean}>
	throttle = {
		refresh = 20, -- fetches new data when needed
		update = 10, -- updates the window
		render = 10, -- renders the window
		follow = 100, -- follows the current item
		preview = { ms = 100, debounce = true }, -- shows the preview for the current item
	},
	-- key mappings can be set to the name of a builtin action,
	-- or you can define your own custom action.
	---@type table<string, trouble.action.spec|false>
	keys = {
		["?"] = "help",
		r = "refresh",
		r = "toggle_refresh",
		q = "close",
		o = "jump_close",
		["<esc>"] = "cancel",
		["<cr>"] = "jump",
		["<2-leftmouse>"] = "jump",
		["<c-s>"] = "jump_split",
		["<c-v>"] = "jump_vsplit",
		-- go down to next item (accepts count)
		-- j = "next",
		["}"] = "next",
		["]]"] = "next",
		-- go up to prev item (accepts count)
		-- k = "prev",
		["{"] = "prev",
		["[["] = "prev",
		dd = "delete",
		d = { action = "delete", mode = "v" },
		i = "inspect",
		p = "preview",
		p = "toggle_preview",
		zo = "fold_open",
		zo = "fold_open_recursive",
		zc = "fold_close",
		zc = "fold_close_recursive",
		za = "fold_toggle",
		za = "fold_toggle_recursive",
		zm = "fold_more",
		zm = "fold_close_all",
		zr = "fold_reduce",
		zr = "fold_open_all",
		zx = "fold_update",
		zx = "fold_update_all",
		zn = "fold_disable",
		zn = "fold_enable",
		zi = "fold_toggle_enable",
		gb = { -- example of a custom action that toggles the active view filter
			action = function(view)
				view:filter({ buf = 0 }, { toggle = true })
			end,
			desc = "toggle current buffer filter",
		},
		s = { -- example of a custom action that toggles the severity
			action = function(view)
				local f = view:get_filter("severity")
				local severity = ((f and f.filter.severity or 0) + 1) % 5
				view:filter({ severity = severity }, {
					id = "severity",
					template = "{hl:title}filter:{hl} {severity}",
					del = severity == 0,
				})
			end,
			desc = "toggle severity filter",
		},
	},
	---@type table<string, trouble.mode>
	modes = {
		-- sources define their own modes, which you can use directly,
		-- or override like in the example below
		lsp_references = {
			-- some modes are configurable, see the source code for more details
			params = {
				include_declaration = true,
			},
		},
		-- the lsp base mode for:
		-- * lsp_definitions, lsp_references, lsp_implementations
		-- * lsp_type_definitions, lsp_declarations, lsp_command
		lsp_base = {
			params = {
				-- don't include the current location in the results
				include_current = false,
			},
		},
		-- more advanced example that extends the lsp_document_symbols
		symbols = {
			desc = "document symbols",
			mode = "lsp_document_symbols",
			focus = false,
			win = { position = "right" },
			filter = {
				-- remove package since luals uses it for control flow structures
				["not"] = { ft = "lua", kind = "package" },
				any = {
					-- all symbol kinds for help / markdown files
					ft = { "help", "markdown" },
					-- default set of symbol kinds
					kind = {
						"class",
						"constructor",
						"enum",
						"field",
						"function",
						"interface",
						"method",
						"module",
						"namespace",
						"package",
						"property",
						"struct",
						"trait",
					},
				},
			},
		},
	},
    -- stylua: ignore
    icons = {
      ---@type trouble.indent.symbols
      indent = {
        top           = "│ ",
        middle        = "├╴",
        last          = "└╴",
        -- last          = "-╴",
        -- last       = "╰╴", -- rounded
        fold_open     = " ",
        fold_closed   = " ",
        ws            = "  ",
      },
      folder_closed   = " ",
      folder_open     = " ",
      kinds = {
        array         = " ",
        boolean       = "󰨙 ",
        class         = " ",
        constant      = "󰏿 ",
        constructor   = " ",
        enum          = " ",
        enummember    = " ",
        event         = " ",
        field         = " ",
        file          = " ",
        ["function"]  = "󰊕 ",
        interface     = " ",
        key           = " ",
        method        = "󰊕 ",
        module        = " ",
        namespace     = "󰦮 ",
        null          = " ",
        number        = "󰎠 ",
        object        = " ",
        operator      = " ",
        package       = " ",
        property      = " ",
        string        = " ",
        struct        = "󰆼 ",
        typeparameter = " ",
        variable      = "󰀫 ",
      },
    }
,
})

vim.o.updatetime = 300 -- Faster popup response
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, {
			scope = "cursor", -- Key change: 'cursor' instead of 'line'
			focusable = false, -- Prevents focusing the window automatically
			close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre" },
		})
	end,
})

-- local conform_ns = vim.api.nvim_create_namespace("conform_errors")

-- Auto import + format
-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
-- 	callback = function(args)
-- 		-- 1. Sync Auto-Import (for typescript-tools)
-- 		-- local api = require("typescript-tools.api")
-- 		-- if api then
-- 		-- 	api.add_missing_imports(true) -- 'true' makes it synchronous
-- 		-- end
--
-- 		-- 2. Sync Formatting (via conform.nvim)
-- 		-- This replaces your manual :Format command for auto-save
-- 		require("conform").format({
-- 			bufnr = args.buf,
-- 			async = false, -- IMPORTANT: Must be false for BufWritePre
-- 			timeout_ms = 500, -- Adjust if your formatter is slow
-- 			lsp_format = "fallback",
-- 		})
-- 	end,
-- })

require("fzf-lua").setup({
	{ "default-prompt" },
	winopts = {
		preview = { border = "none" },
		border = "none",
		backdrop = 100,
	},
	fzf_opts = {
		["--layout"] = false,
		["--info"] = false,
	},

	files = {
		multiprocess = true, -- run command in a separate process
		git_icons = true, -- show git icons?
		file_icons = "mini", -- show file icons (true|"devicons"|"mini")?
		color_icons = true, -- colorize file|git icons
		-- Uncomment for custom vscode-like formatter where the filename is first:
		-- e.g. "fzf-lua/previewer/fzf.lua" => "fzf.lua previewer/fzf-lua"
		-- formatter      = "path.filename_first",
		-- executed command priority is 'cmd' (if exists)
		-- otherwise auto-detect prioritizes `fd`:`rg`:`find`
		-- default options are controlled by 'fd|rg|find|_opts'
		-- find_opts = [[git ls-files --cached --others --exclude-standard || fd --type f --type l --hidden follow]],
		-- hidden = true,
		-- follow = true,
		no_ignore = false, -- respect ".gitignore"  by default
		rg_opts = [[--files --follow --hidden]],
	},
})

require("fzf-lua").setup_fzfvim_cmds()

vim.keymap.set({ "n", "v" }, "<c-p>", function()
	require("fzf-lua").files({})
end, { desc = "find files" })

function _G.has_plug(name)
	return vim.g.plugs and vim.g.plugs[name] ~= nil
end

if _G.has_plug("indent-blankline.nvim") then
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			require("ibl").setup()
		end,
	})
end

require("ibl").setup()

vim.keymap.set("n", "<leader>k", function()
	local word = vim.fn.expand("<cword>")
	vim.cmd("Rg " .. word)
end, { desc = "Search current word with Rg" })

vim.keymap.set("v", "<leader>k", function()
	-- Get visually selected text
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local lines = vim.fn.getline(start_pos[2], end_pos[2])

	if #lines == 1 then
		local selected_text = string.sub(lines[1], start_pos[3], end_pos[3])
		vim.cmd("Rg " .. vim.fn.shellescape(selected_text))
	end
end, { desc = "Search selected text with Rg" })

vim.api.nvim_create_user_command("ReloadConfig", function()
	package.loaded["configure"] = nil
	require("configure")
	print("Config reloaded!")
end, {})

vim.api.nvim_create_user_command("SpellCheck", function()
	local qf_list = {}
	local bufnr = vim.api.nvim_get_current_buf()

	-- Save cursor position
	local save_pos = vim.api.nvim_win_get_cursor(0)

	-- Go through each line
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for lnum, line in ipairs(lines) do
		-- Check each word in the line
		for word in line:gmatch("%w+") do
			local spell_info = vim.fn.spellbadword(word)
			if spell_info[2] ~= "" then
				local suggestions = vim.fn.spellsuggest(word, 3)
				table.insert(qf_list, {
					bufnr = bufnr,
					lnum = lnum,
					col = line:find(word) or 1,
					text = string.format("%s -> %s", word, table.concat(suggestions, ", ")),
				})
			end
		end
	end

	-- Restore cursor position
	vim.api.nvim_win_set_cursor(0, save_pos)

	vim.fn.setqflist(qf_list)
	vim.cmd("copen")
end, {})
