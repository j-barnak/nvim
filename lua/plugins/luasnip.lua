return {
	"L3MON4D3/LuaSnip",
	version = "2.*",
	build = "make install_jsregexp",
	config = function()
		require("luasnip.loaders.from_lua").load({
			paths = "~/.config/nvim/lua/snippets",
		})

		vim.keymap.set({ "i", "s" }, "<C-j>", function()
			require("luasnip").jump(1)
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-k>", function()
			require("luasnip").jump(-1)
		end, { silent = true })
	end,
}
