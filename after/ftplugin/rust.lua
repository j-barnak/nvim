-- <leader>K: fuzzy-search Rust docs (std + this project's `cargo doc` deps) and
-- open the selected page as clean text in a split. Buffer-local, so the global
-- <leader>K is unaffected. Uses: fd, xmllint, w3m.

local function doc_cmd(path, cols)
	-- Render only <section id="main-content"> -> plain text, dropping the
	-- rustdoc sidebar / logo / nav chrome.
	return string.format(
		[[xmllint --html --xpath "//*[@id='main-content']" %s 2>/dev/null | w3m -dump -T text/html -cols %s]],
		path,
		cols
	)
end

local function open_doc(path)
	local out = vim.fn.systemlist(doc_cmd(vim.fn.shellescape(path), 100))
	if not out or #out == 0 then
		out = vim.fn.systemlist({ "w3m", "-dump", "-cols", "100", path }) -- fallback: whole page
	end
	vim.cmd("botright new")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
	vim.bo.buftype, vim.bo.bufhidden, vim.bo.modifiable = "nofile", "wipe", false
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = 0 })
end

vim.keymap.set("n", "<leader>K", function()
	if vim.fn.executable("w3m") == 0 then
		return vim.notify("w3m not found (needed to render Rust docs)", vim.log.levels.WARN)
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

	require("fzf-lua").fzf_exec("fd --type f --extension html --absolute-path . " .. table.concat(roots, " "), {
		prompt = "RustDocs> ",
		fzf_opts = { ["--preview"] = doc_cmd("{}", "$FZF_PREVIEW_COLUMNS") },
		actions = {
			["default"] = function(sel)
				if sel and sel[1] then
					open_doc(sel[1])
				end
			end,
		},
	})
end, { buffer = true, desc = "Search Rust docs" })
