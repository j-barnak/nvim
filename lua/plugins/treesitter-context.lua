return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		max_lines = 3,
	},
	config = function(_, opts)
		require("treesitter-context").setup(opts)
	end,
}
