-- Ergonomic, no-LSP source exploration for the projects :Docs already knows.
-- Shallow-clones a project's full source (separate from the tiny docs clone),
-- builds a ctags index once, scopes &tags per-buffer so <C-]>/<C-t> work, and
-- opens fzf-lua rooted there (files, and ctrl-g grep / ctrl-t symbol tags).
local M = {}

local data_root = vim.fn.stdpath("data") .. "/src"
local function fzf() return require("fzf-lua") end
local function have(b) return vim.fn.executable(b) == 1 end

local function is_universal()
	return (vim.fn.system({ "ctags", "--version" })):match("Universal Ctags") ~= nil
end

local EXCLUDE = {
	".git", "node_modules", "target", "build", "dist", "out", "bin", "obj",
	"vendor", "third_party", "testdata", "corpus", ".venv", "venv", "__pycache__",
}

-- cwd = repo root, so ctags writes "." -relative paths; the tag file lives at
-- the root and Neovim resolves those against it ('tagrelative').
local function ctags_argv(tagfile)
	local uni = is_universal()
	local extra = uni and "--extras=+q" or "--extra=+q" -- Exuberant uses the singular flag
	local langs = uni
		and "C,C++,C#,Python,Go,Rust,Java,JavaScript,TypeScript,Lua,Ruby,Sh"
		or "C,C++,C#,Python,Go,Java,JavaScript,Lua,Ruby,Sh"
	local argv = { "ctags", extra, "--fields=+n", "--languages=" .. langs, "--sort=yes" }
	for _, p in ipairs(EXCLUDE) do
		argv[#argv + 1] = "--exclude=" .. p
	end
	vim.list_extend(argv, { "-R", "-f", tagfile, "." })
	return argv
end

-- 'tags' is global-local; set it buffer-local only for files under this repo.
local function scope_tags(dir, tagfile)
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = vim.api.nvim_create_augroup("SrcTags:" .. dir, { clear = true }),
		pattern = dir .. "/*",
		callback = function(ev)
			vim.bo[ev.buf].tags = tagfile
		end,
	})
end

local function open_picker(dir, tagfile)
	scope_tags(dir, tagfile)
	fzf().files({
		cwd = dir,
		prompt = vim.fs.basename(dir) .. " src> ",
		actions = {
			["ctrl-g"] = function() fzf().live_grep({ cwd = dir }) end,
			["ctrl-t"] = function() fzf().tags({ cwd = dir, ctags_file = tagfile }) end,
		},
	})
end

local function build_tags(dir, cb)
	local tagfile = dir .. "/.srctags"
	vim.notify("Indexing " .. vim.fs.basename(dir) .. " with ctags …")
	vim.system(ctags_argv(tagfile), { cwd = dir, text = true }, function(res)
		vim.schedule(function()
			if vim.fn.filereadable(tagfile) == 1 then
				cb(tagfile)
			else
				vim.notify("ctags failed:\n" .. (res.stderr or ""):sub(1, 300), vim.log.levels.ERROR)
			end
		end)
	end)
end

local function ensure_src(name, url, cb)
	local dir = data_root .. "/" .. name
	local tagfile = dir .. "/.srctags"
	if vim.fn.isdirectory(dir) == 1 then
		if vim.fn.filereadable(tagfile) == 1 then
			return cb(dir, tagfile)
		end
		return build_tags(dir, function(tf) cb(dir, tf) end)
	end
	vim.fn.mkdir(data_root, "p")
	vim.notify("Cloning " .. name .. " source (shallow, first time) …")
	vim.system({ "git", "-c", "core.autocrlf=false", "clone", "--depth=1", url, dir }, { text = true, timeout = 600000 }, function(res)
		vim.schedule(function()
			if res.code ~= 0 or vim.fn.isdirectory(dir) == 0 then
				return vim.notify("Source clone failed:\n" .. (res.stderr or ""):sub(1, 300), vim.log.levels.ERROR)
			end
			build_tags(dir, function(tf) cb(dir, tf) end)
		end)
	end)
end

function M.open(name, url)
	if not (have("git") and have("ctags")) then
		return vim.notify("git and ctags are needed for source exploration", vim.log.levels.WARN)
	end
	ensure_src(name, url, open_picker)
end

function M.reindex(name)
	local dir = data_root .. "/" .. name
	if vim.fn.isdirectory(dir) == 1 then
		build_tags(dir, function() vim.notify("reindexed " .. name) end)
	end
end

return M
