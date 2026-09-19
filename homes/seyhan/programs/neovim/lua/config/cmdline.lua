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

local function blanks(columns)
	local widest = math.floor(vim.o.columns / 2)

	return columns > 0 and "%#MsgArea#" .. (" "):rep(math.min(columns, widest)) or ""
end

local function place(event)
	local columns = explorerColumns()
	local typing = event.event ~= "CmdlineLeave" and vim.fn.getcmdtype() ~= ""

	for name, besideExplorer in pairs({ cmd = not typing, dialog = not typing, pager = false }) do
		local win = extui.wins[name]

		if vim.api.nvim_win_is_valid(win) then
			local col = besideExplorer and columns or 0

			vim.api.nvim_win_set_config(win, {
				relative = "laststatus",
				row = 1,
				col = col,
				width = vim.o.columns - col,
				_cmdline_offset = 0,
			})

			vim.wo[win].smoothscroll = false
			vim.wo[win].statuscolumn = besideExplorer and "" or blanks(columns)
		end
	end
end

local group = vim.api.nvim_create_augroup("MessagesOffExplorer", { clear = true })

vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave", "WinResized" }, {
	group = group,
	callback = place,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "cmd", "dialog", "pager" },
	callback = place,
})
