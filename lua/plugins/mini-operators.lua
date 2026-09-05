return {
	"nvim-mini/mini.operators",
	version = false,
	opts = {
		exchange = { prefix = "X" },
		multiply = { prefix = "M" },
		-- The default `gr` prefix would remove Nvim's gra/gri/grn/grr/grt LSP
		-- mappings (mini.operators deletes conflicting built-ins).
		replace = { prefix = "gR" },
	},
}
