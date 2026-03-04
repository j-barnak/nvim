return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  opts = {
    keymap = {
      fzf = {
        ["tab"] = "down",
        ["btab"] = "up",
      },
    },
    lsp = {
      symbols = {
        exec_empty_query = true,
      },
    },
    files = {
      fd_opts = [[--color=never --hidden --follow
                --type f --exclude .git --exclude exports --exclude build]],
    },
    grep = {
      rg_opts = [[--color=never --hidden --line-number --column --no-heading --smart-case -g "!build/*" -g "!.git/*" -g "!exports/*"]],
    },
  },

  keys = {
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "find file" },
    { "<leader>ft", "<cmd>FzfLua tags<cr>", desc = "project tags" },
    { "<leader>fb", "<cmd>FzfLua btags<cr>", desc = "buffer tags" },
    {
      "<leader>fg",
      function() require("fzf-lua").grep_project() end,
      desc = "grep (fuzzy filter immediately)",
    },
    { "<leader>fd", "<cmd>FzfLua lsp_definitions<cr>", desc = "definitions (LSP)" },
    { "<leader>rr", "<cmd>FzfLua lsp_references<cr>", desc = "references (LSP)" },
    { "<leader>fi", "<cmd>FzfLua lsp_implementations<cr>", desc = "implementations (LSP)" },
    { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "document symbols (LSP)" },
    { "<leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "workspace symbols (LSP)" },
  },
}
