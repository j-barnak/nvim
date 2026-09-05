-- Ergonomic, no-LSP source exploration for the projects :Docs already knows.
-- Shallow-clones a project's full source (separate from the tiny docs clone),
-- builds a ctags index once, scopes &tags per-buffer so <C-]>/<C-t> work, and
-- opens fzf-lua rooted there (files, and ctrl-g grep / ctrl-t symbol tags).
local M = {}

local data_root = vim.fn.stdpath("data") .. "/src"
local function fzf() return require("fzf-lua") end
local function have(b) return vim.fn.executable(b) == 1 end

local _universal -- cached: ctags flavour is fixed for the session
local function is_universal()
	if _universal == nil then
		_universal = (vim.fn.system({ "ctags", "--version" })):match("Universal Ctags") ~= nil
	end
	return _universal
end

local EXCLUDE = {
	".git", "node_modules", "target", "build", "dist", "out", "bin", "obj",
	"vendor", "third_party", "testdata", "corpus", ".venv", "venv", "__pycache__",
}

-- cwd = repo root, so ctags writes "." -relative paths; the tag file lives at
-- the root and Neovim resolves those against it ('tagrelative'). `excl` adds
-- per-repo excludes (e.g. the kernel's non-native arches / Documentation).
local function ctags_argv(tagfile, excl)
	local uni = is_universal()
	local extra = uni and "--extras=+q" or "--extra=+q" -- Exuberant uses the singular flag
	local langs = uni
		and "C,C++,C#,Python,Go,Rust,Java,JavaScript,TypeScript,Lua,Ruby,Sh"
		or "C,C++,C#,Python,Go,Java,JavaScript,Lua,Ruby,Sh"
	local argv = { "ctags", extra, "--fields=+n", "--languages=" .. langs, "--sort=yes" }
	for _, p in ipairs(EXCLUDE) do
		argv[#argv + 1] = "--exclude=" .. p
	end
	for _, p in ipairs(excl or {}) do
		argv[#argv + 1] = "--exclude=" .. p
	end
	vim.list_extend(argv, { "-R", "-f", tagfile, "." })
	return argv
end

-- 'tags' is global-local; set it buffer-local for files under this repo, and
-- give those buffers an instant, index-free `gd` (ripgrep for the symbol's
-- definition) that works before ctags finishes. <C-]> uses ctags once ready.
local function scope_tags(dir, tagfile)
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = vim.api.nvim_create_augroup("SrcTags:" .. dir, { clear = true }),
		pattern = dir .. "/*",
		callback = function(ev)
			vim.bo[ev.buf].tags = tagfile
			vim.keymap.set("n", "gd", function()
				local w = vim.fn.expand("<cword>")
				fzf().grep({ cwd = dir, no_esc = true, search = "\\b" .. w .. "\\s*\\(", prompt = "def " .. w .. "> " })
			end, { buffer = ev.buf, silent = true, desc = "src: definitions (ripgrep)" })
		end,
	})
end

-- When a source file first shows in `win`, arm restore_fn to run when that
-- window later closes (:q), so exploring source in the docs split and then
-- quitting drops you back on the doc. One shared augroup (not per-window), so
-- a cancelled picker (no source file ever opened) leaves no lingering arm: the
-- next gs, or the reset below, clears it. Only one restore can be pending.
local function arm_restore(win, dir, restore_fn)
	local grp = vim.api.nvim_create_augroup("SrcBack", { clear = true })
	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = grp,
		pattern = dir .. "/*", -- only source files, so it doesn't fire session-wide
		callback = function(ev)
			local f = vim.api.nvim_buf_get_name(ev.buf)
			if f:sub(1, #dir) == dir and vim.api.nvim_get_current_win() == win then
				pcall(vim.api.nvim_del_augroup_by_id, grp)
				vim.api.nvim_create_autocmd("WinClosed", {
					-- A named group (cleared each arm) so a re-armed restore never
					-- leaves a stale one-shot handler behind.
					group = vim.api.nvim_create_augroup("SrcBackRestore", { clear = true }),
					pattern = tostring(win),
					once = true,
					callback = function() vim.schedule(restore_fn) end,
				})
			end
		end,
	})
