local api = require("nvim-tree.api")

local indent_marker = "│"

local function toggle_focus()
	if vim.bo.filetype == "NvimTree" then
		vim.cmd("wincmd p")
	else
		api.tree.find_file({ open = true, focus = true })
	end
end

require("nvim-tree").setup({
	disable_netrw = true,
	hijack_directories = { enable = false },
	on_attach = function(bufnr)
		api.config.mappings.default_on_attach(bufnr)

		vim.keymap.set("n", "<C-e>", toggle_focus, { buffer = bufnr, desc = "Focus the editor window" })
		vim.keymap.set("n", "<leader>E", toggle_focus, { buffer = bufnr, desc = "Focus the editor window" })
	end,
	view = {
		width = 35,
		side = "left",
	},
	renderer = {
		highlight_git = "none",
		highlight_opened_files = "none",
		highlight_modified = "none",
		highlight_diagnostics = "none",
		highlight_clipboard = "none",
		indent_markers = {
			enable = true,
			inline_arrows = true,
			icons = {
				corner = "└",
				edge = indent_marker,
				item = indent_marker,
				bottom = "─",
				none = " ",
			},
		},
	},
	actions = {
		open_file = {
			window_picker = { enable = false },
		},
	},
	filters = { dotfiles = false },
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("NvimTreeAutoOpen", { clear = true }),
	callback = function(data)
		if vim.o.diff then
			return
		end

		if vim.fn.isdirectory(data.file) == 1 then
			vim.cmd.enew()
			vim.cmd.bwipeout(data.buf)
			vim.api.nvim_set_current_dir(data.file)
			api.tree.open()
		else
			api.tree.toggle({ focus = false, find_file = true })
		end
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("NvimTreeAutoClose", { clear = true }),
	nested = true,
	callback = function()
		if vim.bo.filetype ~= "NvimTree" then
			return
		end

		local tiled = vim.tbl_filter(function(win)
			return vim.api.nvim_win_get_config(win).relative == ""
		end, vim.api.nvim_tabpage_list_wins(0))

		if #tiled > 1 then
			return
		end

		if #vim.api.nvim_list_tabpages() > 1 then
			vim.cmd("tabclose")
		else
			vim.cmd("quit")
		end
	end,
})

vim.keymap.set("n", "<C-e>", toggle_focus, { desc = "Focus the file explorer" })
vim.keymap.set("n", "<leader>E", toggle_focus, { desc = "Focus the file explorer" })
vim.keymap.set("n", "<C-n>", api.tree.toggle, { desc = "Toggle the file explorer" })
