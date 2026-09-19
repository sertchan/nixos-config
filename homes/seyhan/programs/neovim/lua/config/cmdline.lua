local ok, extui = pcall(require, "vim._core.ui2")

if not ok then
	return
end

extui.enable({})

local fullWidthWindows = { "cmd", "dialog", "pager" }

local function explorerColumns()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree" then
			return vim.api.nvim_win_get_width(win) + 1
		end
	end

	return 0
end

local function keepMessagesOffExplorer()
	local columns = explorerColumns()
	local statuscolumn = columns > 0 and "%#MsgArea#" .. (" "):rep(columns) or ""

	for _, name in ipairs(fullWidthWindows) do
		local win = extui.wins[name]

		if vim.api.nvim_win_is_valid(win) then
			vim.wo[win].statuscolumn = statuscolumn
			vim.wo[win].smoothscroll = false
		end
	end
end

vim.api.nvim_create_autocmd({ "CmdlineEnter", "WinResized" }, {
	group = vim.api.nvim_create_augroup("MessagesOffExplorer", { clear = true }),
	callback = keepMessagesOffExplorer,
})
