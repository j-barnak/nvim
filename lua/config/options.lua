vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.backup = false
vim.opt.fileencoding = "utf-8"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.autoindent = true
vim.opt.smartindent = true
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
vim.opt.softtabstop = 4
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.signcolumn = "yes:1"
vim.opt.cursorline = true
vim.opt.colorcolumn = "72"
vim.opt.exrc = true
vim.opt.secure = true
vim.opt.confirm = true
vim.g.editorconfig = false

vim.api.nvim_create_autocmd("ColorScheme", {
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
