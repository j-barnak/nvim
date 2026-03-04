return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    { "L3MON4D3/LuaSnip", version = "v2.*" },
  },
  opts = {
    snippets = { preset = "luasnip" },

    keymap = {
      preset = "none",
      ["<Tab>"] = {
        function(cmp)
          if cmp.is_visible() then return cmp.select_next() end
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        function(cmp)
          if cmp.is_visible() then return cmp.select_prev() end
        end,
        "fallback",
      },
      ["<CR>"]      = { "accept", "fallback" },
      ["<C-Space>"] = { "show", "fallback" },
      ["<C-e>"]     = { "hide", "fallback" },
      ["<C-p>"]     = { "scroll_documentation_up", "fallback" },
      ["<C-n>"]     = { "scroll_documentation_down", "fallback" },
    },

    completion = {
      menu = {
        draw = {
          treesitter = { "lsp", "buffer", "snippets" },
        },
      },
      list = {
        selection = {
          preselect   = false,
          auto_insert = false,
        },
      },
      documentation = {
        auto_show          = true,
        auto_show_delay_ms = 200,
      },
    },

    sources = {
      default = function(_ctx)
        local ok, node = pcall(vim.treesitter.get_node)
        if ok and node then
          local t = node:type()
          if t:match("string") or t:match("comment") then
            return { "path" }
          end
        end
        return { "lsp", "path", "snippets", "buffer" }
      end,

      providers = {
        snippets = { score_offset = 5 },
      },
    },

    -- fuzzy = {
    --   implementation  = "prefer_rust",
    --   frecency        = { enabled = true },
    --   use_proximity   = true,
    -- },

    fuzzy = {
      implementation = "prefer_rust",  -- Rust matcher is required for typo resistance
      max_typos = function(keyword)
        return math.floor(#keyword / 4)  -- 1 typo per 4 chars, e.g. 4+ char keywords get 1 typo allowed
      end,
      frecency      = { enabled = true },
      use_proximity = true,
    },

    appearance = {
      nerd_font_variant = "mono",
    },
  },
}
