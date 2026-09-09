local opt = vim.opt

opt.number = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.cursorlineopt = "number"
opt.termguicolors = true
opt.scrolloff = 8
opt.showmode = false
opt.pumheight = 10

opt.winborder = "rounded"
opt.laststatus = 3
opt.fillchars = {
	eob = " ",
	horiz = "─",
	horizdown = "┬",
	horizup = "┴",
	vert = "│",
	verthoriz = "┼",
	vertleft = "┤",
	vertright = "├",
}

opt.ignorecase = true
opt.smartcase = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

opt.splitright = true
opt.splitbelow = true

opt.undofile = true
opt.clipboard:append("unnamedplus")
opt.updatetime = 250
opt.timeoutlen = 300
