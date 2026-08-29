return {
	"nvim-mini/mini.statuscolumn",
	version = false,
	opts = {},
	config = function(_, opts)
		require("mini.statuscolumn").setup(opts)
	end,
}
