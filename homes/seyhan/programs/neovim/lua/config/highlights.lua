local palette = require("palette")

local surface = { bg = palette.explorerCard }
local hidden = { fg = palette.explorerCard, bg = palette.explorerCard }
local hairline = { fg = palette.hairline }
local edge = { fg = palette.hairline, bg = palette.base }
local floating = { bg = palette.base }

local overrides = {
	FloatBorder = edge,
	FloatTitle = floating,
	IblIndent = hairline,
	IblWhitespace = hairline,
	MsgArea = surface,
	MsgSeparator = surface,
	NormalFloat = floating,
	NvimTreeCursorLine = { bg = palette.hairline },
	NvimTreeEndOfBuffer = hidden,
	NvimTreeIndentMarker = hairline,
	NvimTreeNormal = surface,
	NvimTreeNormalNC = surface,
	NvimTreeStatusLine = hidden,
	NvimTreeStatuslineNC = hidden,
	NvimTreeWinSeparator = hidden,
	WinSeparator = edge,
}

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("PaletteHighlights", { clear = true }),
	callback = function()
		for name, override in pairs(overrides) do
			local current = vim.api.nvim_get_hl(0, { name = name, link = false })
			vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", current, override))
		end
	end,
})
