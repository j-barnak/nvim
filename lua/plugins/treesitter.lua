return {
	"nvim-treesitter/nvim-treesitter",
	build = function()
		require("nvim-treesitter.install").update({ with_sync = true })
	end,
	lazy = false,
	opts = {
		indent = { enable = true },
		ensure_installed = {
			"c",
			"lua",
			"javascript",
			"cpp",
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				scope_incremental = false,
				node_decremental = "<bs>",
			},
		},
		sync_install = false,
		auto_install = true,
		highlight = {
			enable = true,
			disable = function(lang, bufnr)
				-- The markdown parser crashes on code-fence injections in this
				-- nvim build; fall back to Vim's built-in markdown syntax.
				if lang == "markdown" or lang == "markdown_inline" then
					return true
				end
				return vim.api.nvim_buf_line_count(bufnr) > 50000
					and (lang == "cpp" or lang == "c" or lang == "javascript")
			end,
			additional_vim_regex_highlighting = false,
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
		-- The markdown parser crashes on code-fence injections in this nvim
		-- build. Stop the TS highlighter on markdown (deferred so it runs after
		-- nvim-treesitter starts it) and fall back to Vim's built-in syntax.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function(ev)
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(ev.buf) then
						pcall(vim.treesitter.stop, ev.buf)
					end
				end)
			end,
		})
	end,
}
