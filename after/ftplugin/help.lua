-- q closes the help window. The global q is <Nop> (macro recording is off by
-- design), which left q inert here; man and the docs viewer already do this.
vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, nowait = true, silent = true, desc = "Close help" })
vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
	.. "silent! execute 'nunmap <buffer> q'"
