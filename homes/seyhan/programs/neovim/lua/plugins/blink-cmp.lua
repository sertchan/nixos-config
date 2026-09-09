require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	completion = {
		menu = {
			draw = {
				columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } },
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
		},
		ghost_text = { enabled = true },
	},
	fuzzy = {
		implementation = "rust",
		prebuilt_binaries = { download = false },
	},
	signature = { enabled = true },
})
