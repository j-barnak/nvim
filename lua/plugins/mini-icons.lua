return {
	"nvim-mini/mini.icons",
	lazy = false,
	priority = 900,
	opts = {},
	config = function(_, opts)
		require("mini.icons").setup(opts)
		require("mini.icons").mock_nvim_web_devicons()
	end,
}
