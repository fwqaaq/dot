return {
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"cssls",
					"cssmodules_ls",
					"denols",
					"emmet_ls",
					"gopls",
					"html",
					"jsonls",
					"lua_ls",
					"marksman",
					"rust_analyzer",
					"tailwindcss",
					"taplo",
					"ts_ls",
					"volar",
					"yamlls",
					"buf_ls",
				},
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"prettier",
					"stylua",
					"eslint_d",
					"clang-format",
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},
}
