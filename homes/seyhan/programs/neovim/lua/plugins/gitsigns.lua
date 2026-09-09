local gitsigns = require("gitsigns")

gitsigns.setup({
	on_attach = function(bufnr)
		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end

		local function selected_range()
			return { vim.fn.line("."), vim.fn.line("v") }
		end

		map("n", "]h", function()
			gitsigns.nav_hunk("next")
		end, "Go to the next hunk")

		map("n", "[h", function()
			gitsigns.nav_hunk("prev")
		end, "Go to the previous hunk")

		map("n", "<leader>gs", gitsigns.stage_hunk, "Stage the hunk under the cursor")
		map("n", "<leader>gr", gitsigns.reset_hunk, "Reset the hunk under the cursor")

		map("v", "<leader>gs", function()
			gitsigns.stage_hunk(selected_range())
		end, "Stage the selected lines")

		map("v", "<leader>gr", function()
			gitsigns.reset_hunk(selected_range())
		end, "Reset the selected lines")

		map("n", "<leader>gp", gitsigns.preview_hunk, "Preview the hunk under the cursor")
		map("n", "<leader>gb", gitsigns.blame_line, "Blame the current line")
		map("n", "<leader>gB", gitsigns.toggle_current_line_blame, "Toggle the inline blame")
	end,
})
