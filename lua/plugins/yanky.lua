return {
	"gbprod/yanky.nvim",
	opts = {
		highlight = {
			timer = 0,
		},
		system_clipboard = {
			sync_with_ring = false,
		},
	},
	keys = {
		{ "y", "<Plug>(YankyYank)", mode = { "n", "x" } },
		{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" } },
		{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" } },
		{ "<c-n>", "<Plug>(YankyCycleBackward)" },
		{ "<c-p>", "<Plug>(YankyCycleForward)" },
		{ "<leader>p", "a<space><esc><Plug>(YankyPutAfter)" },
	},
	config = function(_, opts)
		require("yanky").setup(opts)
	end,
}
