-- LeetCode inside Neovim. Loaded on :Leet (not at startup) so it never takes
-- over the dashboard; it drives its own UI from there.
return {
	"kawre/leetcode.nvim",
	cmd = "Leet",
	-- leetcode.nvim renders problem statements as HTML, so it needs the html
	-- treesitter parser; this config already runs nvim-treesitter.
	build = ":TSUpdate html",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	opts = {
		-- Use the picker this config already ships (fzf-lua), not telescope.
		picker = { provider = "fzf-lua" },
	},
}
