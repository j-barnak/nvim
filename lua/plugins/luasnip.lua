return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  keys = {
    { "<S-CR>", function() require("luasnip").jump(1)    end, mode = "i", silent = true },
    { "<C-CR>", function() require("luasnip").expand()   end, mode = "i", silent = true },
  },
}
