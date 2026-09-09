-- Ergonomic, no-LSP source exploration for the projects :Docs already knows.
-- Shallow-clones a project's full source (separate from the tiny docs clone),
-- builds a ctags index once, scopes &tags per-buffer so <C-]>/<C-t> work, and
-- opens fzf-lua rooted there (files, and ctrl-g grep / ctrl-t symbol tags).
local M = {}

local data_root = vim.fn.stdpath("data") .. "/src"
local util = require("config.util")
local fzf, have, shq = util.fzf, util.have, util.shq -- shq: POSIX quoting, the clone script runs under `sh -c`

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
-- `restore_fn` (when source was entered from a doc via gs) also binds `D` in
-- every source buffer, so the reader can jump straight back to the doc they
-- came from without hunting for the docs window or :q-ing out.
local function scope_tags(dir, tagfile, restore_fn)
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = vim.api.nvim_create_augroup("SrcTags:" .. dir, { clear = true }),
		pattern = dir .. "/*",
		callback = function(ev)
			vim.bo[ev.buf].tags = tagfile
			vim.keymap.set("n", "gd", function()
				local w = vim.fn.expand("<cword>")
				fzf().grep({ cwd = dir, no_esc = true, search = "\\b" .. w .. "\\s*\\(", prompt = "def " .. w .. "> " })
			end, { buffer = ev.buf, silent = true, desc = "src: definitions (ripgrep)" })
			if restore_fn then
				vim.keymap.set("n", "D", function() vim.schedule(restore_fn) end,
					{ buffer = ev.buf, silent = true, desc = "src: back to documentation" })
			end
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
	scope_tags(dir, tagfile, restore_fn)
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
	-- 10 min cap: the kernel index is the slow case (~30-60s), so a wedged ctags
	-- would otherwise never fire the callback and the "Indexing …" notice would
	-- hang forever. A timeout SIGKILLs the child, which surfaces as res.code ~= 0.
	vim.system(ctags_argv(tmp, excl), { cwd = dir, text = true, timeout = 600000 }, function(res)
		vim.schedule(function()
			-- Require a clean exit, not merely a readable temp file: a ctags that
			-- died partway (killed, disk full, timeout) leaves a truncated index,
			-- and promoting it to .srctags would cache a half-built tag file that
			-- <C-]> then searches silently. Drop the partial so the next gs retries.
			if res.code == 0 and vim.fn.filereadable(tmp) == 1 then
				vim.uv.fs_rename(tmp, tagfile)
				cb(tagfile)
			else
				pcall(vim.fn.delete, tmp)
				vim.notify("ctags failed:\n" .. (res.stderr or ""):sub(1, 300), vim.log.levels.ERROR)
			end
		end)
	end)
end

