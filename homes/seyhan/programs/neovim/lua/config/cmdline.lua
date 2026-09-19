local ok, extui = pcall(require, "vim._core.ui2")

if not ok then
	return
end

extui.enable({})

local function explorerColumns()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree" then
			return vim.api.nvim_win_get_width(win) + 1
		end
	end

	return 0
end

local function keepCmdlineOffExplorer()
	local win = extui.wins.cmd

	if not vim.api.nvim_win_is_valid(win) then
		return
	end

	local columns = explorerColumns()

	vim.wo[win].statuscolumn = columns > 0 and "%#MsgArea#" .. (" "):rep(columns) or ""
end

vim.api.nvim_create_autocmd({ "CmdlineEnter", "WinResized" }, {
	group = vim.api.nvim_create_augroup("CmdlineOffExplorer", { clear = true }),
	callback = keepCmdlineOffExplorer,
})
