local fzf = require("fzf-lua")

local map = vim.keymap.set

map("n", "<leader>sf", fzf.files, { desc = "Find a file in the tree" })
map("n", "<leader>sg", fzf.live_grep, { desc = "Grep the tree" })
map("n", "<leader>sb", fzf.buffers, { desc = "Find an open buffer" })
map("n", "<leader>ss", fzf.lsp_document_symbols, { desc = "Find a symbol in this document" })
map("n", "<leader>sS", fzf.lsp_live_workspace_symbols, { desc = "Find a symbol in the workspace" })
map("n", "<leader>sr", fzf.lsp_references, { desc = "Find references to the symbol under the cursor" })
