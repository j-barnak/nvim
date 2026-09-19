-- diffview.nvim: a single tab-page view of a git diff across all changed files,
-- plus a file/branch history browser. Complements fugitive (:G) and gitsigns
-- (per-hunk staging): this is the "show me the whole diff / the history" view.
-- :DiffviewOpen also takes a git rev, e.g. :DiffviewOpen origin/main...HEAD.
return {
	"sindrets/diffview.nvim",
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
		"DiffviewFileHistory",
	},
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open (working tree)" },
		{ "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: branch history" },
		{ "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: current file history" },
	},
	opts = {},
}
