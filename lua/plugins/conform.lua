-- Formatting, on save and on demand (conform.nvim).
--
-- One mechanism does both jobs. A filetype with a real formatter gets that
-- formatter, and it takes care of trailing whitespace as part of its output.
-- Every other filetype falls through to the "_" entry, conform's built-in
-- trim_whitespace + trim_newlines, so trailing spaces and blank lines at the
-- end of the file never survive a save anywhere, Markdown included (a hard
-- line break there is a trailing backslash, not two trailing spaces).
-- mini.trailspace stays for the highlight only; a second BufWritePre trimmer
-- would fight the formatters.
--
-- Format-on-save follows the conform recipe: a function so that
-- :FormatDisable (global) / :FormatDisable! (this buffer) / :FormatEnable can
-- switch it off for a file that must be saved as-is. The timeout is generous
-- because ormolu and `raco fmt` take a moment to start.
--
-- Tools (this machine, Ubuntu 26.04): clang-format, ormolu, ocamlformat,
-- racket (+ `raco pkg install fmt`) from apt; ruff is the static release binary and
-- prettier + prettierd come from npm, both in ~/.local/bin; rustfmt from rustup.
-- :ConformInfo shows what is found.
local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
	"stevearc/conform.nvim",
	-- Loaded by the first write (lazy.nvim replays the event, so that save is
	-- formatted too), by its commands, or by the mapping.
	event = { "BufWritePre" },
	cmd = { "ConformInfo", "FormatDisable", "FormatEnable" },
	keys = {
		{
			"==",
			function()
				require("conform").format({ async = true })
			end,
			mode = { "n", "x" },
			desc = "Format buffer / selection",
		},
	},
	init = function()
		-- gq and = use the same formatters (falls back to the built-in behaviour
		-- for filetypes with none).
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
	opts = {
		notify_no_formatters = false,
		default_format_opts = { lsp_format = "fallback" },
		formatters_by_ft = {
			c = { "clang-format" },
			cpp = { "clang-format" },
			rust = { "rustfmt" },
			python = { "ruff_format" },
			haskell = { "ormolu" },
			javascript = prettier,
			javascriptreact = prettier,
			typescript = prettier,
			typescriptreact = prettier,
			json = prettier,
			-- --enable-outside-detected-project is in conform's definition, so a
			-- file with no .ocamlformat nearby still formats.
			ocaml = { "ocamlformat" },
			racket = { "racketfmt" }, -- `raco fmt` (the fmt package)
			["_"] = { "trim_whitespace", "trim_newlines" },
		},
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return { timeout_ms = 1000, lsp_format = "fallback" }
		end,
	},
	config = function(_, opts)
		require("conform").setup(opts)
		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
		end, { desc = "Disable format-on-save (! = this buffer only)", bang = true })
		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, { desc = "Re-enable format-on-save" })
	end,
}
