return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		{ ".luarc.json", ".luarc.jsonc", ".emmyrc.json" },
		{ ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml" },
		{ ".git" },
	},
	settings = {
		Lua = {
			codeLens = { enable = true },
			diagnostics = { globals = { "vim" } },
			hint = { enable = true, semicolon = "Disable" },
			runtime = {
				version = "LuaJIT",
				path = { "lua/?.lua", "lua/?/init.lua" },
			},
			telemetry = { enable = false },
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
}
