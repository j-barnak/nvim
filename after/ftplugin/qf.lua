-- <CR> jumps to the entry and closes the quickfix window.
vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { buffer = true, silent = true, desc = "Jump and close quickfix" })
-- q closes it. The global q is <Nop> (macro recording is off by design), which
-- otherwise leaves q inert in this window.
vim.keymap.set("n", "q", "<cmd>cclose<cr>", { buffer = true, nowait = true, silent = true, desc = "Close quickfix" })
vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
	.. "silent! lua pcall(vim.keymap.del, 'n', '<CR>', { buffer = 0 }); pcall(vim.keymap.del, 'n', 'q', { buffer = 0 })"
