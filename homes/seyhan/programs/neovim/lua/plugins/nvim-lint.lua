local lint = require("lint")

local clangtidy = { "clangtidy" }

lint.linters_by_ft = {
	c = clangtidy,
	cpp = clangtidy,
	lua = { "luacheck" },
	markdown = { "markdownlint-cli2" },
	nix = { "statix", "deadnix" },
	python = { "ruff" },
	sh = { "shellcheck" },
	yaml = { "yamllint" },
}

lint.linters.luacheck.args = {
	"--globals",
	"vim",
	"--codes",
	"--ranges",
	"--formatter",
	"plain",
	"-",
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
	callback = function()
		if vim.bo.buftype ~= "" then
			return
		end

		lint.try_lint()
	end,
})
