local ensure = {
	"bash",
	"c",
	"cpp",
	"css",
	"diff",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"rust",
	"toml",
	"vim",
	"vimdoc",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install(ensure)

		-- Start treesitter highlighting for any buffer whose parser is available.
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
				if not lang then
					return
				end
				-- language.add returns (true) / (nil, err); pcall guards a hard error.
				local ok, added = pcall(vim.treesitter.language.add, lang)
				if ok and added then
					vim.treesitter.start(args.buf, lang)
				end
			end,
		})
	end,
}
