-- :Docs — a small documentation browser.
--   :Docs                 -> provider menu (fzf)
--   :Docs kernel | bcc    -> jump straight to a provider
--     • Linux Kernel -> version -> Browse Documentation (.rst -> Markdown)
--                                or API reference (16k+ kernel-doc symbols,
--                                extracted per-symbol with scripts/kernel-doc)
--     • BCC / QEMU / libbpf -> browse docs (+ examples) at latest (master)
-- Everything is fetched lazily and cached under stdpath("data")/docs, one
-- blobless+treeless sparse checkout per source/version. Files render in a
-- reused right vsplit: .rst via pandoc, .md as-is, code with its filetype.

local M = {}

local repo = "https://github.com/torvalds/linux"
local data_root = vim.fn.stdpath("data") .. "/docs"
local cache_root = data_root .. "/linux"
local tags_cache = cache_root .. "/tags.txt"

local viewer_win -- reused doc-viewer window handle
local viewer_seq = 0 -- for unique scratch buffer names

local function fzf()
	return require("fzf-lua")
end

local function have(bin)
	return vim.fn.executable(bin) == 1
end

-- ── render lines in a reused right vsplit with the given filetype ─────────
local function render_lines(lines, ft, dir, title)
	if not lines or #lines == 0 then
		return vim.notify("Nothing to render", vim.log.levels.WARN)
	end

	-- Reuse the tracked viewer window if still valid, else recover it by tag,
	-- else open a new split.
	local win = viewer_win
	if not (win and vim.api.nvim_win_is_valid(win)) then
		win = nil
		for _, w in ipairs(vim.api.nvim_list_wins()) do
			if vim.w[w].docs_viewer then
				win = w
				break
			end
		end
	end
	if win then
		vim.api.nvim_set_current_win(win)
	else
		vim.cmd("rightbelow vsplit")
		win = vim.api.nvim_get_current_win()
	end
	viewer_win = win
	vim.w[win].docs_viewer = true

	-- Scratch buffer: buftype=nofile, noswapfile, nomodeline, unlisted are the
	-- defaults for nvim_create_buf(false, true); only bufhidden needs override.
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.api.nvim_win_set_buf(win, buf)
	viewer_seq = viewer_seq + 1
	pcall(vim.api.nvim_buf_set_name, buf, string.format("docs://%d/%s", viewer_seq, title or "doc"))
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Prose-friendly window-local viewport (wrap only for prose, not code).
	local prose = ft == nil or ft == "" or ft == "markdown" or ft == "rst"
	local wo = {
		number = false,
		relativenumber = false,
		signcolumn = "no",
		foldcolumn = "0",
		foldenable = false,
		list = false,
		cursorline = true,
		wrap = prose,
		linebreak = prose,
	}
	for k, v in pairs(wo) do
		vim.api.nvim_set_option_value(k, v, { scope = "local", win = win })
	end

	-- filetype last, while `win` is current, so ftplugin setlocal stays scoped.
	vim.bo[buf].filetype = ft or "markdown"
	vim.bo[buf].modifiable = false

	vim.keymap.set("n", "q", function()
		pcall(vim.api.nvim_win_close, 0, true)
	end, { buffer = buf, nowait = true, silent = true, desc = "Close docs viewer" })
	if dir then
		vim.keymap.set("n", "<leader>fe", function()
			require("oil").toggle_float(dir)
		end, { buffer = buf, desc = "Oil (this doc's directory)" })
	end
end

-- ── render a doc or source file, by extension ────────────────────────────
--   .rst -> pandoc to Markdown (raw rst as `rst` if pandoc is missing);
--   .md -> as-is; anything else (code examples) -> raw with detected filetype.
local function open_file(path)
	local ext = (path:match("%.([%w]+)$") or ""):lower()
	local lines, ft
	if ext == "rst" and have("pandoc") then
		lines = vim.fn.systemlist({ "pandoc", "-f", "rst", "-t", "gfm-raw_html", "--wrap=none", path })
		ft = "markdown"
	end
	if not lines or #lines == 0 then
		lines = vim.fn.filereadable(path) == 1 and vim.fn.readfile(path) or {}
		if ext == "md" or ext == "markdown" then
			ft = "markdown"
		elseif ext == "rst" then
			ft = "rst"
		else
			ft = vim.filetype.match({ filename = path, contents = lines }) or ""
		end
	end
	render_lines(lines, ft, vim.fs.dirname(path), vim.fs.basename(path))
