local filetypes = { "c", "cpp", "rust", "python" }

return {
	"stevearc/conform.nvim",
	ft = filetypes,
	cmd = "ConformInfo",
	opts = {
		notify_no_formatters = false,
		formatters_by_ft = {
			c = { "clang-format" },
			cpp = { "clang-format" },
			rust = { "rustfmt" },
			python = { "ruff_format" },
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetypes,
			callback = function(args)
				vim.keymap.set("n", "==", function()
					require("conform").format({ async = false })
				end, { buffer = args.buf, desc = "Format buffer" })
			end,
		})
	end,
}
