return {
	cmd = { "clangd" },
	filetypes = { "c", "cpp" },
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		".git",
	},
	capabilities = {
		offsetEncoding = { "utf-8", "utf-16" },
		textDocument = {
			completion = { editsNearCursor = true },
		},
	},
	on_init = function(client, init_result)
		if init_result.offsetEncoding then
			client.offset_encoding = init_result.offsetEncoding
		end
	end,
}
