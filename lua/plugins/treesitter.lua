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
			-- Own augroup (cleared on re-source) so reloading the config never
			-- stacks duplicate handlers.
			group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
			callback = function(args)
				local buf = args.buf
				-- Big-file guard: treesitter highlight + injections get slow on very
				-- large buffers (e.g. the sqlite3.h API header, the GCC manual, big
				-- source files). Skip it past a size threshold; regex syntax stays.
				local nlines = vim.api.nvim_buf_line_count(buf)
				if nlines > 5000 or vim.api.nvim_buf_get_offset(buf, nlines) > 512 * 1024 then
					vim.b[buf].ts_disabled_bigfile = true
					return
				end
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
