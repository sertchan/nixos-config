local severity = vim.diagnostic.severity

local trailing = {
	virtual_lines = false,
	virtual_text = {
		prefix = "●",
		source = "if_many",
	},
}

local expanded = {
	virtual_lines = true,
	virtual_text = false,
}

vim.diagnostic.config(vim.tbl_extend("error", trailing, {
	signs = {
		text = {
			[severity.ERROR] = "󰅚 ",
			[severity.WARN] = "󰀦 ",
			[severity.HINT] = "󰌵 ",
			[severity.INFO] = "󰋼 ",
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		source = true,
		header = "",
		prefix = "",
	},
}))

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "List diagnostics in location list" })

vim.keymap.set("n", "<leader>tv", function()
	vim.diagnostic.config(vim.diagnostic.config().virtual_lines and trailing or expanded)
end, { desc = "Toggle diagnostics between trailing text and full width lines" })
