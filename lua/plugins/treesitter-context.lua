return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		max_lines = 3,
		-- ts-context crashes parsing markdown code-fence injections with the
		-- current treesitter; skip it there (Rust docs float, Obsidian notes).
		on_attach = function(buf)
			return vim.bo[buf].filetype ~= "markdown"
		end,
	},
	config = function(_, opts)
		require("treesitter-context").setup(opts)
	end,
}
