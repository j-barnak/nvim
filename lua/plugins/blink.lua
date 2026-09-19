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
		-- Turn completion off inside string literals (keeps normal buffer/path/
		-- ripgrep noise out of strings), on top of blink's default gating.
		enabled = function()
			if vim.bo.buftype == "prompt" or vim.b.completion == false then
				return false
			end
			local ok, node = pcall(vim.treesitter.get_node)
			if ok and node and node:type():lower():find("string") then
				return false
			end
			return true
		end,
		-- C-n / C-p move through the menu, <CR> accepts the highlighted item (and
		-- is a normal newline when nothing is selected). C-space opens the menu,
		-- C-e hides it; <Tab> still jumps between snippet fields.
		keymap = {
			preset = "default",
			["<CR>"] = { "accept", "fallback" },
		},
		completion = {
			-- Open the menu automatically, but preselect nothing: you land on no
			-- item until you press C-n/C-p, and nothing is inserted until <CR>.
			menu = { auto_show = true },
			list = { selection = { preselect = false, auto_insert = false } },
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
		-- Command-line completion for `:` commands and `/` `?` search: menu opens
		-- automatically, nothing preselected, C-n/C-p choose, Enter runs the line.
		cmdline = {
			keymap = { preset = "cmdline" },
			completion = {
				menu = { auto_show = true },
				list = { selection = { preselect = false } },
			},
		},
		-- Default fuzzy = prefer the Rust matcher built above, warn + fall back to
		-- the Lua matcher if the build is missing.
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
