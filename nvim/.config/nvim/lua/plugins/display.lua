return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 2000,
		opts = { style = "night" },
		config = function()
			vim.cmd.colorscheme("tokyonight")
			vim.cmd("colorscheme tokyonight")
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {
			scope = { enabled = false },
		},
	},
	{
		"s1n7ax/nvim-window-picker",
		name = "window-picker",
		event = "VeryLazy",
		version = "2.*",
		config = function()
			require("window-picker").setup()
		end,
	},
}
