return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",

	opts = {
		keymap = {
			fzf = {
				true,
				["tab"] = "down",
				["btab"] = "up",
			},
		},
		files = {
			-- Must stay on ONE line: fzf-lua splices this verbatim into a single
			-- sh command, so an embedded newline truncates it (dropping --type f
			-- and every exclude, and erroring on the remainder).
			fd_opts = "--color=never --hidden --follow --type f --exclude .git --exclude exports --exclude build",
		},
		grep = {
			rg_opts = [[--color=never --hidden --line-number --column --no-heading --smart-case -g "!build/*" -g "!.git/*" -g "!exports/*"]],
		},
	},

	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "find file" },
		{
			"<leader>fg",
			function()
				require("fzf-lua").grep_project()
			end,
			desc = "grep",
		},
		{ "<leader>ft", "<cmd>FzfLua tags<cr>", desc = "project tags" },
		{ "<leader>fb", "<cmd>FzfLua btags<cr>", desc = "buffer tags" },
		{
			"<leader>fs",
			function()
				require("fzf-lua").treesitter()
			end,
			desc = "document symbols",
		},
	},
}
