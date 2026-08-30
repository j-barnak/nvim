-- <leader>K: fuzzy-search Rust docs (std + this project's `cargo doc` deps),
-- open the selected page as clean Markdown in a floating window. Buffer-local,
-- so the global <leader>K is unaffected. Uses: fd, xmllint, pandoc, w3m.

-- Extract just <section id="main-content"> (drops the rustdoc sidebar/logo/nav).
local XPATH = [[xmllint --html --xpath "//*[@id='main-content']" %s 2>/dev/null]]

local function to_markdown(path)
	local extract = XPATH:format(vim.fn.shellescape(path))
	-- gfm-raw_html drops any HTML pandoc can't map, leaving clean Markdown.
	local out = vim.fn.systemlist(extract .. " | pandoc -f html -t gfm-raw_html --wrap=none 2>/dev/null")
	if not out or #out == 0 then
		out = vim.fn.systemlist({ "w3m", "-dump", path }) -- fallback: plain text
	end
	return out
end

local function open_doc(path)
	local lines = to_markdown(path)
	vim.cmd("rightbelow vsplit")
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, buf)
	vim.bo[buf].buftype, vim.bo[buf].bufhidden = "nofile", "wipe"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	-- Set filetype only after the split is the current window so the markdown
	-- ftplugin's window-local options don't leak onto the Rust window.
	vim.bo[buf].filetype = "markdown"
	vim.bo[buf].modifiable = false
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
	-- Oil opens in this doc's directory (browse sibling pages), not the cwd.
	local dir = vim.fs.dirname(path)
	vim.keymap.set("n", "<leader>fe", function()
		require("oil").toggle_float(dir)
	end, { buffer = buf, desc = "Oil (this doc's directory)" })
end

vim.keymap.set("n", "<leader>K", function()
	if vim.fn.executable("pandoc") == 0 and vim.fn.executable("w3m") == 0 then
		return vim.notify("Need pandoc or w3m to render Rust docs", vim.log.levels.WARN)
	end
	local roots = {}
	for _, d in ipairs({
		vim.fn.trim(vim.fn.system({ "rustc", "--print", "sysroot" })) .. "/share/doc/rust/html",
		vim.fn.getcwd() .. "/target/doc",
	}) do
		if vim.fn.isdirectory(d) == 1 then
			roots[#roots + 1] = vim.fn.shellescape(d)
		end
	end
	if #roots == 0 then
		return vim.notify("No Rust docs found (run: cargo doc)", vim.log.levels.WARN)
	end

	local preview = XPATH:format("{}") .. " | w3m -dump -T text/html -cols $FZF_PREVIEW_COLUMNS"
	require("fzf-lua").fzf_exec("fd --type f --extension html --absolute-path . " .. table.concat(roots, " "), {
		prompt = "RustDocs> ",
		fzf_opts = { ["--preview"] = preview },
		actions = {
			["default"] = function(sel)
				if sel and sel[1] then
					open_doc(sel[1])
				end
			end,
		},
	})
end, { buffer = true, desc = "Search Rust docs" })
