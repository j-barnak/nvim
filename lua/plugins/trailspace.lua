return {
	"nvim-mini/mini.trailspace",
	event = { "BufReadPost", "BufNewFile" },
	opts = {},
	config = function(_, opts)
		require("mini.trailspace").setup(opts)
	end,
}
