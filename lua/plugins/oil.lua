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
  local start_dir = bufname ~= "" and vim.fs.dirname(bufname) or vim.loop.cwd()

  local root = vim.fs.find(root_markers, {
    upward = true,
    path = start_dir,
  })[1]

  return root and vim.fs.dirname(root) or vim.loop.cwd()
end

return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  cmd = { "Oil" },
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
      ["h"] = "actions.parent",
      ["l"] = "actions.select",
      ["<CR>"] = "actions.select",
    },
    use_default_keymaps = true,
  },

  config = function(_, opts)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("oil").setup(opts)
  end,
}
