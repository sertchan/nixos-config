local theme = require("lualine.themes.auto")

for _, mode in pairs(theme) do
	if mode.c then
		mode.c.bg = "NONE"
	end
end

local pill = { left = vim.fn.nr2char(0xE0B6), right = vim.fn.nr2char(0xE0B4) }

local function gitsigns_diff()
	local status = vim.b.gitsigns_status_dict

	if status then
		return { added = status.added, modified = status.changed, removed = status.removed }
	end
end

require("lualine").setup({
	options = {
		component_separators = "",
		section_separators = "",
		theme = theme,
	},
	sections = {
		lualine_a = { { "mode", separator = pill } },
		lualine_b = { "branch", { "diff", source = gitsigns_diff }, "diagnostics" },
		lualine_c = {
			{
				"filename",
				path = 1,
				symbols = {
					modified = " ●",
					readonly = " 🔒",
					unnamed = "[No Name]",
					newfile = "[New]",
				},
			},
		},
		lualine_x = { "filetype" },
		lualine_y = { "progress" },
		lualine_z = { { "location", separator = pill } },
	},
})
