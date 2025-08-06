return {
  "adigitoleo/haunt.nvim",
  opts = {},

  -- 1 ▪ normal-mode <C-e> opens the man page for the word under the cursor
  keys = {
    { "<C-e>", "<cmd>HauntMan<CR>",
      mode = "n",
      desc = "Haunt: float man page for <cword>" },
  },

  -- 2 ▪ when a Haunt man/help window appears, add a buffer-local <C-e> that quits it
  config = function(_, opts)
    require("haunt").setup(opts)

    -- man pages opened by Haunt have filetype 'man'
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "man",
      callback = function(ev)
        -- map once per buffer
        vim.keymap.set(
          { "n", "i" }, "<C-e>", "<cmd>quit<CR>",
          { buffer = ev.buf, silent = true, noremap = true }
        )
      end,
    })
  end,
}
