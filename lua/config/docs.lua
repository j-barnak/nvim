-- :Docs — a small documentation browser.
--   :Docs -> provider menu ->
--     • Linux Kernel -> version -> Browse Documentation (.rst -> Markdown)
--                                or API reference (16k+ kernel-doc symbols,
--                                extracted per-symbol with scripts/kernel-doc)
--     • BCC          -> browse docs + examples at latest (master)
-- Everything is fetched lazily and cached under stdpath("cache")/docs, one
-- blobless+treeless sparse checkout per source/version. Files render in a
-- right vsplit: .rst via pandoc, .md as-is, code examples with their filetype.

local M = {}

local repo = "https://github.com/torvalds/linux"
local cache_root = vim.fn.stdpath("cache") .. "/docs/linux"
local tags_cache = cache_root .. "/tags.txt"

local function fzf()
	return require("fzf-lua")
end

-- ── render lines in a right vsplit with the given filetype ───────────────
local function render_lines(lines, ft, dir)
	if not lines or #lines == 0 then
		return vim.notify("Nothing to render", vim.log.levels.WARN)
	end
	vim.cmd("rightbelow vsplit")
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, buf)
	vim.bo[buf].buftype, vim.bo[buf].bufhidden = "nofile", "wipe"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	-- ft after the split is current window so a filetype's window-local options
	-- don't leak onto the previous window.
	vim.bo[buf].filetype = ft or "markdown"
	vim.bo[buf].modifiable = false
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
	if dir then
		vim.keymap.set("n", "<leader>fe", function()
			require("oil").toggle_float(dir)
		end, { buffer = buf, desc = "Oil (this doc's directory)" })
	end
end

-- ── render a doc or source file, by extension ────────────────────────────
--   .rst -> pandoc to Markdown; .md -> shown as-is; anything else (code
--   examples) -> shown raw with its detected filetype for syntax highlighting.
local function open_file(path)
	local ext = (path:match("%.([%w]+)$") or ""):lower()
	local lines, ft
	if ext == "rst" and vim.fn.executable("pandoc") == 1 then
		lines = vim.fn.systemlist({ "pandoc", "-f", "rst", "-t", "gfm-raw_html", "--wrap=none", path })
		ft = "markdown"
	end
	if not lines or #lines == 0 then
		lines = vim.fn.filereadable(path) == 1 and vim.fn.readfile(path) or {}
		if ext == "md" or ext == "markdown" or ext == "rst" then
			ft = "markdown"
		else
			ft = vim.filetype.match({ filename = path }) or ""
		end
	end
	render_lines(lines, ft, vim.fs.dirname(path))
end

-- ── extract one kernel-doc symbol and render it ──────────────────────────
local function open_api(dir, name, file)
	local cmd = string.format(
		"cd %s && perl scripts/kernel-doc -rst -function %s %s 2>/dev/null "
			.. "| pandoc -f rst -t gfm-raw_html --wrap=none 2>/dev/null",
		vim.fn.shellescape(dir),
		vim.fn.shellescape(name),
		vim.fn.shellescape(file)
	)
	local res = vim.system({ "sh", "-c", cmd }, { text = true }):wait()
	render_lines(vim.split(res.stdout or "", "\n", { trimempty = true }), "markdown", dir)
end

-- ── fuzzy-browse doc/source files under a directory ──────────────────────
local function pick_files(dir, fd_args, prompt)
	fzf().fzf_exec("fd --base-directory " .. vim.fn.shellescape(dir) .. " --type f " .. fd_args, {
		prompt = prompt,
		actions = {
			["default"] = function(sel)
				if sel and sel[1] then
					open_file(dir .. "/" .. sel[1])
				end
			end,
		},
	})
end

local function api_search(dir)
	fzf().fzf_exec("cat " .. vim.fn.shellescape(dir .. "/api-index.tsv"), {
		prompt = "Kernel API> ",
		fzf_opts = { ["--delimiter"] = "\t", ["--with-nth"] = "1..2" },
		actions = {
			["default"] = function(sel)
				if sel and sel[1] then
					local name, file = sel[1]:match("^(.-)\t(.+)$")
					if name and file then
						open_api(dir, name, file)
					end
				end
			end,
		},
	})
end

