return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		indent = { highlight = { "LineNr" }, char = "│" },
		scope = { enabled = false },
		exclude = {
			filetypes = {
				"help",
				"lazy",
				"oil",
				"markdown",
			},
		},
	},
}
