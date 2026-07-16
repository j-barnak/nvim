vim.keymap.set("n", "q", "<Nop>", { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("n", "<cr>", "ciw")
vim.keymap.set("i", "<C-w>", "<Esc>cvb", {})
vim.keymap.set("i", "jj", "<Esc>", { silent = true })
vim.keymap.set({ "n", "o", "x" }, "H", "^", {})
vim.keymap.set({ "n", "o", "x" }, "L", "$", {})
vim.keymap.set("n", "U", "<C-r>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>Q", "<cmd>qall!<cr>")
vim.keymap.set("n", "<leader>-", "<cmd>split<cr>")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<leader><BS>", "<C-o>")

vim.keymap.set({ "n", "o", "x" }, "J", "G", { noremap = true, silent = true, desc = "Jump to end‑of‑file" })
vim.keymap.set({ "n", "o", "x" }, "K", "gg", { noremap = true, silent = true, desc = "Jump to start‑of‑file" })
vim.keymap.set("n", "<leader>J", "J", { noremap = true, silent = true, desc = "Join lines (original J)" })
vim.keymap.set("x", "<leader>J", "J", { noremap = true, silent = true, desc = "Join selection (original J)" })
vim.keymap.set("n", "<leader>K", "K", { noremap = true, silent = true, desc = "Keyword help (original K)" })
vim.keymap.set("x", "<leader>K", "K", { noremap = true, silent = true, desc = "Keyword help (original K)" })

vim.keymap.set("n", "<leader>cc", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set({ "n", "x" }, "<leader>c", "gc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("n", "<leader>bc", "gbc", { remap = true, desc = "Toggle comment block" })
vim.keymap.set({ "n", "x" }, "<leader>b", "gb", { remap = true, desc = "Toggle comment block" })

vim.cmd([[
cnoreabbrev W! w!
cnoreabbrev W1 w!
cnoreabbrev w1 w!
cnoreabbrev Q! q!
cnoreabbrev Q1 q!
cnoreabbrev q1 q!
cnoreabbrev Qa! qa!
cnoreabbrev Qall! qall!
cnoreabbrev Wa wa
cnoreabbrev Wq wq
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev wq1 wq!
cnoreabbrev Wq1 wq!
cnoreabbrev wQ1 wq!
cnoreabbrev WQ1 wq!
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qa qa
cnoreabbrev Qall qall
]])

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qf" },
	command = [[nnoremap <buffer> <CR> <CR>:cclose<CR>]],
})