end

-- ── extract one kernel-doc symbol and render it (async) ──────────────────
local function open_api(dir, name, file)
	local cmd = string.format(
		"cd %s && perl scripts/kernel-doc -rst -function %s %s 2>/dev/null "
			.. "| pandoc -f rst -t gfm-raw_html --wrap=none 2>/dev/null",
		vim.fn.shellescape(dir),
		vim.fn.shellescape(name),
		vim.fn.shellescape(file)
	)
	vim.system({ "sh", "-c", cmd }, { text = true, timeout = 15000 }, function(res)
		vim.schedule(function()
			local out = vim.split(res.stdout or "", "\n", { trimempty = true })
			if #out == 0 then
				return vim.notify("kernel-doc: nothing for " .. name .. "\n" .. (res.stderr or ""), vim.log.levels.WARN)
			end
			render_lines(out, "markdown", dir, name)
		end)
	end)
end

-- ── fuzzy-browse doc/source files under a directory ──────────────────────
local function pick_files(dir, fd_args, prompt)
	if not have("fd") then
		return vim.notify("fd not found (needed to browse docs)", vim.log.levels.WARN)
	end
	-- --base-directory guarantees the search root (fzf-lua's cwd isn't applied
	-- to the raw command); cwd lets the builtin previewer resolve the entries.
	fzf().fzf_exec("fd --base-directory " .. vim.fn.shellescape(dir) .. " --type f " .. fd_args, {
		prompt = prompt,
		cwd = dir,
		previewer = "builtin",
		fzf_opts = { ["--no-multi"] = true },
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
		fzf_opts = { ["--delimiter"] = "\t", ["--with-nth"] = "1..2", ["--no-multi"] = true },
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
		"git -c core.autocrlf=false clone -n --depth=1 --filter=tree:0 --branch "
			.. vim.fn.shellescape(version) .. " " .. repo .. " " .. vim.fn.shellescape(dir),
		"cd " .. vim.fn.shellescape(dir),
		"git sparse-checkout set --no-cone /Documentation",
		"git checkout",
	}, " && ")
	vim.system({ "sh", "-c", script }, { text = true, timeout = 180000 }, function(res)
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
		vim.system(
			{ "sh", "-c", string.format(API_BUILD, vim.fn.shellescape(dir)) },
			{ text = true, timeout = 600000 },
			function(res)
				vim.schedule(function()
					if res.code == 0 and vim.fn.filereadable(index) == 1 then
						cb(dir)
					else
						vim.notify("API index build failed:\n" .. (res.stderr or ""):sub(1, 400), vim.log.levels.ERROR)
					end
				end)
			end
		)
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
	vim.system({ "sh", "-c", cmd }, { text = true, timeout = 30000 }, function(res)
		local list = vim.split(res.stdout or "", "\n", { trimempty = true })
		vim.schedule(function()
			if #list == 0 then
				return vim.notify("Could not list kernel versions:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
			end
			vim.fn.writefile(list, tags_cache)
			cb(list)
		end)
	end)
end

local function kernel_menu(version)
	fzf().fzf_exec({ "Browse Documentation", "API reference" }, {
		prompt = version .. "> ",
		fzf_opts = { ["--no-multi"] = true },
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
	if not have("git") then
		return vim.notify("git not found (needed to fetch kernel docs)", vim.log.levels.WARN)
	end
	with_versions(function(list)
		fzf().fzf_exec(list, {
			prompt = "Kernel version> ",
			fzf_opts = { ["--no-multi"] = true },
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

-- ── simple providers: sparse-clone a repo's docs at latest (master) ──────
-- Lazily sparse-clone `sparse` paths of `url` into `dir`; cb(dir) once the
-- `marker` subdir exists.
local function ensure_repo(dir, url, sparse, marker, cb)
	if vim.fn.isdirectory(dir .. "/" .. marker) == 1 then
		return cb(dir)
	end
	vim.fn.mkdir(vim.fs.dirname(dir), "p")
	vim.notify("Cloning " .. vim.fs.basename(vim.fs.dirname(dir)) .. " docs … (first time only)")
	local script = table.concat({
		"rm -rf " .. vim.fn.shellescape(dir),
		"git -c core.autocrlf=false clone -n --depth=1 --filter=tree:0 " .. url .. " " .. vim.fn.shellescape(dir),
		"cd " .. vim.fn.shellescape(dir),
		"git sparse-checkout set --no-cone " .. sparse,
		"git checkout",
	}, " && ")
	vim.system({ "sh", "-c", script }, { text = true, timeout = 180000 }, function(res)
		vim.schedule(function()
			if res.code == 0 and vim.fn.isdirectory(dir .. "/" .. marker) == 1 then
				cb(dir)
			else
				vim.notify("Clone failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
			end
		end)
	end)
end

-- name -> { url, sparse (checkout paths), marker (dir proving success),
--          browse (subdir to fuzzy-browse, "" = whole clone), exts, prompt }
local simple = {
	bcc = {
		url = "https://github.com/iovisor/bcc",
		sparse = "/docs /examples",
		marker = "examples",
		browse = "",
		exts = "-e md -e rst -e py -e c -e cc -e h -e lua -e txt",
		prompt = "BCC> ",
	},
	qemu = {
		url = "https://github.com/qemu/qemu",
		sparse = "/docs",
		marker = "docs",
		browse = "/docs",
		exts = "-e rst -e md -e txt",
		prompt = "QEMU> ",
	},
	libbpf = {
		url = "https://github.com/libbpf/libbpf",
		sparse = "/docs",
		marker = "docs",
		browse = "/docs",
		exts = "-e rst -e md -e txt",
		prompt = "libbpf> ",
	},
	drgn = {
		url = "https://github.com/osandov/drgn",
		sparse = "/docs",
		marker = "docs",
		browse = "/docs",
		exts = "-e rst -e md -e py -e txt",
		prompt = "drgn> ",
	},
}

local function make_simple(name, spec)
	return function()
		if not have("git") then
			return vim.notify("git not found (needed to fetch " .. name .. " docs)", vim.log.levels.WARN)
		end
		ensure_repo(data_root .. "/" .. name .. "/master", spec.url, spec.sparse, spec.marker, function(dir)
			pick_files(dir .. spec.browse, spec.exts, spec.prompt)
		end)
	end
end

-- ── providers + :Docs command ────────────────────────────────────────────
local providers = {
	{ name = "Linux Kernel", key = "kernel", run = pick_kernel_version },
	{ name = "BCC", key = "bcc", run = make_simple("bcc", simple.bcc) },
	{ name = "QEMU", key = "qemu", run = make_simple("qemu", simple.qemu) },
	{ name = "libbpf", key = "libbpf", run = make_simple("libbpf", simple.libbpf) },
	{ name = "drgn", key = "drgn", run = make_simple("drgn", simple.drgn) },
}

function M.open()
	local names = vim.tbl_map(function(p)
		return p.name
	end, providers)
	fzf().fzf_exec(names, {
		prompt = "Docs> ",
		fzf_opts = { ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				if not (sel and sel[1]) then
					return
				end
				for _, p in ipairs(providers) do
					if p.name == sel[1] then
						return p.run()
					end
				end
			end,
		},
	})
end

vim.api.nvim_create_user_command("Docs", function(o)
	local key = o.fargs[1]
	if not key then
		return M.open()
	end
	for _, p in ipairs(providers) do
		if p.key == key then
			return p.run()
		end
	end
	vim.notify("Docs: unknown provider '" .. key .. "'", vim.log.levels.ERROR)
end, {
	nargs = "?",
	desc = "Browse documentation",
	complete = function(arg_lead)
		return vim.tbl_filter(function(k)
			return vim.startswith(k, arg_lead)
		end, vim.tbl_map(function(p)
			return p.key
		end, providers))
	end,
})

return M
