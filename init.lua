local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
	-- Without this a first run with no network gives a bare Lua traceback
	-- from the require below instead of saying what actually failed.
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit ..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config")
require("lazy").setup("plugins", {
	performance = {
		rtp = {
			-- Runtime plugins nothing here uses (netrw is replaced by oil);
			-- skipping them saves ~1.3 ms of sourcing per launch.
			-- "tohtml" is not listed: it ships as an opt package
			-- (pack/dist/opt/nvim.tohtml) and is not sourced at startup.
			disabled_plugins = { "gzip", "matchit", "netrwPlugin", "tarPlugin", "tutor", "zipPlugin" },
		},
	},
})
