local util = require("config.util")
local have, shq = util.have, util.shq

local XPATH = [[xmllint --html --xpath "//*[@id='main-content']" %s 2>/dev/null]]

-- The render pipelines, best first. Each runs under `sh`, so shq (POSIX
-- quoting), not shellescape (which quotes for the user's 'shell').
local function pipelines(path)
	local extract = XPATH:format(shq(path))
	local out = {}
	if have("xmllint") and have("pandoc") then
		out[#out + 1] = extract .. " | pandoc -f html -t gfm-raw_html --wrap=none 2>/dev/null"
	end
	if have("xmllint") and have("w3m") then
		out[#out + 1] = extract .. " | w3m -dump -T text/html 2>/dev/null"
	end
	if have("w3m") then
		out[#out + 1] = "w3m -dump " .. shq(path)
	end
	return out
end

-- Asynchronous: a rustdoc page took about a second to convert, and doing it
-- with systemlist froze the editor for that whole time.
local function to_markdown(path, cb)
	local cmds, i = pipelines(path), 0
	local function try()
		i = i + 1
		if not cmds[i] then
			return cb({})
		end
		vim.system({ "sh", "-c", cmds[i] }, { text = true, timeout = 30000 }, function(res)
			vim.schedule(function()
				local lines = vim.split(res.stdout or "", "\n")
				while #lines > 0 and lines[#lines]:match("^%s*$") do
					lines[#lines] = nil
				end
				if res.code == 0 and #lines > 0 then
					return cb(lines)
				end
				try() -- this pipeline produced nothing; fall back to the next
			end)
		end)
	end
	try()
end

-- `origin` is the window the search was started from. The render is async, so
-- without it the split lands wherever the user has moved to in the meantime
-- (including another tabpage).
local function show(path, lines, origin)
	if origin and vim.api.nvim_win_is_valid(origin) then
		if vim.api.nvim_win_get_tabpage(origin) ~= vim.api.nvim_get_current_tabpage() then
			return vim.notify("Rust docs ready for " .. vim.fs.basename(path) .. " (press <leader>K again here)", vim.log.levels.INFO)
		end
		vim.api.nvim_set_current_win(origin)
	end
	vim.cmd.vsplit({ mods = { split = "belowright" } })
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, buf)
	vim.bo[buf].buftype, vim.bo[buf].bufhidden = "nofile", "wipe"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].filetype = "markdown"
	vim.bo[buf].modifiable = false
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
	local dir = vim.fs.dirname(path)
	vim.keymap.set("n", "<leader>fe", function()
		require("oil").toggle_float(dir)
	end, { buffer = buf, desc = "Oil (this doc's directory)" })
end

local function open_doc(path)
	local origin = vim.api.nvim_get_current_win()
	to_markdown(path, function(lines)
		if not lines or #lines == 0 then
			return vim.notify("Could not render " .. vim.fs.basename(path), vim.log.levels.WARN)
		end
		show(path, lines, origin)
	end)
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
		-- Cached: the sysroot is fixed for the session, and this is the only
		-- blocking call left on this path.
		if vim.g.rust_sysroot == nil then
			vim.g.rust_sysroot = vim.fn.trim(vim.fn.system({ "rustc", "--print", "sysroot" }))
		end
		table.insert(candidates, 1, vim.g.rust_sysroot .. "/share/doc/rust/html")
	end
	local roots = {}
	for _, d in ipairs(candidates) do
		if vim.fn.isdirectory(d) == 1 then
			roots[#roots + 1] = shq(d) -- the fzf command runs under sh, not 'shell'
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
	if have("w3m") then
		opts.preview = XPATH:format("{}") .. " | w3m -dump -T text/html -cols $FZF_PREVIEW_COLUMNS"
	end
	require("fzf-lua").fzf_exec("fd --type f --extension html --absolute-path . " .. table.concat(roots, " "), opts)
end, { buffer = true, desc = "Search Rust docs" })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
	.. "silent! lua pcall(vim.keymap.del, 'n', '<leader>K', { buffer = 0 })"
