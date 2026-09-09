local servers = {
	"bashls",
	"clangd",
	"cssls",
	"html",
	"jsonls",
	"lua_ls",
	"marksman",
	"nil_ls",
	"pyright",
	"rust_analyzer",
	"taplo",
	"ts_ls",
}

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
	callback = function(event)
		local bufnr = event.buf
		local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

		local function map(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
		end

		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gD", vim.lsp.buf.declaration, "Go to declaration")

		if client:supports_method("textDocument/inlayHint") then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
			end, "Toggle inlay hints")
		end

		if client:supports_method("textDocument/documentHighlight") then
			local group = vim.api.nvim_create_augroup("UserLspDocumentHighlight" .. bufnr, { clear = true })

			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				group = group,
				buffer = bufnr,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				group = group,
				buffer = bufnr,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})

vim.lsp.enable(servers)
