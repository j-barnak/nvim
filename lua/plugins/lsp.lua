return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "nvim-telescope/telescope.nvim" },
    { "lukas-reineke/lsp-format.nvim" },
    { "hrsh7th/nvim-cmp" },
  },
  config = function()
    local builtin    = require("telescope.builtin")
    local sig_toggle = require("config.lsp_toggle")
    local lsp_format = require("lsp-format")

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend(
      "force",
      capabilities,
      require("cmp_nvim_lsp").default_capabilities()
    )
    capabilities.textDocument.completion.completionItem.snippetSupport = false

    local function with_caps(opts)
      opts = opts or {}
      opts.capabilities = capabilities
      return opts
    end

    ---------------------------------------------------------------------------
    -- Global LspAttach: completion, inlay hints, per-buffer LSP keymaps
    ---------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = false })
        vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })

        local opts = { buffer = ev.buf }

        vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,    opts)
        vim.keymap.set("n", "gd",         vim.lsp.buf.definition,     opts)
        vim.keymap.set("n", "<leader>I",  vim.lsp.buf.hover,          opts)
        vim.keymap.set("n", "gi",         vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>rr", builtin.lsp_references,     opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,         opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,    opts)
      end,
    })

    vim.keymap.set({ "i", "n" }, "<C-f>", sig_toggle.toggle, {
      silent = true,
      desc   = "toggle LSP signature help",
    })

    vim.keymap.set("i", "<C-g>", sig_toggle.enter, {
      silent = true,
      desc   = "jump to signature popup",
    })

    vim.keymap.set("n", "<leader>E", function()
      vim.diagnostic.open_float(nil, { border = "rounded" })
    end, { silent = true, desc = "Show diagnostic float" })


    vim.lsp.config("emmet_language_server", with_caps({}))
    vim.lsp.config("tsserver", with_caps({}))

    vim.lsp.config("ruff", with_caps({}))
    vim.lsp.config("pyright", with_caps({}))

    vim.lsp.config("harper_ls", with_caps({
      filetypes = { "markdown" },
    }))

    vim.lsp.config("millet", with_caps({
      -- original intent: SML only
      filetypes = { "sml" },
    }))

    vim.lsp.config("racket_langserver", with_caps({
      on_attach = lsp_format.on_attach,
    }))

    vim.lsp.config("clangd", with_caps({
      on_attach = vim.schedule_wrap(function(client, bufnr)
        -- same as your original: format on attach + keymap
        lsp_format.on_attach(client, bufnr)
        vim.keymap.set(
          "n",
          "<leader><leader>s",
          "<cmd>ClangdSwitchSourceHeader<cr>",
          { buffer = bufnr, silent = true, desc = "Switch source/header" }
        )
      end),
      cmd = {
        "clangd",
        "--all-scopes-completion",
        "--background-index",
        "--cross-file-rename",
        "--header-insertion=never",
      },
    }))

    vim.lsp.config("lua_ls", with_caps({
      on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path .. "/.luarc.json")
          and not vim.loop.fs_stat(path .. "/.luarc.jsonc")
        then
          client.config.settings = vim.tbl_deep_extend(
            "force",
            client.config.settings or {},
            {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                },
                workspace = {
                  library = { vim.env.VIMRUNTIME },
                },
              },
            }
          )
          client.notify("workspace/didChangeConfiguration", {
            settings = client.config.settings,
          })
        end
        return true
      end,
    }))

    vim.lsp.enable({
      "emmet_language_server",
      "ruff",
      "pyright",
      "harper_ls",
      "millet",
      "racket_langserver",
      "clangd",
      "lua_ls",
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "ruff" then
          client.server_capabilities.hoverProvider = false
        end
      end,
      desc = "LSP: Disable hover capability from Ruff",
    })
  end,
}
