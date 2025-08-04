-- Set any vim option
-- vim.opt.option_name = value

-- With a map leader it's possible to do extra key combinations
-- like <leader>w saves the current file
-- Set leader keys (should be done before any mappings that use leader)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- For both (hybrid line numbers)
vim.opt.number = true
vim.opt.relativenumber = true

require("config.lazy")

-- Reverting to old vim colorscheme
-- vim.cmd("colorscheme vim")
-- vim.cmd("colorscheme tokyonight-night")
vim.opt.background = "dark"
vim.g.colors_name = "tokyonight-storm"

-- vim.o.termguicolors = false
-- vim.api.nvim_set_hl(0, "FloatBorder", { link = "WinSeparator" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { link = "Pmenu" })

-- TODO: Fix clipboard over ssh 4gud
-- vim.g.clipboard = {
-- 	name = "ssh clipboard",
-- 	copy = {
-- 		["+"] = { "bash", "copy-over-ssh.sh" },
-- 		["*"] = { "bash", "copy-over-ssh.sh" },
-- 	},
-- 	paste = {
-- 		["+"] = { "xclip", "-select", "clipboard", "-o" },
-- 		["*"] = { "xclip", "-select", "clipboard", "-o" },
-- 	},
-- 	cache_enabled = 1,
-- }

-- copy/paste over ssh using kitty
-- vim.g.clipboard = {
-- 	name = "OSC 52",
-- 	copy = {
-- 		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
-- 		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
-- 	},
-- 	paste = {
-- 		["+"] = require("vim.ui.clipboard.osc52").paste("+"),
-- 		["*"] = require("vim.ui.clipboard.osc52").paste("*"),
-- 	},
-- }

-- Airline configurations
vim.g["airline#extensions#tabline#formatter"] = "unique_tail"
vim.g["airline#extensions#tabline#enabled"] = 1
vim.g["airline#extensions#tabline#show_tab_nr"] = 1
vim.g["airline#extensions#tabline#tab_nr_type"] = 2
vim.g["airline#extensions#tabline#show_tab_type"] = 1

-- MarkdownPreview plugin, set port so we can forward it
-- use a custom port to start server or random for empty
vim.g["mkdp_port"] = "1337"
vim.g["mkdp_echo_preview_url"] = 1

vim.keymap.set("n", "<C-p>", ":Files<CR>", { noremap = true })

-- if i want telescope
-- vim.keymap.set('n', '<C-p>', ':Telescope find_files<CR>', { noremap = true })

-- airline Font Fix
vim.g["airline_powerline_fonts"] = 1

vim.opt.title = true

-- completeopt-=preview: Better to use the full setting in Neovim
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- For indent keys
vim.opt_local.indentkeys:append("0.")

-- Sudo write command
vim.api.nvim_create_user_command("Ws", "w !sudo tee % > /dev/null", {})

-- UI Settings
vim.opt.cmdheight = 2
vim.opt.mouse = "a"
vim.opt.hidden = true
vim.opt.path:append("**")
vim.opt.whichwrap:append("<,>,h,l")
vim.opt.ignorecase = true
vim.opt.magic = true
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.autoread = true
vim.opt.errorbells = false
vim.opt.visualbell = false
-- vim.opt.t_vb = ''
vim.opt.timeoutlen = 500
vim.opt.foldcolumn = "1"

-- Auto reload on focus
vim.api.nvim_create_autocmd("FocusGained", {
	pattern = "*",
	command = "checktime",
})

-- Colors and Fonts
vim.cmd("syntax enable")
-- vim.opt.t_Co = '256'
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.encoding = "utf-8"
vim.opt.fileformats = "unix,dos,mac"

-- Disable backups
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.linebreak = true
vim.opt.textwidth = 500
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = true

-- Visual mode mappings
vim.keymap.set("v", "<silent> *", ':call VisualSelection("f", "")<CR>')
vim.keymap.set("v", "<silent> #", ':call VisualSelection("b", "")<CR>')

-- Movement mappings
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "<F3>", ":Vista!!<CR>")

-- Folding
vim.opt.foldmethod = "syntax"
vim.opt.foldenable = false
vim.opt.foldlevel = 50

