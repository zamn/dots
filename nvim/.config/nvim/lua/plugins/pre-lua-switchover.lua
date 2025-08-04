return {
	{ "nvim-treesitter/nvim-treesitter" },
	-- If you want neo-tree's file operations to work with LSP (updating imports, etc.), you can use a plugin like
	-- https://github.com/antosha417/nvim-lsp-file-operations:
	-- {
	--   "antosha417/nvim-lsp-file-operations",
	--   dependencies = {
	--     "nvim-lua/plenary.nvim",
	--     "nvim-neo-tree/neo-tree.nvim",
	--   },
	--   config = function()
	--     require("lsp-file-operations").setup()
	--   end,
	-- },
	{ "junegunn/vim-easy-align" },
	{ "junegunn/fzf" },
	{ "junegunn/fzf.vim" },
	{ "liuchengxu/eleline.vim" },
	{ "fatih/vim-go" },
	{ "lervag/vimtex" },
	{
		"iamcco/markdown-preview.nvim",
		ft = "norg",
		-- TODO: Figure out install?
		-- opts = { 'do': ':call mkdp#util#install()', 'for': 'markdown' }
	},
	{ "tpope/vim-surround" },
	{ "tpope/vim-repeat" },
	{ "pangloss/vim-javascript" },
	{ "leafgarland/typescript-vim" },
	{ "othree/yajs.vim" },
	{ "jparise/vim-graphql" },
	{ "moll/vim-node" },
	{ "prisma/vim-prisma" },
	{ "HerringtonDarkholme/yats.vim" },
	{ "liuchengxu/vista.vim" },
	{ "raimondi/delimitmate" },
	{ "tpope/vim-commentary" },
	{ "romainl/vim-qf" },
	{ "mbbill/undotree" },
	{ "hashivim/vim-terraform" },
	-- TODO replace w/ lualine
	{ "bling/vim-airline" },
}
