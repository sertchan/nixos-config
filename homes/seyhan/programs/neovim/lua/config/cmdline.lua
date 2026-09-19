local ok, extui = pcall(require, "vim._core.ui2")

if not ok then
	return
end

extui.enable({})

local overlayWindows = { "cmd", "dialog" }

local function explorerColumns()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree" then
			return vim.api.nvim_win_get_width(win) + 1
		end
	end

	return 0
end

local function place(col, width, statuscolumn)
	for _, name in ipairs(overlayWindows) do
		local win = extui.wins[name]

		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_set_config(win, {
				relative = "laststatus",
				row = 1,
				col = col,
				width = width,
				_cmdline_offset = 0,
			})

			vim.wo[win].statuscolumn = statuscolumn
		end
	end
end

local function spanScreenBelowExplorer()
	local columns = explorerColumns()

	place(0, vim.o.columns, columns > 0 and "%#MsgArea#" .. (" "):rep(columns) or "")
end

local function spanFileWindow()
	local columns = explorerColumns()

	place(columns, vim.o.columns - columns, "")
end

local function placeForCurrentMode()
	if vim.fn.getcmdtype() == "" then
		spanFileWindow()
	else
		spanScreenBelowExplorer()
	end
end

local group = vim.api.nvim_create_augroup("MessagesOffExplorer", { clear = true })

vim.api.nvim_create_autocmd("CmdlineEnter", {
	group = group,
	callback = spanScreenBelowExplorer,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
	group = group,
	callback = spanFileWindow,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = overlayWindows,
	callback = placeForCurrentMode,
})

vim.api.nvim_create_autocmd("WinResized", {
	group = group,
	callback = placeForCurrentMode,
})
