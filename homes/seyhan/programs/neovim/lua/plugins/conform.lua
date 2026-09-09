local conform = require("conform")

local beautysh = { "beautysh" }
local clang_format = { "clang-format" }
local prettierd = { "prettierd" }

conform.setup({
	formatters_by_ft = {
		c = clang_format,
		cpp = clang_format,
		css = prettierd,
		html = prettierd,
		javascript = prettierd,
		javascriptreact = prettierd,
		json = { "fixjson" },
		jsonc = prettierd,
		kdl = { "kdlfmt" },
		less = prettierd,
		lua = { "stylua" },
		markdown = prettierd,
		nix = { "alejandra" },
		python = { "ruff_organize_imports", "ruff_format" },
		rust = { "rustfmt" },
		scss = prettierd,
		sh = beautysh,
		toml = { "taplo" },
		typescript = prettierd,
		typescriptreact = prettierd,
		yaml = { "yamlfix" },
		zsh = beautysh,
	},
	formatters = {
		kdlfmt = {
			args = { "format", "--kdl-version", "v1", "-" },
		},
	},
	format_on_save = {
		timeout_ms = 1000,
		lsp_format = "fallback",
	},
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
	conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format the current buffer" })
