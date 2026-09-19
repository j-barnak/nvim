-- blink.cmp (main / latest) completion.
-- Docs: https://main.cmp.saghen.dev  Reference: /configuration/reference.html

-- True when the cursor sits inside a string literal (treesitter). Used to gate
-- the noisy sources OFF in strings while leaving `path` on, so completion in a
-- string only appears when the text is path-like (e.g. include "dir/file.h").
local function in_string()
	local ok, node = pcall(vim.treesitter.get_node)
	return ok and node ~= nil and node:type():lower():find("string") ~= nil
end
local function not_in_string()
	return not in_string()
end

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
		-- Tab / Shift-Tab (and C-n / C-p) move through the menu; <CR> accepts the
		-- highlighted item and is a normal newline when nothing is selected. When
		-- the menu is closed, Tab/S-Tab jump between snippet fields, else fall back
		-- to a plain Tab. C-space opens the menu, C-e hides it.
		keymap = {
			preset = "default",
			["<CR>"] = { "accept", "fallback" },
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		},
		completion = {
			-- Open the menu automatically, but preselect nothing: you land on no
			-- item until you press C-n/C-p, and nothing is inserted until <CR>.
			menu = { auto_show = true },
			list = { selection = { preselect = false, auto_insert = false } },
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
		},
		-- No LSP source. path/snippets/buffer plus ripgrep (whole-project words)
		-- and git (commit buffers). Every source EXCEPT `path` is gated off inside
		-- strings, so a string only completes when it is path-like (include-style
		-- "dir/file.h" paths get filesystem completion; prose strings stay quiet).
		sources = {
			default = { "path", "snippets", "buffer", "ripgrep", "git" },
			providers = {
				-- path: no string gate -> stays on inside strings. It self-triggers
				-- only on path-like input, and drops the buffer fallback so a
				-- non-path string never pulls buffer words in.
				path = { fallbacks = {} },
				snippets = { enabled = not_in_string },
				buffer = { enabled = not_in_string },
				ripgrep = {
					module = "blink-ripgrep",
					name = "Ripgrep",
					score_offset = -3, -- rank below path/snippets/buffer
					enabled = not_in_string,
				},
				git = {
					module = "blink-cmp-git",
					name = "Git",
					-- Only run in commit-message-ish buffers, and never in strings.
					enabled = function()
						return not_in_string()
							and vim.tbl_contains({ "octo", "gitcommit", "markdown" }, vim.bo.filetype)
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
