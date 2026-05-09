return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()

		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.HINT] = "󰠠",
					[vim.diagnostic.severity.INFO] = "",
				},
			},
			virtual_text = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(args)
				local bufnr = args.buf
				local client = vim.lsp.get_client_by_id(args.data.client_id)

				if client and client:supports_method("textDocument/inlayHint") then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end

				local opts = { noremap = true, silent = true, buffer = bufnr }
				local map = vim.keymap.set

				map("n", "gf", vim.lsp.buf.references, opts)
				map("n", "gD", vim.lsp.buf.declaration, opts)
				map("n", "gd", vim.lsp.buf.definition, opts)
				map("n", "gi", vim.lsp.buf.implementation, opts)
				map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				map("n", "<leader>rn", vim.lsp.buf.rename, opts)
				map("n", "<leader>D", vim.diagnostic.open_float, opts)
				map("n", "<leader>d", vim.diagnostic.open_float, opts)
				map("n", "[d", vim.diagnostic.goto_prev, opts)
				map("n", "]d", vim.diagnostic.goto_next, opts)
				map("n", "K", vim.lsp.buf.hover, opts)
				map("n", "<leader>o", "<cmd>Telescope lsp_document_symbols<CR>", opts)

				if client and client.name == "ts_ls" then
					map("n", "<leader>oi", function()
						vim.lsp.buf.code_action({
							apply = true,
							context = { only = { "source.organizeImports" }, diagnostics = {} },
						})
					end, opts)
					map("n", "<leader>ru", function()
						vim.lsp.buf.code_action({
							apply = true,
							context = { only = { "source.removeUnused" }, diagnostics = {} },
						})
					end, opts)
				end
			end,
		})

		lspconfig.html.setup({ capabilities = capabilities })

		lspconfig.rust_analyzer.setup({
			capabilities = capabilities,
			settings = {
				["rust-analyzer"] = {
					checkOnSave = { command = "clippy" },
					completion = {
						autoself = { enable = true },
						postfix = { enable = true },
					},
					diagnostics = { enable = true },
					inlayHints = {
						lifetimeElisionHints = {
							enable = true,
							useParameterNames = true,
						},
						reborrowHints = { enable = true },
						typeHints = { enable = true },
						closureReturnTypeHints = { enable = "always" },
					},
					highlightRelated = {
						references = { enable = true },
					},
				},
			},
		})

		lspconfig.ts_ls.setup({ capabilities = capabilities })
		lspconfig.cssls.setup({ capabilities = capabilities })
		lspconfig.tailwindcss.setup({ capabilities = capabilities })

		lspconfig.emmet_ls.setup({
			capabilities = capabilities,
			filetypes = {
				"html",
				"typescriptreact",
				"javascriptreact",
				"css",
				"sass",
				"scss",
				"less",
				"svelte",
			},
		})

		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		})

		lspconfig.denols.setup({
			capabilities = capabilities,
			filetypes = { "javascript", "typescript" },
			single_file_support = true,
			root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
		})

		lspconfig.gopls.setup({
			capabilities = capabilities,
			settings = {
				gopls = {
					["ui.inlayhint.hints"] = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						functionTypeParameters = true,
						compositeLiteralTypes = true,
						constantValues = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
				},
			},
		})

		lspconfig.jsonls.setup({ capabilities = capabilities })
		lspconfig.marksman.setup({
			capabilities = capabilities,
			filetypes = { "markdown" },
		})
		lspconfig.volar.setup({ capabilities = capabilities })
		lspconfig.taplo.setup({ capabilities = capabilities })
		lspconfig.yamlls.setup({ capabilities = capabilities })

		lspconfig.clangd.setup({
			capabilities = vim.tbl_deep_extend("keep", capabilities, {
				offsetEncoding = { "utf-16" },
			}),
		})

		lspconfig.buf_ls.setup({ capabilities = capabilities })
	end,
}
