return {
	"nvim-mini/mini.surround",
	event = "VeryLazy",
	version = false, -- main branch, like the other mini modules here
	keys = {
		{
			mode = "x",
			"S",
			":<C-u>lua MiniSurround.add('visual')<CR>",
			desc = "Surround in visual",
			silent = true,
		},

		{
			mode = "x",
			"SC",
			":<C-u>lua MiniSurround.add('visual')<CR>c",
			desc = "Surround with <code>",
			silent = true,
		},
	},

	opts = {
		mappings = {
			add = "'a",
			delete = "'d",
			find = "'f",
			find_left = "'F",
			highlight = "'h",
			replace = "'r",
			update_n_lines = "'n",
		},

		custom_surroundings = {
			c = {
				output = { left = "<code>", right = "</code>" },
			},
		},
	},
}
