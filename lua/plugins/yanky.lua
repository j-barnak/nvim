return {
	"gbprod/yanky.nvim",
	opts = {
		-- on_put/on_yank are the documented switches; a timer of 0 does not
		-- turn the highlight off.
		highlight = {
			on_put = false,
			on_yank = false,
		},
		system_clipboard = {
			sync_with_ring = false,
		},
	},
	keys = {
		{ "y", "<Plug>(YankyYank)", mode = { "n", "x" } },
		{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" } },
		{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" } },
		-- Previous on <c-p>, next on <c-n>, matching yanky's README (they were
		-- swapped, which also shadowed the built-in motions in the wrong order).
		{ "<c-p>", "<Plug>(YankyPreviousEntry)" },
		{ "<c-n>", "<Plug>(YankyNextEntry)" },
		{ "<leader>p", "a<space><esc><Plug>(YankyPutAfter)" },
	},
}
