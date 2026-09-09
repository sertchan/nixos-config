return {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = {
		{ "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lock" },
		{ "package.json", "tsconfig.json", "jsconfig.json" },
		{ ".git" },
	},
	init_options = { hostInfo = "neovim" },
}
