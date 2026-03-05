return {
	"stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		backends = { "treesitter", "lsp", "markdown", "man" },
		layout = {
			max_width = { 40, 0.2 },
			min_width = 20,
		},
		filter_kind = false,
	},
	keys = {
		{ "<leader>a", "<cmd>AerialToggle!<cr>", desc = "toggle aerial" },
	},
}
