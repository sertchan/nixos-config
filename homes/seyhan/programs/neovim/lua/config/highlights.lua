local palette = require("palette")

local overrides = {
	FloatBorder = { fg = palette.hairline, bg = palette.base },
	FloatTitle = { bg = palette.base },
	IblIndent = { fg = palette.hairline },
	IblWhitespace = { fg = palette.hairline },
	NormalFloat = { bg = palette.base },
	NvimTreeCursorLine = { bg = palette.hairline },
	NvimTreeEndOfBuffer = { fg = palette.explorerCard, bg = palette.explorerCard },
	NvimTreeIndentMarker = { fg = palette.hairline },
	NvimTreeNormal = { bg = palette.explorerCard },
	NvimTreeNormalNC = { bg = palette.explorerCard },
	NvimTreeWinSeparator = { fg = palette.hairline, bg = palette.explorerCard },
	WinSeparator = { fg = palette.hairline, bg = palette.base },
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
