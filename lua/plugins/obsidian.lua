local vault = vim.fn.expand("~/Documents/Obsidian Vault")

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	event = {
		{ event = { "BufReadPre", "BufNewFile" }, pattern = vault .. "/*" },
	},
	cmd = "Obsidian",
	opts = {
		legacy_commands = false,
		workspaces = {
			{ name = "personal", path = vault },
		},
		daily_notes = { folder = "Daily" },
		picker = { name = "fzf-lua" },
		ui = { enable = false },
	},
	config = function(_, opts)
		require("obsidian").setup(opts)
		vim.api.nvim_create_autocmd("User", {
			pattern = "ObsidianNoteEnter",
			callback = function()
				pcall(vim.keymap.del, "n", "<CR>", { buffer = true })
				vim.keymap.set(
					"n",
					"<leader><CR>",
					require("obsidian.actions").smart_action,
					{ buffer = true, expr = true, desc = "Obsidian smart action" }
				)
			end,
		})
	end,
}
