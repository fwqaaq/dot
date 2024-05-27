-- import null-ls plugin safely
local setup, null_ls = pcall(require, "null-ls")
if not setup then
	return
end

local rustfmt = {
	name = "rustfmt",
	method = null_ls.methods.FORMATTING,
	filetypes = { "rust" },
	generator = {
		fn = function(params)
			local cmd = params.command or "rustfmt"
			local args = params.args or { "--emit=stdout" }
			return {
				exe = cmd,
				args = args,
				stdin = true,
			}
		end,
	},
}

-- for conciseness
local formatting = null_ls.builtins.formatting -- to setup formatters
local diagnostics = null_ls.builtins.diagnostics -- to setup linters

-- 8 spaces for golang
local function setup_go_ident()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "go",
		command = "setlocal shiftwidth=8 tabstop=8 noexpandtab",
	})
end
setup_go_ident()

-- to setup format on save
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- configure null_ls
null_ls.setup({
	offset_encoding = "utf-8",
	-- setup formatters & linters
	sources = {
		formatting.prettier, -- js/ts formatter
		formatting.stylua, -- lua formatter
		formatting.clang_format, -- clang formatter
		rustfmt,
		formatting.gofmt, -- golang formatter
	},
	-- configure format on save
	on_attach = function(current_client, bufnr)
		if current_client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({
						filter = function(client)
							--  only use null-ls for formatting instead of lsp server
							return client.name == "null-ls"
						end,
						bufnr = bufnr,
					})
				end,
			})
		end
	end,
})