-- ── lazy sparse-clone: Documentation only ────────────────────────────────
local function ensure_docs(version, cb)
	local dir = cache_root .. "/" .. version
	local docdir = dir .. "/Documentation"
	if vim.fn.isdirectory(docdir) == 1 then
		return cb(dir, docdir)
	end
	vim.fn.mkdir(cache_root, "p")
	vim.notify("Cloning kernel Documentation @ " .. version .. " … (first time only)")
	local script = table.concat({
		"rm -rf " .. vim.fn.shellescape(dir),
		"git clone -n --depth=1 --filter=tree:0 --branch " .. vim.fn.shellescape(version) .. " " .. repo .. " " .. vim.fn.shellescape(dir),
		"cd " .. vim.fn.shellescape(dir),
		"git sparse-checkout set --no-cone /Documentation",
		"git checkout",
	}, " && ")
	vim.system({ "sh", "-c", script }, { text = true }, function(res)
		vim.schedule(function()
			if res.code == 0 and vim.fn.isdirectory(docdir) == 1 then
				cb(dir, docdir)
			else
				vim.notify("Clone failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
			end
		end)
	end)
end

-- ── lazy: add scripts/ + referenced sources, build the API symbol index ──
local API_BUILD = [[
set -e
cd %s
grep -rhoE '^\.\. kernel-doc:: \S+' Documentation --include='*.rst' | awk '{print $3}' | sort -u > .kd_files.txt
git sparse-checkout add /scripts
sed 's|^|/|' .kd_files.txt | xargs -d '\n' git sparse-checkout add
git checkout
python3 - "$PWD" <<'PY'
import re, os, sys
root = sys.argv[1]
out = open(os.path.join(root, "api-index.tsv"), "w")
hdr = re.compile(r'\s*\*\s*(?:(?:struct|union|enum|typedef)\s+)?([A-Za-z_]\w*)\s*(?:\(\))?\s*[-:]')
for rel in open(os.path.join(root, ".kd_files.txt")):
    rel = rel.strip(); p = os.path.join(root, rel)
    try:
        lines = open(p, encoding="utf-8", errors="replace").read().splitlines()
    except OSError:
        continue
    for i, l in enumerate(lines):
        if l.strip() == "/**" and i + 1 < len(lines):
            nxt = lines[i + 1]
            if "DOC:" in nxt:
                continue
            m = hdr.match(nxt)
            if m:
                out.write(m.group(1) + "\t" + rel + "\n")
out.close()
PY
]]

local function ensure_api(version, cb)
	ensure_docs(version, function(dir, _)
		local index = dir .. "/api-index.tsv"
		if vim.fn.filereadable(index) == 1 then
			return cb(dir)
		end
		vim.notify("Fetching kernel API sources @ " .. version .. " … (first time, ~1-2 min)")
		vim.system({ "sh", "-c", string.format(API_BUILD, vim.fn.shellescape(dir)) }, { text = true }, function(res)
			vim.schedule(function()
				if res.code == 0 and vim.fn.filereadable(index) == 1 then
					cb(dir)
				else
					vim.notify("API index build failed:\n" .. (res.stderr or ""):sub(1, 400), vim.log.levels.ERROR)
				end
			end)
		end)
	end)
end

-- ── version submenu (cached release-tag list) ────────────────────────────
local function with_versions(cb)
	if vim.fn.filereadable(tags_cache) == 1 then
		return cb(vim.fn.readfile(tags_cache))
	end
	vim.fn.mkdir(cache_root, "p")
	vim.notify("Fetching kernel versions …")
	local cmd = "git ls-remote --tags --refs " .. repo .. " | grep -oE 'v[0-9]+\\.[0-9]+(\\.[0-9]+)?$' | sort -Vr"
	vim.system({ "sh", "-c", cmd }, { text = true }, function(res)
		local list = vim.split(res.stdout or "", "\n", { trimempty = true })
		if #list > 0 then
			vim.fn.writefile(list, tags_cache)
		end
		vim.schedule(function()
			cb(list)
		end)
	end)
end

local function kernel_menu(version)
	fzf().fzf_exec({ "Browse Documentation", "API reference" }, {
		prompt = version .. "> ",
		actions = {
			["default"] = function(sel)
				if not (sel and sel[1]) then
					return
				end
				if sel[1] == "API reference" then
					ensure_api(version, api_search)
				else
					ensure_docs(version, function(_, docdir)
						pick_files(docdir, "--extension rst", "Kernel docs> ")
					end)
				end
			end,
		},
	})
end

local function pick_kernel_version()
	with_versions(function(list)
		if #list == 0 then
			return vim.notify("Could not list kernel versions", vim.log.levels.ERROR)
		end
		fzf().fzf_exec(list, {
			prompt = "Kernel version> ",
			actions = {
				["default"] = function(sel)
					if sel and sel[1] then
						kernel_menu(sel[1])
					end
				end,
			},
		})
	end)
end

-- ── BCC (iovisor/bcc): docs + examples, latest (master) ──────────────────
local bcc_root = vim.fn.stdpath("cache") .. "/docs/bcc"

local function ensure_bcc(cb)
	local dir = bcc_root .. "/master"
	if vim.fn.isdirectory(dir .. "/examples") == 1 then
		return cb(dir)
	end
	vim.fn.mkdir(bcc_root, "p")
	vim.notify("Cloning BCC docs + examples … (first time only)")
	local script = table.concat({
		"rm -rf " .. vim.fn.shellescape(dir),
		"git clone -n --depth=1 --filter=tree:0 https://github.com/iovisor/bcc " .. vim.fn.shellescape(dir),
		"cd " .. vim.fn.shellescape(dir),
		"git sparse-checkout set --no-cone /docs /examples",
		"git checkout",
	}, " && ")
	vim.system({ "sh", "-c", script }, { text = true }, function(res)
		vim.schedule(function()
			if res.code == 0 and vim.fn.isdirectory(dir .. "/examples") == 1 then
				cb(dir)
			else
				vim.notify("BCC clone failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
			end
		end)
	end)
end

local function pick_bcc()
	ensure_bcc(function(dir)
		pick_files(dir, "-e md -e rst -e py -e c -e cc -e h -e lua -e txt", "BCC> ")
	end)
end

-- ── top-level :Docs provider menu ────────────────────────────────────────
local providers = {
	["Linux Kernel"] = pick_kernel_version,
	["BCC"] = pick_bcc,
}

function M.open()
	local names = vim.tbl_keys(providers)
	table.sort(names)
	fzf().fzf_exec(names, {
		prompt = "Docs> ",
		actions = {
			["default"] = function(sel)
				if sel and sel[1] and providers[sel[1]] then
					providers[sel[1]]()
				end
			end,
		},
	})
end

vim.api.nvim_create_user_command("Docs", M.open, { desc = "Browse documentation" })

return M
