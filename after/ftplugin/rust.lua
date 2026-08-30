-- <leader>K: fuzzy-search Rust docs (std + this project's `cargo doc` deps),
-- open the selected page as clean Markdown in a right vsplit. Buffer-local, so
-- the global <leader>K is unaffected. Uses: fd, xmllint, pandoc, w3m.

local function have(bin)
	return vim.fn.executable(bin) == 1
end

-- Extract just <section id="main-content"> (drops the rustdoc sidebar/logo/nav).
local XPATH = [[xmllint --html --xpath "//*[@id='main-content']" %s 2>/dev/null]]

local function to_markdown(path)
	local extract = XPATH:format(vim.fn.shellescape(path))
	-- Preferred: clean Markdown. gfm-raw_html drops HTML pandoc can't map.
	if have("xmllint") and have("pandoc") then
		local out = vim.fn.systemlist(extract .. " | pandoc -f html -t gfm-raw_html --wrap=none 2>/dev/null")
		if out and #out > 0 then
			return out
		end
	end
	-- Fallback: still main-content only (sidebar-free) via w3m.
	if have("xmllint") and have("w3m") then
		local out = vim.fn.systemlist(extract .. " | w3m -dump -T text/html 2>/dev/null")
		if out and #out > 0 then
			return out
		end
	end
	-- Last resort: whole page.
	if have("w3m") then
		return vim.fn.systemlist({ "w3m", "-dump", path })
	end
	return {}
end

local function open_doc(path)
	local lines = to_markdown(path)
	if not lines or #lines == 0 then
		return vim.notify("Could not render " .. vim.fs.basename(path), vim.log.levels.WARN)
	end
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
	if not have("fd") then
		return vim.notify("fd not found (needed to search Rust docs)", vim.log.levels.WARN)
	end
	if not have("xmllint") then
		return vim.notify("xmllint not found (needed to extract Rust docs)", vim.log.levels.WARN)
	end
	if not have("pandoc") and not have("w3m") then
		return vim.notify("Need pandoc or w3m to render Rust docs", vim.log.levels.WARN)
	end

	local candidates = { vim.fn.getcwd() .. "/target/doc" }
	if have("rustc") then
		table.insert(candidates, 1, vim.fn.trim(vim.fn.system({ "rustc", "--print", "sysroot" })) .. "/share/doc/rust/html")
	end
	local roots = {}
	for _, d in ipairs(candidates) do
		if vim.fn.isdirectory(d) == 1 then
			roots[#roots + 1] = vim.fn.shellescape(d)
		end
	end
	if #roots == 0 then
		return vim.notify("No Rust docs found (run: cargo doc)", vim.log.levels.WARN)
	end

	local opts = {
		prompt = "RustDocs> ",
		actions = {
			["default"] = function(sel)
				if sel and sel[1] then
					open_doc(sel[1])
				end
			end,
		},
	}
	-- Live preview only when both extraction tools are present.
	if have("w3m") then
		opts.preview = XPATH:format("{}") .. " | w3m -dump -T text/html -cols $FZF_PREVIEW_COLUMNS"
	end
	require("fzf-lua").fzf_exec("fd --type f --extension html --absolute-path . " .. table.concat(roots, " "), opts)
end, { buffer = true, desc = "Search Rust docs" })

-- Revert the buffer-local mapping if this buffer's filetype changes.
vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
	.. "silent! lua pcall(vim.keymap.del, 'n', '<leader>K', { buffer = 0 })"
