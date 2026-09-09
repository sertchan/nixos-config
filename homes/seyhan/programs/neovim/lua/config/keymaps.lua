local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move visual block down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move visual block up" })

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center cursor" })

map("v", "<", "<gv", { desc = "Indent left and keep selection" })
map("v", ">", ">gv", { desc = "Indent right and keep selection" })

map("n", "[b", "<cmd>bprevious<CR>", { desc = "Go to previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
