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
		local nt = require("nvim-treesitter")
		nt.install(ensure)

		-- Start treesitter highlighting for any buffer whose parser is available.
		-- If a supported parser isn't installed yet (first run / new language),
		-- install it on demand and start once it finishes.
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local buf = args.buf
				local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
				if not lang then
					return
				end
				-- language.add returns (true) / (nil, err); pcall guards a hard error.
				local ok, added = pcall(vim.treesitter.language.add, lang)
				if ok and added then
					vim.treesitter.start(buf, lang)
				elseif vim.tbl_contains(nt.get_available(), lang) then
					nt.install({ lang }):await(function(err)
						if err then
							return
						end
						vim.schedule(function()
							if vim.api.nvim_buf_is_valid(buf) then
								pcall(vim.treesitter.start, buf, lang)
							end
						end)
					end)
				end
			end,
		})
	end,
}