end

local function open_picker(win, dir, tagfile, restore_fn)
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_current_win(win) -- selections open in the docs split
		-- Window-local cd: Neovim chdir's the process to it while this window is
		-- current, so the user's own cwd-based maps (<leader>ff files, <leader>fg
		-- grep) target the source. <leader>ft reads &tags, which scope_tags points
		-- at this repo's .srctags. So all three existing maps just work here.
		pcall(vim.cmd, "lcd " .. vim.fn.fnameescape(dir))
	end
	scope_tags(dir, tagfile)
	if restore_fn then
		arm_restore(win, dir, restore_fn)
	end
	fzf().files({ cwd = dir, prompt = vim.fs.basename(dir) .. " src> " })
end

-- Write to a temp file then rename in, so a <C-]> mid-build never reads a
-- half-written tag file (the kernel index takes ~30-60s in the background).
local function build_tags(dir, excl, cb)
	local tagfile = dir .. "/.srctags"
	local tmp = tagfile .. ".tmp"
	vim.notify("Indexing " .. vim.fs.basename(dir) .. " with ctags …")
	vim.system(ctags_argv(tmp, excl), { cwd = dir, text = true }, function(res)
		vim.schedule(function()
			if vim.fn.filereadable(tmp) == 1 then
				vim.uv.fs_rename(tmp, tagfile)
				cb(tagfile)
			else
				vim.notify("ctags failed:\n" .. (res.stderr or ""):sub(1, 300), vim.log.levels.ERROR)
			end
		end)
	end)
end

-- Clone only (no indexing): cb runs as soon as the source is on disk. Clone
-- into <dir>.tmp then rename, so a clone killed midway never leaves a partial
-- checkout that looks complete. Cache key is <dir>/.git.
local function ensure_clone(name, url, cb)
	local dir = data_root .. "/" .. name
	if vim.fn.isdirectory(dir .. "/.git") == 1 then
		return cb(dir)
	end
	vim.fn.mkdir(data_root, "p")
	vim.notify("Cloning " .. name .. " source (shallow, first time) …")
	local tmp = dir .. ".tmp"
	local script = table.concat({
		"rm -rf " .. vim.fn.shellescape(tmp) .. " " .. vim.fn.shellescape(dir),
		"git -c core.autocrlf=false clone --depth=1 --single-branch --no-tags " .. url .. " " .. vim.fn.shellescape(tmp),
		"mv " .. vim.fn.shellescape(tmp) .. " " .. vim.fn.shellescape(dir),
	}, " && ")
	vim.system({ "sh", "-c", script }, { text = true, timeout = 900000 }, function(res)
		vim.schedule(function()
			if res.code ~= 0 or vim.fn.isdirectory(dir .. "/.git") == 0 then
				return vim.notify("Source clone failed:\n" .. (res.stderr or ""):sub(1, 300), vim.log.levels.ERROR)
			end
			cb(dir)
		end)
	end)
end

-- Open in the current (docs) window; restore_fn re-renders the doc on :q.
-- The picker opens IMMEDIATELY (fd files + ripgrep are instant even on the
-- kernel); ctags indexes in the background and <C-]> lights up when ready.
function M.open(name, url, restore_fn, excl)
	if not (have("git") and have("ctags")) then
		return vim.notify("git and ctags are needed for source exploration", vim.log.levels.WARN)
	end
	local win = vim.api.nvim_get_current_win()
	ensure_clone(name, url, function(dir)
		local tagfile = dir .. "/.srctags"
		open_picker(win, dir, tagfile, restore_fn)
		if vim.fn.filereadable(tagfile) == 0 then
			build_tags(dir, excl, function()
				vim.notify("ctags index ready: " .. vim.fs.basename(dir))
			end)
		end
	end)
end

function M.reindex(name, excl)
	local dir = data_root .. "/" .. name
	if vim.fn.isdirectory(dir) == 1 then
		build_tags(dir, excl, function() vim.notify("reindexed " .. name) end)
	end
end

return M
