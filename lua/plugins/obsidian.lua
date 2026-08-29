return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	ft = "markdown",
	opts = {
		legacy_commands = false,
		workspaces = {
			{ name = "personal", path = "~/Documents/Obsidian Vault" },
		},
		picker = { name = "fzf-lua" },
		ui = { enable = false },
	},
	config = function(_, opts)
		require("obsidian").setup(opts)
		-- Keep our global <CR> = ciw; move obsidian's smart action to <leader><CR>.
		-- Link nav [o/]o is left intact.
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
