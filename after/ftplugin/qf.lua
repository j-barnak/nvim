-- <CR> jumps to the entry and closes the quickfix window.
vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { buffer = true, silent = true, desc = "Jump and close quickfix" })
vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
	.. "silent! lua pcall(vim.keymap.del, 'n', '<CR>', { buffer = 0 })"
