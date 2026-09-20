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

-- Keywords that turn a quoted string into a module/file path.
local INCLUDE_KW = {
	include = true,
	require = true,
	require_relative = true,
	import = true,
	from = true,
	use = true,
	source = true,
	load = true,
	dofile = true,
	loadfile = true,
}
-- Inline check: cursor is inside a string that directly follows one of the
-- keywords above (an optional `(` and whitespace between is fine, and `<...>`
-- system includes count), e.g.  #include "std|   require("foo|   from "./y|
-- This is what limits path completion in strings to include/require/import.
local function in_include_string()
	if not in_string() then
		return false
	end
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local before = vim.api.nvim_get_current_line():sub(1, col)
	local kw = before:match("([%a_][%w_]*)%s*%(?%s*['\"`<][^'\"`<]*$")
	return kw ~= nil and INCLUDE_KW[kw:lower()] == true
end
-- Also allow path completion when the string CONTENT itself looks like a
-- filesystem path (contains a `/`, or starts with `~`), regardless of any
-- keyword, e.g.  Path::new("/tmp/nyx|   open("./data|   "~/.config/|
local function in_path_string()
	if not in_string() then
		return false
	end
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local before = vim.api.nvim_get_current_line():sub(1, col)
	local content = before:match("['\"`]([^'\"`]*)$")
	return content ~= nil and (content:find("/", 1, true) ~= nil or content:sub(1, 1) == "~")
end

return {
	"saghen/blink.cmp",
	dependencies = {
		"saghen/blink.lib", -- main-branch dependency
		"rafamadriz/friendly-snippets", -- snippets for the `snippets` source
		"mikavilpas/blink-ripgrep.nvim", -- `ripgrep` source (project-wide words)
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
		-- No LSP source. path + snippets, plus ripgrep as the ONE word source
		-- (whole-project words, which subsumes the old `buffer` source). In
		-- strings, only `path` may fire, and only when the string follows
		-- include/require/import or is path-like (so prose strings stay quiet).
		sources = {
			default = { "path", "snippets", "ripgrep" },
			providers = {
				-- path: on everywhere in code; inside a string only in an
				-- include/require/import context. Buffer fallback dropped so a
				-- non-path string never pulls buffer words in.
				path = {
					fallbacks = {},
					enabled = function()
						return not_in_string() or in_include_string() or in_path_string()
					end,
				},
				snippets = { enabled = not_in_string },
				ripgrep = {
					module = "blink-ripgrep",
					name = "Ripgrep",
					score_offset = -3, -- rank below path/snippets
					enabled = not_in_string,
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
