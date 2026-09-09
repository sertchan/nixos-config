local group = vim.api.nvim_create_augroup("RestoreCursor", { clear = true })

local rewritten_filetypes = { "gitcommit", "gitrebase", "xxd" }

local function restore(event)
	if vim.wo.diff or vim.tbl_contains(rewritten_filetypes, vim.bo[event.buf].filetype) then
		return
	end

	local row, col = unpack(vim.api.nvim_buf_get_mark(event.buf, '"'))
	if row >= 1 and row <= vim.api.nvim_buf_line_count(event.buf) then
		pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
	end
end

vim.api.nvim_create_autocmd("BufReadPre", {
	group = group,
	callback = function(event)
		vim.api.nvim_create_autocmd("BufWinEnter", {
			group = group,
			buffer = event.buf,
			once = true,
			callback = restore,
		})
	end,
})
