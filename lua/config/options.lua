vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.backup = false
vim.opt.fileencoding = "utf-8"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.timeoutlen = 1000
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.updatetime = 50
vim.opt.writebackup = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.signcolumn = "yes:1"
vim.opt.cursorline = true
vim.opt.exrc = true
vim.opt.secure = true
vim.opt.confirm = true
vim.g.editorconfig = false

if vim.g.neovide == true then
	vim.g.neovide_hide_mouse_when_typing = true
	vim.o.guifont = "Hack Nerd Font:h17"
	vim.api.nvim_set_keymap("n", "<leader><leader>;", ":let g:neovide_fullscreen = !g:neovide_fullscreen<CR>", {})
	vim.g.neovide_cursor_animation_length = 0
	vim.g.neovide_cursor_trail_size = 0
	vim.g.neovide_cursor_animate_command_line = false
	vim.cmd([[ inoremap <CS-V> <c-r>+ ]])
	vim.cmd([[ cnoremap <CS-V> <c-r>+ ]])
	vim.cmd([[nmap <CS-V> "+p]])
end
--
-- -- Obsidian vault auto-sync on Neovim exit
-- local vault = vim.fn.expand("~/Documents/Obsidian Vault")
-- local logfile = vim.fn.stdpath("state") .. "/obsync.log"
--
-- -- Set to true for synchronous (blocks exit, captures full output + exit code)
-- -- Set to false for async/detached (returns immediately, logs via shell redirection)
-- local SYNCHRONOUS = false
--
-- local function in_vault()
-- 	local cwd = vim.fn.getcwd()
-- 	return cwd == vault or cwd:sub(1, #vault + 1) == vault .. "/"
-- end
--
-- local function rotate_log()
-- 	local stat = vim.uv.fs_stat(logfile)
-- 	if stat and stat.size > 1024 * 1024 then -- 1 MiB
-- 		os.rename(logfile, logfile .. ".old")
-- 	end
-- end
--
-- local function sync_sync(cwd)
-- 	local ok, output = pcall(vim.fn.system, { "ob", "sync" })
-- 	local code = vim.v.shell_error
-- 	local stamp = os.date("%Y-%m-%d %H:%M:%S")
--
-- 	local f = io.open(logfile, "a")
-- 	if f then
-- 		f:write(string.format("[%s] mode=sync cwd=%s exit=%s\n", stamp, cwd, ok and code or "pcall_err"))
-- 		f:write((output or "") .. "\n")
-- 		f:close()
-- 	end
-- end
--
-- local function sync_async(cwd)
-- 	local stamp = os.date("%Y-%m-%d %H:%M:%S")
-- 	local f = io.open(logfile, "a")
-- 	if f then
-- 		f:write(string.format("[%s] mode=async cwd=%s (output below)\n", stamp, cwd))
-- 		f:close()
-- 	end
--
-- 	vim.fn.jobstart({ "sh", "-c", "ob sync >> " .. vim.fn.shellescape(logfile) .. " 2>&1" }, { detach = true })
-- end
--
-- vim.api.nvim_create_autocmd("VimLeavePre", {
-- 	group = vim.api.nvim_create_augroup("ObsidianSync", { clear = true }),
-- 	callback = function()
-- 		if not in_vault() then
-- 			return
-- 		end
-- 		rotate_log()
-- 		local cwd = vim.fn.getcwd()
-- 		if SYNCHRONOUS then
-- 			sync_sync(cwd)
-- 		else
-- 			sync_async(cwd)
-- 		end
-- 	end,
-- 	desc = "Sync Obsidian vault on exit",
-- })
--
-- vim.api.nvim_create_user_command("ObSync", function()
-- 	if not in_vault() then
-- 		vim.notify("Not in Obsidian Vault", vim.log.levels.WARN)
-- 		return
-- 	end
-- 	rotate_log()
-- 	local cwd = vim.fn.getcwd()
-- 	if SYNCHRONOUS then
-- 		sync_sync(cwd)
-- 		vim.notify("ob sync complete (exit " .. vim.v.shell_error .. ")")
-- 	else
-- 		sync_async(cwd)
-- 		vim.notify("ob sync started in background")
-- 	end
-- end, { desc = "Run ob sync now" })
