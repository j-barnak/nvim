return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"s",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump({ search = { forward = true, wrap = false, multi_window = false } })
			end,
			desc = "Flash forward",
		},
		{
			"S",
			mode = { "n", "o" },
			function()
				require("flash").jump({ search = { forward = false, wrap = false, multi_window = false } })
			end,
			desc = "Flash backward",
		},
	},
}
