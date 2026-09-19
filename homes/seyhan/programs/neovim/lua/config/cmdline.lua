local ok, extui = pcall(require, "vim._core.ui2")

if not ok then
	return
end

extui.enable({})

local windows = { "cmd", "dialog", "pager" }

local function explorerColumns()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree" then
			return vim.api.nvim_win_get_width(win) + 1
		end
	end

	return 0
end

local function explorerBlanks()
	local widest = math.floor(vim.o.columns / 2)
	local columns = math.min(explorerColumns(), widest)

	return columns > 0 and "%#NvimTreeNormalNC#" .. (" "):rep(columns) or ""
end

local function place()
	local blanks = explorerBlanks()

	for _, name in ipairs(windows) do
		local win = extui.wins[name]

		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_set_config(win, {
				relative = "laststatus",
				row = 1,
				col = 0,
				width = vim.o.columns,
				_cmdline_offset = 0,
			})

			vim.wo[win].smoothscroll = false
			vim.wo[win].statuscolumn = blanks
		end
	end
end

local group = vim.api.nvim_create_augroup("MessagesOffExplorer", { clear = true })

vim.api.nvim_create_autocmd({ "WinNew", "WinClosed", "WinResized", "VimResized", "CmdlineEnter" }, {
	group = group,
	callback = place,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = windows,
	callback = place,
})
