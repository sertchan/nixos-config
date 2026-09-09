local parser_filetypes = {
	bash = { "sh" },
	javascript = { "javascriptreact" },
	json = { "jsonc" },
	tsx = { "typescriptreact" },
}

for language, filetypes in pairs(parser_filetypes) do
	vim.treesitter.language.register(language, filetypes)
end
