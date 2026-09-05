vim.keymap.set({ "n", "o", "x" }, "j", "gj", { buffer = true })
vim.keymap.set({ "n", "o", "x" }, "k", "gk", { buffer = true })
vim.keymap.set({ "n", "o", "x" }, "H", "g0", { buffer = true })
vim.keymap.set({ "n", "o", "x" }, "L", "g$", { buffer = true })
vim.opt_local.wrap = true

-- Undo everything above when the filetype changes (:help undo_ftplugin);
-- without this the display-line motions stayed mapped on the buffer.
vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
	.. "setlocal wrap< | silent! execute 'unmap <buffer> j' | silent! execute 'unmap <buffer> k'"
	.. " | silent! execute 'unmap <buffer> H' | silent! execute 'unmap <buffer> L'"
