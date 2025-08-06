return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "nvim-telescope/telescope.nvim" },
    { "lukas-reineke/lsp-format.nvim" },
    { "hrsh7th/nvim-cmp" },
  },
  config = function()
    local lspconfig = require("lspconfig")
    local builtin = require("telescope.builtin")
    
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend(
    "force",
      capabilities,
      require("cmp_nvim_lsp").default_capabilities()
    )
    capabilities.textDocument.completion.completionItem.snippetSupport = false   -- ★

    local function with_caps(tbl)
      tbl = tbl or {}
      tbl.capabilities = capabilities
      return tbl
    end
    
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = false })
        vim.keymap.set('n', '<leader>E', vim.diagnostic.open_float, { desc = 'LSP diagnostics under cursor' })
        local opts = { buffer = ev.buf }
        vim.lsp.inlay_hint.enable(true)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>rr", builtin.lsp_references, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      end,
    })

    local sig_toggle = require("config.lsp_toggle")

    vim.keymap.set(
      { "i", "n" },
      "<C-f>",
      sig_toggle.toggle,
      vim.tbl_extend("keep", opts or {}, {
        silent = true,
        desc   = "toggle LSP signature help",
      })
    )


-- <C-g> (insert mode) focuses the popup
vim.keymap.set("i", "<C-g>", sig_toggle.enter, { silent = true, desc = "jump to signature popup" })


    -- Server setup here
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    lspconfig.emmet_language_server.setup({})
    -- lspconfig.tsserver.setup({})
    lspconfig.ruff.setup{}
    lspconfig.pyright.setup{}

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then
          return
        end
        if client.name == 'ruff' then
          client.server_capabilities.hoverProvider = false
        end
      end,
      desc = 'LSP: Disable hover capability from Ruff',
    })

    lspconfig.harper_ls.setup{
        filetypes = { "markdown" },
    }

    lspconfig.millet.setup({
      filetype = { "sml" },
    })

    lspconfig.racket_langserver.setup({
      on_attach = require("lsp-format").on_attach,
    })

    lspconfig.clangd.setup(with_caps({
      on_attach = vim.schedule_wrap(function(client)
        require("lsp-format").on_attach(client)
        vim.keymap.set("n", "<leader><leader>s", "<cmd>ClangdSwitchSourceHeader<cr>")
      end),
      cmd = {
        "clangd",
        "--all-scopes-completion",
        "--background-index",
        "--cross-file-rename",
        "--header-insertion=never",
      },
    }))
    -- lspconfig.clangd.setup({
    --   on_attach = vim.schedule_wrap(
    --     function(client)
    --       require("lsp-format").on_attach(client)
    --       vim.keymap.set("n", "<leader><leader>s", "<cmd>ClangdSwitchSourceHeader<cr>")
    --     end), 
    --   cmd = {
    --     "/usr/bin/clangd",
    --     "--all-scopes-completion",
    --     "--background-index",
    --     "--cross-file-rename",
    --     "--header-insertion=never",
    --   },
    -- })

    vim.keymap.set("n", "<leader>E", function() vim.diagnostic.open_float(nil, { border = "rounded" })
end, { silent = true, desc = "Show diagnostic float" })
    lspconfig.lua_ls.setup({
      on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
          client.config.settings = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
              version = "LuaJIT",
            },
            workspace = {
              library = { vim.env.VIMRUNTIME },
            },
          })
          client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
        return true
      end,
    })
  end,
}
