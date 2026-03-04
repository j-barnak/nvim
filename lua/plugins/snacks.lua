return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    zen = {
      toggles = {
        dim = false,
        git_signs = false,
        mini_diff_signs = false,
        diagnostics = false,
        inlay_hints = false,
      },
      show = {
        statusline = false,
        tabline = false,
      },
      win = {
        style = "zen",
        minimal = true,
        width = 120,
        backdrop = { transparent = false, blend = 10 },
      },
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    vim.api.nvim_create_user_command("Zen", function() Snacks.zen() end, { desc = "Toggle Zen mode" })
  end,
}
