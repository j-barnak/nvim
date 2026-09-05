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
		{ "<c-n>", "<Plug>(YankyPreviousEntry)" },
		{ "<c-p>", "<Plug>(YankyNextEntry)" },
		{ "<leader>p", "a<space><esc><Plug>(YankyPutAfter)" },
	},
}
