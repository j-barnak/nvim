vim.keymap.set("n", "q", "<Nop>", { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("n", "<cr>", "ciw")
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

vim.keymap.set({ "n", "o", "x" }, "J", "G", { silent = true, desc = "Jump to end-of-file" })
vim.keymap.set({ "n", "o", "x" }, "K", "gg", { silent = true, desc = "Jump to start-of-file" })
vim.keymap.set("n", "<leader>J", "J", { silent = true, desc = "Join lines (original J)" })
vim.keymap.set("x", "<leader>J", "J", { silent = true, desc = "Join selection (original J)" })
vim.keymap.set("n", "<leader>K", "K", { silent = true, desc = "Keyword help (original K)" })
vim.keymap.set("x", "<leader>K", "K", { silent = true, desc = "Keyword help (original K)" })

vim.keymap.set("n", "<leader>cc", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set({ "n", "x" }, "<leader>c", "gc", { remap = true, desc = "Toggle comment" })

-- Shifted typos of :w / :q. Guarded so the abbreviation only fires when the
-- command line is exactly that word (a plain cnoreabbrev also rewrites
-- `:%s/W/x/` or `:!git commit -m "W"`).
for from, to in pairs({
	W = "w",
	W1 = "w!",
	w1 = "w!",
	Q = "q",
	Q1 = "q!",
	q1 = "q!",
	Qa = "qa",
	Qall = "qall",
	Wa = "wa",
	Wq = "wq",
	wQ = "wq",
	WQ = "wq",
	wq1 = "wq!",
	Wq1 = "wq!",
	wQ1 = "wq!",
	WQ1 = "wq!",
}) do
	vim.keymap.set("ca", from, function()
		return (vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == from) and to or from
	end, { expr = true })
end
