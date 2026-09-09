local palette = require("palette")

require("kanagawa").setup({
	background = {
		dark = "dragon",
		light = "dragon",
	},
	colors = {
		theme = {
			dragon = {
				ui = {
					bg = palette.base,
					bg_gutter = "none",
				},
			},
		},
	},
})

vim.cmd.colorscheme("kanagawa")
