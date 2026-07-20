return {
	"nvim-mini/mini.cursorword",
	event = { "BufReadPost", "BufNewFile" },
	opts = {},
	config = function(_, opts)
		require("mini.cursorword").setup(opts)
	end,
}
