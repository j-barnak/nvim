-- blink.cmp (main / latest) completion.
-- Docs: https://main.cmp.saghen.dev  Reference: /configuration/reference.html
return {
	"saghen/blink.cmp",
	dependencies = {
		"saghen/blink.lib", -- main-branch dependency
		"rafamadriz/friendly-snippets", -- snippets for the `snippets` source
		"mikavilpas/blink-ripgrep.nvim", -- `ripgrep` source (project-wide words)
		"Kaiser-Yang/blink-cmp-git", -- `git` source (commit messages)
	},
	event = { "InsertEnter", "CmdlineEnter" },
	-- Latest = the `main` branch, so build the Rust SIMD fuzzy matcher (the
	-- frizbee-family matcher). Needs a Rust toolchain; `gb` in :Lazy rebuilds it.
	build = function()
		require("blink.cmp").build():pwait()
	end,
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- Tab / Shift-Tab SELECT the next/previous item in the menu. If the menu
		-- is closed but a snippet is active they jump between snippet fields, and
		-- otherwise fall back to a normal <Tab>. Accept the selected item with
		-- C-y (the `default` preset); C-e hides the menu, C-space opens it.
		keymap = {
			preset = "default",
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		},
		completion = {
			menu = { auto_show = true },
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
		},
		-- No LSP source. path/snippets/buffer plus the two chosen extras:
		-- ripgrep (whole-project words) everywhere, git only in commit buffers.
		sources = {
			default = { "path", "snippets", "buffer", "ripgrep", "git" },
			providers = {
				ripgrep = {
					module = "blink-ripgrep",
					name = "Ripgrep",
					score_offset = -3, -- rank below path/snippets/buffer
				},
				git = {
					module = "blink-cmp-git",
					name = "Git",
					-- Only run in commit-message-ish buffers.
					enabled = function()
						return vim.tbl_contains({ "octo", "gitcommit", "markdown" }, vim.bo.filetype)
					end,
				},
			},
		},
		-- Command-line completion for `:` commands and `/` `?` search. Tab/S-Tab
		-- select here too; C-y accepts, Enter runs the line.
		cmdline = {
			keymap = {
				preset = "cmdline",
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
			},
			completion = { menu = { auto_show = true } },
		},
		-- Default fuzzy = prefer the Rust matcher built above, warn + fall back to
		-- the Lua matcher if the build is missing.
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