-- LSP and formatting mappings
vim.keymap.set("n", "<leader>td", vim.lsp.buf.definition)
vim.keymap.set("n", "<leader>p", function()
	require("conform").format()
end)

-- Highlight colors
vim.cmd([[
hi Pmenu ctermbg=gray guibg=gray ctermfg=black guifg=black
hi PmenuSel ctermbg=darkgray guibg=darkgray ctermfg=black guifg=black
hi link Pmenu PmenuSbar
hi link Pmenu PmenuThumb
]])

-- Various mappings
vim.keymap.set("n", "<leader><cr>", ":noh<cr>", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-W>j")
vim.keymap.set("n", "<C-k>", "<C-W>k")
vim.keymap.set("n", "<C-h>", "<C-W>h")
vim.keymap.set("n", "<C-l>", "<C-W>l")
vim.keymap.set("n", "<leader>ba", ":1,1000 bd!<cr>")
vim.keymap.set("n", "<leader>r", ":source $MYVIMRC<cr>")

-- Tab management
vim.keymap.set("n", "<leader>tn", ":tabnext<cr>")
vim.keymap.set("n", "<leader>tp", ":tabprev<cr>")
vim.keymap.set("n", "<leader>tc", ":tabnew<cr>")

-- Buffer management
vim.keymap.set("n", "<leader>bn", ":bn<cr>")
vim.keymap.set("n", "<leader>bp", ":bp<cr>")
vim.keymap.set("n", "<leader>bd", ":Bclose<cr>")

-- Buffer switching behavior
vim.opt.switchbuf = "useopen,usetab,newtab"
vim.opt.showtabline = 2

-- Return to last edit position
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		local line = vim.fn.line("'\"")
		if line > 0 and line <= vim.fn.line("$") then
			vim.cmd('normal! g`"')
		end
	end,
})

-- Remember info about open buffers
vim.opt.viminfo:append("%")

-- PSQL syntax highlighting
vim.api.nvim_create_autocmd("BufRead", {
	pattern = "/tmp/psql.edit.*",
	command = "set syntax=sql",
})

-- Delete trailing whitespace function
vim.api.nvim_create_autocmd("BufWrite", {
	pattern = "*",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

-- Auto unfold for specific filetypes
vim.api.nvim_create_autocmd("Syntax", {
	pattern = { "c", "cpp", "vim", "xml", "html", "xhtml", "perl", "javascript", "ruby", "json" },
	command = "normal zR",
})

-- Ripgrep integration
if vim.fn.executable("rg") == 1 then
	vim.opt.grepprg = "rg --nogroup --nocolor"
end

-- Quickfix toggle function
_G.quickfix_is_open = 0
function _G.quickfix_toggle()
	if _G.quickfix_is_open == 0 then
		vim.cmd("lopen")
		_G.quickfix_is_open = 1
	else
		vim.cmd("lclose")
		_G.quickfix_is_open = 0
	end
end

vim.keymap.set("n", "<leader>cc", "<cmd>lua quickfix_toggle()<CR>")
vim.keymap.set("n", "<leader>co", "ggVGy:tabnew<cr>:set syntax=qf<cr>pgg")

-- Spell checking
vim.keymap.set("n", "<leader>ss", ":setlocal spell!<cr>")

-- Misc mappings
vim.keymap.set("n", "<Leader>m", "mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm")
vim.keymap.set("n", "<leader>q", ":e ~/buffer<cr>")
vim.keymap.set("n", "<leader>pp", ":setlocal paste!<cr>")

-- Helper functions
-- Note: Some of these might need to be rewritten in Lua for better integration

-- Bclose function
vim.api.nvim_create_user_command("Bclose", function()
	local current_buf = vim.fn.bufnr("%")
	local alternate_buf = vim.fn.bufnr("#")

	if vim.fn.buflisted(alternate_buf) == 1 then
		vim.cmd("buffer #")
	else
		vim.cmd("bnext")
	end

	if vim.fn.bufnr("%") == current_buf then
		vim.cmd("new")
	end

	if vim.fn.buflisted(current_buf) == 1 then
		vim.cmd("bdelete! " .. current_buf)
	end
end, {})

-- Enable local config files
vim.opt.exrc = true
