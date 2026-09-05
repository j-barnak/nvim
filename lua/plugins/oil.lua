local root_markers = {
	"stylua.toml",
	"stylua.lua",
	".git",
	".clang-format",
	"pyproject.toml",
	"setup.py",
	".obsidian",
}

local function project_root()
	local bufname = vim.api.nvim_buf_get_name(0)
	local start_dir = bufname ~= "" and vim.fs.dirname(bufname) or vim.uv.cwd()

	local root = vim.fs.find(root_markers, {
		upward = true,
		path = start_dir,
	})[1]

	return root and vim.fs.dirname(root) or vim.uv.cwd()
end

return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-mini/mini.icons" },

	-- Not lazy-loaded: oil's docs advise against it, and it must be the default
	-- file explorer for `nvim .` / `:e <dir>`. netrw is disabled in options.lua.
	lazy = false,
	keys = {
		{
			"<leader>fe",
			function()
				require("oil").toggle_float()
			end,
			mode = "n",
			desc = "Oil (cwd, float)",
		},
		{
			"<leader>fE",
			function()
				require("oil").toggle_float(project_root())
			end,
			mode = "n",
			desc = "Oil (project root, float)",
		},
	},

	opts = {
		default_file_explorer = true,

		float = {
			padding = 3,
			max_width = 0.9,
			max_height = 0.9,
			border = "rounded",
			win_options = {
				winblend = 0,
			},
			override = function(conf)
				local padding = 3
				local columns = vim.o.columns
				local lines = vim.o.lines - vim.o.cmdheight

				conf.width = math.min(conf.width, columns - padding * 2)
				conf.height = math.min(conf.height, lines - padding * 2)

				conf.row = math.floor((lines - conf.height) / 2)
				conf.col = math.floor((columns - conf.width) / 2)

				return conf
			end,
		},

		keymaps = {
			-- Scoped to normal mode (oil gives a bare string `mode or ""`, which
			-- also claims visual and operator-pending, so dl, vll and moving
			-- inside a filename were dead in this editable buffer).
			["h"] = { "actions.parent", mode = "n" },
			["l"] = { "actions.select", mode = "n" },
			["<CR>"] = { "actions.select", mode = "n" },
		},
		use_default_keymaps = true,
	},
}
