return {
	"stevearc/conform.nvim",
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>F",
			function()
				require("conform").format({ async = false })
			end,
			desc = "Format buffer",
		},
	},
	opts = {
		notify_no_formatters = false,
		formatters_by_ft = {
			c = { "clang-format" },
			cpp = { "clang-format" },
			rust = { "rustfmt" },
			python = { "ruff_format" },
		},
	},
}
