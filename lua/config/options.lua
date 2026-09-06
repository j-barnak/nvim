-- netrw and the other unused runtime plugins are disabled through lazy.nvim's
-- performance.rtp.disabled_plugins (init.lua); oil is the file explorer.

vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.autoindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
-- Truecolor, confirmed rather than forced. Nvim auto-detects since 0.10, but
-- the detection fails inside tmux: tmux-256color's terminfo carries no RGB
-- capability and tmux does not export COLORTERM, so a forced `= true` was the
-- only reason the hex colours below applied. tmux does render truecolor (and
-- downsamples when the outer terminal cannot), so ask it instead of assuming.
if not vim.o.termguicolors then
	local colorterm = vim.env.COLORTERM
	if colorterm == "truecolor" or colorterm == "24bit" then
		vim.o.termguicolors = true
	elseif vim.env.TMUX and vim.fn.executable("tmux") == 1 then
		-- ~2 ms, and only on the path where nothing else could answer.
		local feats = vim.fn.system({ "tmux", "display", "-p", "#{client_termfeatures}" })
		vim.o.termguicolors = feats:find("RGB", 1, true) ~= nil
	end
end
vim.opt.undofile = true
vim.opt.undodir = vim.env.HOME .. "/.vim/undodir" -- shared with Vim; Nvim's default would also persist
vim.opt.updatetime = 50
vim.opt.writebackup = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.signcolumn = "yes:1"
vim.opt.cursorline = true
vim.opt.colorcolumn = "72"
vim.opt.cmdheight = 0
-- Project-local config, gated by Nvim's trust list (:trust). 0.12 searches
-- every parent directory, not just the cwd, and 'secure' is a no-op here.
vim.opt.exrc = true
vim.opt.confirm = true
-- Turns off Neovim's built-in EditorConfig reader only. vim-sleuth ships its
-- own parser and still honours a project's .editorconfig ahead of its
-- heuristics, so a project file can set shiftwidth over the values above.
vim.g.editorconfig = false

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("jb.colorscheme", { clear = true }),
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "Pmenu", { fg = "#dddddd", bg = "#303030" })
		vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#000000", bg = "#87afaf" })
		vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
		vim.api.nvim_set_hl(0, "FloatTitle", { fg = "#87afaf", bold = true })
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "#1f3a5f" })
		vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffff00", bold = true })
		vim.api.nvim_set_hl(0, "MatchParen", { fg = "#e0af68", bold = true, underline = true })
	end,
})
vim.cmd.colorscheme("vim")
