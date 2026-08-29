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
	},
}
