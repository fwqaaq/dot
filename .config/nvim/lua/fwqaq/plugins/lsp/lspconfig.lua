return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		-- Apply cmp capabilities to every server as the default.
		vim.lsp.config("*", { capabilities = capabilities })

		-- Diagnostic appearance
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

		-- Keymaps and inlay hints — set once per buffer on attach
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
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

		-- ── Per-server overrides ─────────────────────────────────────────────
		-- Only settings that differ from the server's built-in defaults are
		-- listed here.  Capabilities are already set globally above.

		vim.lsp.config("rust_analyzer", {
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

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					workspace = {
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		})

		vim.lsp.config("gopls", {
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

		vim.lsp.config("emmet_ls", {
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

		vim.lsp.config("marksman", {
			filetypes = { "markdown" },
		})

		-- Deno: only attaches when deno.json / deno.jsonc is present
		vim.lsp.config("denols", {
			filetypes = { "javascript", "typescript" },
			single_file_support = true,
			root_dir = function(fname)
				return vim.fs.root(fname, { "deno.json", "deno.jsonc" })
			end,
		})

		-- ts_ls: skip attach when the project is a Deno project
		vim.lsp.config("ts_ls", {
			root_dir = function(fname)
				if vim.fs.root(fname, { "deno.json", "deno.jsonc" }) then
					return nil
				end
				return vim.fs.root(fname, { "package.json", "tsconfig.json", ".git" })
			end,
		})

		-- clangd requires a specific offset encoding to avoid conflicts
		vim.lsp.config("clangd", {
			capabilities = vim.tbl_deep_extend("keep", capabilities, {
				offsetEncoding = { "utf-16" },
			}),
		})

		-- ── Enable servers ───────────────────────────────────────────────────
		vim.lsp.enable({
			"html",
			"cssls",
			"cssmodules_ls",
			"tailwindcss",
			"emmet_ls",
			"ts_ls",
			"denols",
			"vue_ls",
			"jsonls",
			"yamlls",
			"taplo",
			"lua_ls",
			"rust_analyzer",
			"gopls",
			"clangd",
			"buf_ls",
			"marksman",
		})
	end,
}
