return {
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{ "christoomey/vim-tmux-navigator", event = "VeryLazy" },
	{
		"szw/vim-maximizer",
		cmd = "MaximizerToggle",
		keys = {
			{ "<leader>sm", "<cmd>MaximizerToggle<CR>", desc = "Toggle window maximize" },
		},
	},
	{
		"inkarkat/vim-ReplaceWithRegister",
		dependencies = { "inkarkat/vim-ingo-library" },
		keys = {
			{ "gr", mode = { "n", "x" }, desc = "Replace with register" },
			{ "grr", mode = "n", desc = "Replace line with register" },
		},
	},
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("crates").setup()
		end,
	},
}