-- Clone only (no indexing): cb runs as soon as the source is on disk. Clone
-- into <dir>.tmp then rename, so a clone killed midway never leaves a partial
-- checkout that looks complete. Cache key is <dir>/.git.
-- `ref` (optional) is a tag or branch to check out, and `name` may contain a
-- slash, so a versioned project keeps one tree per version (the kernel: docs
-- are already per-version, and source that disagreed with the docs you are
-- reading is worse than no source at all).
local function ensure_clone(name, url, cb, ref, sub, sparse)
	local dir = data_root .. "/" .. name
	if vim.fn.isdirectory(dir .. "/.git") == 1 then
		return cb(dir)
	end
	-- A versioned name ("linux/v6.12", "unicorn/v2.1.4") whose PARENT is itself an
	-- old flat clone from before this provider was versioned: creating the new tree
	-- inside that working tree would nest one git repo in another and silently
	-- double the disk. A small stale clone (a transitioned provider like unicorn,
	-- tens of MB) is removed automatically so the per-version tree just works; only
	-- a LARGE tree (a multi-GB kernel checkout) still refuses with instructions,
	-- since silently deleting gigabytes is the surprise worth avoiding.
	local parent = vim.fs.dirname(dir)
	if parent ~= data_root and vim.fn.isdirectory(parent .. "/.git") == 1 then
		local mb = tonumber((vim.fn.system({ "du", "-sm", parent }) or ""):match("^(%d+)"))
		if not mb or mb > 1024 then -- unknown size or > 1 GB: too big to delete silently
			return vim.notify(
				("Src: %s is a large old unversioned clone. Remove it to use per-version trees:\n  rm -rf %s")
					:format(parent, parent),
				vim.log.levels.ERROR
			)
		end
		vim.notify(("Src: replacing old unversioned %s clone (%d MB) with per-version trees …")
			:format(vim.fs.basename(parent), mb))
		vim.fn.delete(parent, "rf")
	end
	-- Guarded: vim.fn.mkdir raises, so an unwritable data dir turned gs into
	-- an E739 traceback instead of a message. Make the PARENT, not data_root,
	-- so a "<project>/<version>" name does not fail on the missing middle dir.
	if vim.fn.isdirectory(parent) == 0 and not pcall(vim.fn.mkdir, parent, "p") then
		return vim.notify("Src: cannot create " .. parent, vim.log.levels.ERROR)
	end
	vim.notify("Cloning " .. name .. " source (shallow, first time) …")
	local tmp = dir .. ".tmp"
	local steps
	if sparse and sparse ~= "" then
		-- Scoped source: some projects (LibAFL) have dozens of crates but the
		-- reader only wants the handful the book's Crate List names, plus the
		-- example fuzzers. Blobless + --no-cone sparse-checkout materializes only
		-- those paths, so ctags/gs index just them and the clone stays small.
		local paths = table.concat(vim.tbl_map(shq, vim.split(sparse, " ", { trimempty = true })), " ")
		steps = {
			"rm -rf " .. shq(tmp) .. " " .. shq(dir),
			"git -c core.autocrlf=false clone -n --depth=1 --single-branch --no-tags --filter=blob:none "
				.. (ref and ("--branch " .. shq(ref) .. " ") or "")
				.. shq(url) .. " " .. shq(tmp),
			"git -C " .. shq(tmp) .. " sparse-checkout set --no-cone " .. paths,
			"git -C " .. shq(tmp) .. " checkout",
		}
		if sub then -- init only the submodules that live under a checked-out path
			steps[#steps + 1] = "git -C " .. shq(tmp) .. " submodule update --init --recursive --depth 1"
		end
		steps[#steps + 1] = "mv " .. shq(tmp) .. " " .. shq(dir)
	else
		steps = {
			"rm -rf " .. shq(tmp) .. " " .. shq(dir),
			-- `sub` recurses git submodules (AFL++ vendors qemuafl/unicornafl/… as
			-- submodules; without this they come down as empty gitlink placeholders).
			-- --shallow-submodules keeps each submodule a depth-1 clone.
			"git -c core.autocrlf=false clone --depth=1 --single-branch --no-tags "
				.. (sub and "--recurse-submodules --shallow-submodules " or "")
				.. (ref and ("--branch " .. shq(ref) .. " ") or "")
				.. shq(url) .. " " .. shq(tmp),
			"mv " .. shq(tmp) .. " " .. shq(dir),
		}
	end
	local script = table.concat(steps, " && ")
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
function M.open(name, url, restore_fn, excl, ref, sub, sparse)
	if not (have("git") and have("ctags")) then
		return vim.notify("git and ctags are needed for source exploration", vim.log.levels.WARN)
	end
	local win = vim.api.nvim_get_current_win()
	ensure_clone(name, url, function(dir)
		local tagfile = dir .. "/.srctags"
		-- (ref is consumed by ensure_clone; the tree on disk is already at it)
		open_picker(win, dir, tagfile, restore_fn)
		if vim.fn.filereadable(tagfile) == 0 then
			build_tags(dir, excl, function()
				vim.notify("ctags index ready: " .. vim.fs.basename(dir))
			end)
		end
	end, ref, sub, sparse)
end

return M
