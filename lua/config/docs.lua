-- :Docs (a small documentation browser).
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

-- ── figure viewer: show an extracted SDM diagram inline (snacks.image) ────
-- snacks renders PNG natively via the kitty graphics protocol (works over
-- SSH+tmux with allow-passthrough), no ImageMagick needed. Opening the PNG
-- in a float lets snacks' image hijack render it. Falls back to xdg-open.
local fig_win -- floating window currently showing a figure
local function clear_figure()
	if fig_win and vim.api.nvim_win_is_valid(fig_win) then
		pcall(vim.api.nvim_win_close, fig_win, true)
	end
	fig_win = nil
end

local function show_figure(png)
	local ok, snacks = pcall(require, "snacks")
	if ok and snacks.image and snacks.image.supports_file(png) and snacks.image.supports_terminal() then
		clear_figure()
		local cols, rows = vim.o.columns, vim.o.lines
		local W = math.max(40, math.floor(cols * 0.62))
		local H = math.max(10, math.floor((rows - 4) * 0.9))
		local win = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
			relative = "editor",
			width = W,
			height = H,
			row = math.floor((rows - H) / 2 - 1),
			col = math.floor((cols - W) / 2),
			style = "minimal",
			border = "rounded",
			title = " " .. vim.fs.basename(png):gsub("%.png$", "") .. "  (q closes) ",
		})
		fig_win = win
		-- Open the image file in the float; snacks' BufReadCmd hijack renders it.
		vim.api.nvim_win_call(win, function()
			vim.cmd("edit " .. vim.fn.fnameescape(png))
			local b = vim.api.nvim_get_current_buf()
			vim.bo[b].bufhidden = "wipe"
			for _, k in ipairs({ "q", "<Esc>" }) do
				vim.keymap.set("n", k, clear_figure, { buffer = b, nowait = true, silent = true })
			end
		end)
		return
	end
	if have("xdg-open") then
		vim.system({ "xdg-open", png })
		return vim.notify("Opened " .. vim.fs.basename(png) .. " externally", vim.log.levels.INFO)
	end
	vim.notify("Figure image at " .. png, vim.log.levels.INFO)
end

-- On a line that names a figure ("Figure 4-8" / "see Figure 5-9"), show the
-- diagram cropped from the PDF during the SDM build (docs_dir/figures/).
local function open_figure_under_cursor()
	local dir = vim.b.docs_dir
	if not dir then
		return
	end
	local id = vim.api.nvim_get_current_line():match("[Ff]igure%s+([%dA-Z]+%-%w+)")
	if not id then
		return
	end
	local png = dir .. "/figures/Figure " .. id .. ".png"
	if vim.fn.filereadable(png) == 0 then
		return vim.notify("No image for Figure " .. id, vim.log.levels.WARN)
	end
	show_figure(png)
end

-- ── table of contents: fuzzy-jump the current doc's headings (<leader>fs) ─
-- Handles markdown ("## Heading") and Intel SDM numbered sections
-- ("4.1   PAGING MODES AND CONTROL BITS": section number, 2+ spaces, title;
-- inline refs like "4.10 provides ..." use a single space and are excluded).
local function docs_toc()
	local win = vim.api.nvim_get_current_win()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local entries = {}
	for i, L in ipairs(lines) do
		local title, depth
		local hashes, htext = L:match("^(#+)%s+(.+)$")
		if hashes then
			depth, title = #hashes, htext
		else
			local num, sect = L:match("^([%dA-Z][%d.]*%.%d[%d.]*)%s%s+([%u%d].*)$")
			if num then
				depth = select(2, num:gsub("%.", "")) + 1
				title = num .. "  " .. sect
			elseif L:match("^%u[%u][%u &/,()'-]*$") then
				depth, title = 1, L -- man-page section header (NAME, SEE ALSO, …)
			end
		end
		if title then
			title = title:gsub("%s+$", "")
			entries[#entries + 1] = string.format("%d\t%s%s", i, string.rep("  ", depth - 1), title)
		end
	end
	if #entries == 0 then
		return vim.notify("No headings found in this document", vim.log.levels.INFO)
	end
	fzf().fzf_exec(entries, {
		prompt = "TOC> ",
		fzf_opts = { ["--with-nth"] = "2..", ["--delimiter"] = "\\t", ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				local lnum = sel and sel[1] and tonumber(sel[1]:match("^(%d+)"))
				if lnum and vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_set_current_win(win)
					vim.api.nvim_win_set_cursor(win, { lnum, 0 })
					vim.cmd("normal! zz")
				end
			end,
		},
	})
end

local follow_link -- forward declaration; assigned after open_file is defined

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
	vim.keymap.set("n", "<leader>fs", docs_toc, { buffer = buf, desc = "Docs: table of contents" })
	if ft == "man" then
		-- gd follows the cross-reference under the cursor (e.g. gd on `read`
		-- opens read's man page), matching gd = "follow link" in the other docs.
		vim.keymap.set("n", "gd", function()
			vim.cmd("Man " .. vim.fn.expand("<cword>"))
		end, { buffer = buf, nowait = true, silent = true, desc = "Docs: follow man cross-reference" })
	end
	if dir then
		vim.b[buf].docs_dir = dir
		vim.keymap.set("n", "gd", function()
			follow_link()
		end, { buffer = buf, nowait = true, silent = true, desc = "Docs: follow link under cursor" })
		vim.keymap.set("n", "<leader>fe", function()
			require("oil").toggle_float(dir)
		end, { buffer = buf, desc = "Oil (this doc's directory)" })
		-- SDM chapters carry extracted diagrams: <CR> on a "Figure N-M" line
		-- shows the cropped image inline.
		if dir:match("/sdm/vol%d") then
			vim.keymap.set("n", "<CR>", open_figure_under_cursor, { buffer = buf, nowait = true, silent = true, desc = "Show figure under cursor" })
		end
	end
end

-- Drop a leading YAML front-matter block (MS Learn, Jekyll, Sphinx docs),
-- which is metadata noise when reading a page.
local function strip_frontmatter(lines)
	if lines[1] == "---" then
		for i = 2, math.min(#lines, 80) do
			if lines[i] == "---" then
				return vim.list_slice(lines, i + 1)
			end
		end
	end
	return lines
end

-- Turn Jekyll/Liquid tags into plain Markdown (Frida's docs use these):
-- {% highlight LANG %}..{% endhighlight %} -> fenced code; drop other lone tags.
local function strip_liquid(lines)
	for i, l in ipairs(lines) do
		local lang = l:match("^%s*{%%%s*highlight%s+(%S+)%s*%%}%s*$")
		if lang then
			lines[i] = "```" .. lang
		elseif l:match("^%s*{%%%s*endhighlight%s*%%}%s*$") then
			lines[i] = "```"
		elseif l:match("^%s*{%%.-%%}%s*$") then
			lines[i] = ""
		else
			-- Drop trailing {#anchor} / {: attrs} (Doxygen/moxygen/kramdown) noise.
			lines[i] = l:gsub("%s*{[#:][^}]*}%s*$", "")
		end
	end
	return lines
end

-- Rewrite relative Markdown image links to absolute paths so snacks.image can
-- find them: the doc renders in a scratch buffer with no real file path.
local function abs_images(lines, dir)
	if not dir then
		return lines
	end
	for i, l in ipairs(lines) do
		lines[i] = l:gsub("(!%[[^%]]*%]%()([^)%s]+)(%))", function(pre, url, post)
			if url:match("^%a[%w+.-]*://") or url:match("^/") then
				return pre .. url .. post
			end
			return pre .. vim.fs.normalize(dir .. "/" .. (url:gsub("^%./", ""))) .. post
		end)
	end
	return lines
end

-- ── render a doc or source file, by extension ────────────────────────────
--   .rst -> pandoc to Markdown (raw rst as `rst` if pandoc is missing);
--   .md -> as-is; anything else (code examples) -> raw with detected filetype.
local function open_file(path)
	local ext = (path:match("%.([%w]+)$") or ""):lower()
	local lines, ft
	-- .rst via pandoc rst, .xml via pandoc DocBook (OpenGL refpages), .html via
	-- pandoc HTML (Ghidra CheatSheet, doxygen pages).
	if have("pandoc") and (ext == "rst" or ext == "xml" or ext == "html" or ext == "htm") then
		local from = ext == "xml" and "docbook" or ((ext == "html" or ext == "htm") and "html") or "rst"
		lines = vim.fn.systemlist({ "pandoc", "-f", from, "-t", "gfm-raw_html", "--wrap=none", path })
		ft = "markdown"
	end
	if not lines or #lines == 0 then
		lines = vim.fn.filereadable(path) == 1 and vim.fn.readfile(path) or {}
		if ext == "md" or ext == "markdown" or ext == "pandoc" then
			ft = "markdown"
		elseif ext == "rst" then
			ft = "rst"
		else
			ft = vim.filetype.match({ filename = path, contents = lines }) or ""
		end
	end
	local dir = vim.fs.dirname(path)
	if ft == "markdown" then
		lines = abs_images(strip_liquid(strip_frontmatter(lines)), dir)
	end
	render_lines(lines, ft, dir, vim.fs.basename(path))
end

-- gd: follow the Markdown/rst link under the cursor to another doc in this set.
follow_link = function()
	local dir = vim.b.docs_dir
	if not dir then
		return
	end
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local pick, first
	local s = 1
	while true do
		local a, b, url = line:find("%[[^%]]*%]%(([^)]+)%)", s)
		if not a then
			break
		end
		first = first or url
		if col >= a - 1 and col <= b then
			pick = url
			break
		end
		s = b + 1
	end
	local url = pick or first
	if not url then
		return vim.notify("No link on this line", vim.log.levels.INFO)
	end
	if url:match("^%a[%w+.-]*://") then
		return vim.notify("External link: " .. url, vim.log.levels.INFO)
	end
	url = url:gsub("%s.*$", ""):gsub("#.*$", "") -- drop title/anchor
	if url == "" then
		return
	end
	local base = vim.fs.normalize(dir .. "/" .. url:gsub("^%./", ""))
	-- Wiki links often omit the extension ([SDL_Event](SDL_Event) -> SDL_Event.md).
	local path
	for _, cand in ipairs({ base, base .. ".md", base .. ".markdown", base .. ".rst", base .. ".txt", base .. ".html" }) do
		if vim.fn.filereadable(cand) == 1 then
			path = cand
			break
		end
	end
	if not path then
		-- case-insensitive fallback within the target's directory
		local d, want = vim.fs.dirname(base), vim.fs.basename(base):lower()
		pcall(function()
			for name, t in vim.fs.dir(d) do
				if t == "file" and (name:lower() == want or name:gsub("%.[%w]+$", ""):lower() == want) then
					path = d .. "/" .. name
					return
				end
			end
		end)
	end
	if path then
		open_file(path)
	else
		vim.notify("Link target not found: " .. url, vim.log.levels.WARN)
	end
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
		-- /docs is thin sphinx autodoc; the real API is the header comments in /src.
		url = "https://github.com/libbpf/libbpf",
		sparse = "/docs /src",
		marker = "docs",
		browse = "",
		exts = "-e rst -e md -e txt -e h",
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
	sdl2 = {
		url = "https://github.com/libsdl-org/sdlwiki",
		sparse = "/SDL2",
		marker = "SDL2",
		browse = "/SDL2",
		exts = "-e md",
		prompt = "SDL2> ",
	},
	sdl3 = {
		url = "https://github.com/libsdl-org/sdlwiki",
		sparse = "/SDL3",
		marker = "SDL3",
		browse = "/SDL3",
		exts = "-e md",
		prompt = "SDL3> ",
	},
	opengl = {
		url = "https://github.com/KhronosGroup/OpenGL-Refpages",
		sparse = "/gl4",
		marker = "gl4",
		browse = "/gl4",
		exts = "-e xml",
		prompt = "OpenGL> ",
	},
	aflpp = {
		url = "https://github.com/AFLplusplus/AFLplusplus",
		sparse = "/docs /utils /custom_mutators",
		marker = "docs",
		browse = "",
		exts = "-e md -e rst -e c -e cpp -e h -e py -e txt",
		prompt = "AFL++> ",
	},
	python = {
		url = "https://github.com/python/cpython",
		sparse = "/Doc",
		marker = "Doc",
		browse = "/Doc/library",
		exts = "-e rst",
		prompt = "Python> ",
	},
	llvm = {
		url = "https://github.com/llvm/llvm-project",
		sparse = "/llvm/docs",
		marker = "llvm/docs",
		browse = "/llvm/docs",
		exts = "-e rst -e md",
		prompt = "LLVM> ",
	},
	xen = {
		url = "https://github.com/xen-project/xen",
		sparse = "/docs",
		marker = "docs",
		browse = "/docs",
		exts = "-e rst -e md -e pandoc -e txt",
		prompt = "Xen> ",
	},
	-- reverse-engineering / binary-analysis / fuzzing tooling
	frida = {
		-- /_docs are Jekyll "{% tf %}" wrappers; the real prose is in _i18n/en.
		url = "https://github.com/frida/frida-website",
		sparse = "/_i18n/en/_docs",
		marker = "_i18n/en/_docs",
		browse = "/_i18n/en/_docs",
		exts = "-e md",
		prompt = "Frida> ",
	},
	triton = {
		-- Triton has no in-repo prose docs; its C++ API headers (doxygen comments) are the reference.
		url = "https://github.com/JonathanSalwan/Triton",
		sparse = "/src",
		marker = "src",
		browse = "/src/libtriton/includes",
		exts = "-e hpp -e h",
		prompt = "Triton (C++ API)> ",
	},
	angr = {
		url = "https://github.com/angr/angr",
		sparse = "/docs",
		marker = "docs",
		browse = "/docs",
		exts = "-e rst -e md",
		prompt = "angr> ",
	},
	qbdi = {
		url = "https://github.com/QBDI/QBDI",
		sparse = "/docs /examples",
		marker = "docs",
		browse = "",
		exts = "-e rst -e md -e cpp -e c -e py -e txt",
		prompt = "QBDI> ",
	},
	capstone = {
		url = "https://github.com/capstone-engine/capstone",
		sparse = "/docs /include",
		marker = "docs",
		browse = "",
		exts = "-e md -e rst -e txt -e h",
		prompt = "Capstone> ",
	},
	binja = {
		url = "https://github.com/Vector35/binaryninja-api",
		sparse = "/docs /examples",
		marker = "docs",
		browse = "",
		exts = "-e md -e rst -e py -e cpp -e txt",
		prompt = "Binary Ninja> ",
	},
	lief = {
		url = "https://github.com/lief-project/LIEF",
		sparse = "/doc /examples",
		marker = "doc",
		browse = "",
		exts = "-e rst -e md -e py -e cpp -e txt",
		prompt = "LIEF> ",
	},
	pyelftools = {
		url = "https://github.com/eliben/pyelftools",
		sparse = "/doc /examples /scripts",
		marker = "doc",
		browse = "",
		exts = "-e rst -e md -e py -e txt",
		prompt = "pyelftools> ",
	},
	qbindiff = {
		url = "https://github.com/quarkslab/qbindiff",
		sparse = "/doc",
		marker = "doc",
		browse = "/doc",
		exts = "-e rst -e md -e py -e txt",
		prompt = "QBinDiff> ",
	},
	qiling = {
		url = "https://github.com/qilingframework/qiling",
		sparse = "/docs /examples",
		marker = "docs",
		browse = "",
		exts = "-e md -e rst -e py -e txt",
		prompt = "Qiling> ",
	},
	panda = {
		-- /docs is QEMU-inherited; PANDA's own docs live in /panda/docs.
		url = "https://github.com/panda-re/panda",
		sparse = "/panda/docs",
		marker = "panda/docs",
		browse = "/panda/docs",
		exts = "-e md -e rst -e txt",
		prompt = "PANDA> ",
	},
	volatility = {
		url = "https://github.com/volatilityfoundation/volatility3",
		sparse = "/doc",
		marker = "doc",
		browse = "/doc",
		exts = "-e rst -e md -e txt",
		prompt = "Volatility> ",
	},
	syzkaller = {
		url = "https://github.com/google/syzkaller",
		sparse = "/docs",
		marker = "docs",
		browse = "/docs",
		exts = "-e md -e txt",
		prompt = "syzkaller> ",
	},
	unicorn = {
		url = "https://github.com/unicorn-engine/unicorn",
		sparse = "/docs /samples",
		marker = "docs",
		browse = "",
		exts = "-e md -e rst -e txt -e c -e py",
		prompt = "Unicorn> ",
	},
	keystone = {
		-- include/keystone/keystone.h is the actual API; bindings/samples show use.
		url = "https://github.com/keystone-engine/keystone",
		sparse = "/docs /samples /include /bindings",
		marker = "docs",
		browse = "",
		exts = "-e md -e rst -e txt -e c -e py -e h",
		prompt = "Keystone> ",
	},
	android = {
		-- In-depth Android systems docs: bionic (libc + dynamic linker), the
		-- C API headers, ELF-TLS/ABI/fortify notes. (Framework/SDK is web-only.)
		url = "https://github.com/aosp-mirror/platform_bionic",
		sparse = "/docs /libc/include /linker",
		marker = "docs",
		browse = "",
		exts = "-e md -e h",
		prompt = "Android (bionic)> ",
	},
	pwntools = {
		url = "https://github.com/Gallopsled/pwntools",
		sparse = "/docs /examples",
		marker = "docs",
		browse = "",
		exts = "-e rst -e md -e py -e txt",
		prompt = "pwntools> ",
	},
	uefi = {
		-- MdePkg/Include is the UEFI/PI API (protocols, services, types).
		url = "https://github.com/tianocore/edk2",
		sparse = "/MdePkg",
		marker = "MdePkg",
		browse = "/MdePkg/Include",
		exts = "-e h -e md",
		prompt = "UEFI (edk2 MdePkg)> ",
	},
	coreboot = {
		url = "https://github.com/coreboot/coreboot",
		sparse = "/Documentation",
		marker = "Documentation",
		browse = "/Documentation",
		exts = "-e md -e rst -e txt",
		prompt = "coreboot> ",
	},
	uboot = {
		url = "https://github.com/u-boot/u-boot",
		sparse = "/doc",
		marker = "doc",
		browse = "/doc",
		exts = "-e rst -e md -e txt",
		prompt = "U-Boot> ",
	},
	nyx = {
		url = "https://github.com/nyx-fuzz/Nyx",
		sparse = "/docs",
		marker = "docs",
		browse = "/docs",
		exts = "-e md -e rst -e txt",
		prompt = "Nyx> ",
	},
	libafl = {
		-- The LibAFL Book (docs/src) plus the example fuzzers.
		url = "https://github.com/AFLplusplus/LibAFL",
		sparse = "/docs/src /fuzzers",
		marker = "docs/src",
		browse = "",
		exts = "-e md -e rs -e txt",
		prompt = "LibAFL> ",
	},
	-- DynamoRIO: open-source dynamic binary instrumentation (Intel Pin alternative)
	dynamorio = {
		url = "https://github.com/DynamoRIO/dynamorio",
		sparse = "/api",
		marker = "api",
		browse = "/api",
		exts = "-e dox -e md -e c -e cpp -e h -e txt",
		prompt = "DynamoRIO> ",
	},
	codeql = {
		url = "https://github.com/github/codeql",
		sparse = "/docs",
		marker = "docs",
		browse = "/docs",
		exts = "-e md -e rst -e txt -e ql -e qll",
		prompt = "CodeQL> ",
	},
	pe = {
		-- The PE/COFF format spec (and related debug docs) from MS Learn source.
		url = "https://github.com/MicrosoftDocs/win32",
		sparse = "/desktop-src/Debug",
		marker = "desktop-src/Debug",
		browse = "/desktop-src/Debug",
		exts = "-e md",
		prompt = "PE format> ",
	},
	bpftrace = {
		url = "https://github.com/bpftrace/bpftrace",
		sparse = "/docs /man",
		marker = "docs",
		browse = "",
		exts = "-e md -e rst -e txt",
		prompt = "bpftrace> ",
	},
	ebpf = {
		url = "https://github.com/isovalent/ebpf-docs",
		sparse = "/docs",
		marker = "docs",
		browse = "/docs",
		exts = "-e md",
		prompt = "eBPF> ",
	},
	lld = {
		url = "https://github.com/llvm/llvm-project",
		sparse = "/lld/docs",
		marker = "lld/docs",
		browse = "/lld/docs",
		exts = "-e rst -e md",
		prompt = "lld (LLVM linker)> ",
	},
	lldb = {
		url = "https://github.com/llvm/llvm-project",
		sparse = "/lldb/docs",
		marker = "lldb/docs",
		browse = "/lldb/docs",
		exts = "-e rst -e md",
		prompt = "lldb> ",
	},
	macho = {
		-- The Mach-O format definition: XNU's own mach-o headers.
		url = "https://github.com/apple-oss-distributions/xnu",
		sparse = "/EXTERNAL_HEADERS/mach-o",
		marker = "EXTERNAL_HEADERS/mach-o",
		browse = "/EXTERNAL_HEADERS/mach-o",
		exts = "-e h",
		prompt = "Mach-O> ",
	},
	winsdk = {
		url = "https://github.com/MicrosoftDocs/sdk-api",
		sparse = "/sdk-api-src",
		marker = "sdk-api-src",
		browse = "/sdk-api-src",
		exts = "-e md",
		prompt = "Win32 API> ",
	},
	windriver = {
		url = "https://github.com/MicrosoftDocs/windows-driver-docs",
		sparse = "/windows-driver-docs-pr",
		marker = "windows-driver-docs-pr",
		browse = "/windows-driver-docs-pr",
		exts = "-e md",
		prompt = "Windows Driver> ",
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

-- ── doxygen providers: doxygen (XML) -> moxygen -> per-class/group Markdown ─
-- For libraries whose API lives in Doxygen-commented C/C++ headers (libdrgn,
-- SFML). Downloads a prebuilt doxygen binary on first use; moxygen (npm) turns
-- the XML into cross-linked per-class/per-group Markdown, browsed like the rest.
local tools_dir = data_root .. "/.tools"
local DOX_PIPELINE = [[
set -e
INPUT="$1"; OUT="$2"; TOOLS="$3"; PATTERNS="$4"
DOXY=$(ls "$TOOLS"/doxygen-*/bin/doxygen 2>/dev/null | head -1)
if [ -z "$DOXY" ]; then
  mkdir -p "$TOOLS"
  ( cd "$TOOLS" && curl -fsSL https://www.doxygen.nl/files/doxygen-1.14.0.linux.bin.tar.gz -o d.tgz && tar xzf d.tgz && rm -f d.tgz )
  DOXY=$(ls "$TOOLS"/doxygen-*/bin/doxygen 2>/dev/null | head -1)
fi
XML="$OUT/.xml"; rm -rf "$XML"; mkdir -p "$XML" "$OUT"
{
  echo "INPUT = $INPUT"
  echo "FILE_PATTERNS = $PATTERNS"
  echo "RECURSIVE = YES"
  echo "GENERATE_HTML = NO"
  echo "GENERATE_XML = YES"
  echo "XML_OUTPUT = $XML"
  echo "XML_PROGRAMLISTING = NO"
  echo "EXTRACT_ALL = YES"
  echo "QUIET = YES"
  echo "WARN_IF_UNDOCUMENTED = NO"
} > "$XML/Doxyfile"
"$DOXY" "$XML/Doxyfile" >/dev/null 2>&1
moxygen --classes --groups --anchors --output "$OUT/%s.md" "$XML" >/dev/null 2>&1
]]

local function pick_doxygen(name, url, sparse, input, patterns)
	if not have("git") then
		return vim.notify("git not found", vim.log.levels.WARN)
	end
	if vim.fn.executable("moxygen") == 0 then
		return vim.notify("moxygen not found (run: npm install -g moxygen)", vim.log.levels.WARN)
	end
	local marker = sparse:gsub("^/", ""):gsub(" .*", "")
	ensure_repo(data_root .. "/" .. name .. "/master", url, sparse, marker, function(dir)
		local md = dir .. "/.dox"
		local function browse()
			pick_files(md, "-e md", name .. "> ")
		end
		if #vim.fn.glob(md .. "/*.md", false, true) > 0 then
			return browse()
		end
		vim.notify("Building " .. name .. " API (doxygen + moxygen) … first time, ~1-2 min")
		vim.system(
			{ "sh", "-c", DOX_PIPELINE, "dox", dir .. input, md, tools_dir, patterns },
			{ text = true, timeout = 300000 },
			function(res)
				vim.schedule(function()
					if #vim.fn.glob(md .. "/*.md", false, true) > 0 then
						browse()
					else
						vim.notify("Doxygen build failed:\n" .. (res.stderr or ""):sub(1, 400), vim.log.levels.ERROR)
					end
				end)
			end
		)
	end)
end

-- ── Intel SDM figure extraction (stdlib Python; written to disk by pick_sdm) ─
-- SDM diagrams are vector art with selectable text labels, so a figure is the
-- band between its caption and the nearest full-width paragraph above it. We
-- find that band from `pdftotext -bbox-layout`, render just that region with
-- pdftoppm, and trim to a tight PNG named after the figure ("Figure 4-8.png").
local FIGEXTRACT_PY = [==[
import sys, os, re, subprocess
import xml.etree.ElementTree as ET

PDF, OUTDIR = sys.argv[1], sys.argv[2]
DPI = 300  # crisp enough to zoom; figures are cached under stdpath("data")
SCALE = DPI / 72.0
os.makedirs(OUTDIR, exist_ok=True)

raw = subprocess.run(["pdftotext", "-bbox-layout", PDF, "-"],
                     capture_output=True, text=True).stdout
raw = re.sub(r'<!DOCTYPE[^>]*>', '', raw)
raw = re.sub(r'\sxmlns="[^"]*"', '', raw, count=1)
root = ET.fromstring(raw)

FIG_RE = re.compile(r'^Figure\s+([0-9A-Z]+-[0-9A-Z]+)\.', re.I)

def block_text(b):
    return " ".join((w.text or "") for w in b.iter("word")).strip()

def fget(el, attr):
    return float(el.get(attr))

count = 0
pagenum = 0
for page in root.iter("page"):
    pagenum += 1
    pw, ph = fget(page, "width"), fget(page, "height")
    blocks = list(page.iter("block"))
    if not blocks:
        continue
    blocks.sort(key=lambda b: fget(b, "yMin"))
    cl, cr = 45.0, pw - 45.0
    cw = cr - cl
    HEADER_Y, FOOTER_Y = 55.0, ph - 45.0

    def is_body(b):
        w = fget(b, "xMax") - fget(b, "xMin")
        return w >= 0.55 * cw and fget(b, "xMin") <= cl + 0.12 * cw

    CAP_RE = re.compile(r'^(Figure|Table)\s+[0-9A-Z]+-', re.I)

    for b in blocks:
        m = FIG_RE.match(block_text(b))
        if not m:
            continue
        fid = m.group(1)
        final = os.path.join(OUTDIR, "Figure " + fid + ".png")
        if os.path.exists(final):
            continue  # keep the first occurrence (main figure, not a "(Contd.)")
        cap_ymin, cap_ymax = fget(b, "yMin"), fget(b, "yMax")
        # Top boundary: the nearest body paragraph OR another figure/table
        # caption above (so stacked figures on one page don't merge).
        top = HEADER_Y
        for pb in blocks:
            if pb is b:
                continue
            pby = fget(pb, "yMax")
            if pby <= cap_ymin - 2 and pby > top and (is_body(pb) or CAP_RE.match(block_text(pb))):
                top = pby
        top += 3
        bottom = min(cap_ymax + 4, FOOTER_Y)
        if bottom - top < 30:
            continue
        xs0, xs1 = [], []
        for ib in blocks:
            if fget(ib, "yMin") >= top - 2 and fget(ib, "yMax") <= bottom + 2:
                xs0.append(fget(ib, "xMin")); xs1.append(fget(ib, "xMax"))
        left = max(cl, min(xs0) - 8) if xs0 else cl
        right = min(cr, max(xs1) + 8) if xs1 else cr
        x, y = int(left * SCALE), int(top * SCALE)
        w, h = int((right - left) * SCALE), int((bottom - top) * SCALE)
        if w <= 0 or h <= 0:
            continue
        out = os.path.join(OUTDIR, "Figure " + fid)
        subprocess.run(["pdftoppm", "-png", "-r", str(DPI), "-f", str(pagenum), "-l", str(pagenum),
                        "-x", str(x), "-y", str(y), "-W", str(w), "-H", str(h), PDF, out],
                       capture_output=True)
        produced = next((os.path.join(OUTDIR, f) for f in os.listdir(OUTDIR)
                         if f.startswith("Figure " + fid + "-") and f.endswith(".png")), None)
        if produced:
            final = os.path.join(OUTDIR, "Figure " + fid + ".png")
            if produced != final:
                os.replace(produced, final)
            subprocess.run(["convert", final, "-trim", "+repage",
                            "-bordercolor", "white", "-border", "14", final], capture_output=True)
            count += 1
print("figures:", count)
]==]

-- ── Intel SDM: download the PDF, split by chapter into text + figures ─────
-- The manuals aren't published as markdown, so fetch the latest PDF and
-- pdftotext -layout each chapter (page ranges from the PDF outline) into
-- per-chapter text files, stripping running headers/footers and form feeds.
-- Figures (vector diagrams) are then cropped to PNGs via FIGEXTRACT_PY so
-- <CR> on a "Figure N-M" line shows the diagram inline (snacks.image).
local SDM_BUILD = [[
set -e
PDF="$1"; OUT="$2"; URL="$3"; PY="$4"
if [ ! -f "$PDF" ]; then
  mkdir -p "$(dirname "$PDF")"
  curl -fsSL "$URL" -o "$PDF"
fi
mkdir -p "$OUT"
JS="$OUT/.ol.js"
cat > "$JS" <<EOF2
var doc = Document.openDocument("$PDF");
function pageof(it){ try { var l = doc.resolveLink(it.uri); return (typeof l==="number")?l:(l&&l.page); } catch(e){ return -1; } }
function walk(items,d){ for(var i=0;i<items.length;i++){ var it=items[i]; print(d+"\t"+(pageof(it)+1)+"\t"+it.title); if(it.down) walk(it.down,d+1); } }
walk(doc.loadOutline(),0);
EOF2
mutool run "$JS" > "$OUT/.all.tsv" 2>/dev/null
TOTAL=$(pdfinfo "$PDF" | awk '/^Pages:/{print $2}')
# Split at the shallowest outline depth with >= 5 entries (volumes differ).
D=$(awk -F'\t' '{c[$1]++} END{for(d=0;d<8;d++) if(c[d]>=5){print d; exit}}' "$OUT/.all.tsv")
idx=0; prev_p=""; prev_t=""
emit() {
  idx=$((idx+1)); n=$(printf '%03d' "$idx")
  f=$(printf '%s' "$3" | tr '/' '-' | cut -c1-80)
  hdr=$(printf '%s' "$3" | sed -E 's/^(Chapter|Appendix) [0-9A-Z]+ *//' | tr '[:lower:]' '[:upper:]')
  pdftotext -layout -f "$1" -l "$2" "$PDF" - 2>/dev/null \
    | sed 's/\f//g' \
    | awk -v h="$hdr" '{t=$0; gsub(/^[ \t]+|[ \t]+$/,"",t)} t ~ /^Vol\. [0-9A-D]+ +[0-9A-Z]+-[0-9]+$/{next} t ~ /^[0-9A-Z]+-[0-9]+ +Vol\. [0-9A-D]+$/{next} h!="" && toupper(t)==h{next} {print}' \
    | cat -s > "$OUT/$n $f.txt"
}
if [ -n "$D" ]; then
  awk -F'\t' -v D="$D" '$1==D{print $2"\t"$3}' "$OUT/.all.tsv" > "$OUT/.ch.tsv"
  while IFS="$(printf '\t')" read -r p t; do
    [ -n "$prev_p" ] && emit "$prev_p" $((p-1)) "$prev_t"
    prev_p="$p"; prev_t="$t"
  done < "$OUT/.ch.tsv"
  [ -n "$prev_p" ] && emit "$prev_p" "$TOTAL" "$prev_t"
else
  # No usable outline (e.g. Vol 4): fixed 40-page chunks.
  p=1
  while [ "$p" -le "$TOTAL" ]; do
    e=$((p+39)); [ "$e" -gt "$TOTAL" ] && e="$TOTAL"
    emit "$p" "$e" "pages $p-$e"
    p=$((e+1))
  done
fi
rm -f "$JS" "$OUT/.all.tsv" "$OUT/.ch.tsv"
# Extract figures as tight PNGs (diagrams are vector, so rasterize regions).
if [ -n "$PY" ] && command -v python3 >/dev/null 2>&1 \
   && command -v pdftoppm >/dev/null 2>&1 && command -v convert >/dev/null 2>&1; then
  python3 "$PY" "$PDF" "$OUT/figures" >/dev/null 2>&1 || true
fi
]]

local SDM = "https://www.intel.com/content/dam/www/public/us/en/documents/manuals/"
local SDM_URLS = {
	[1] = SDM .. "64-ia-32-architectures-software-developer-vol-1-manual.pdf",
	[2] = SDM .. "64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf",
	[3] = SDM .. "64-ia-32-architectures-software-developer-system-programming-manual-325384.pdf",
	[4] = "https://www.intel.com/content/dam/develop/external/us/en/documents/335592-sdm-vol-4.pdf",
}

local function pick_sdm(vol)
	for _, t in ipairs({ "curl", "mutool", "pdftotext", "pdfinfo" }) do
		if not have(t) then
			return vim.notify(t .. " needed for Intel SDM", vim.log.levels.WARN)
		end
	end
	local out = data_root .. "/sdm/vol" .. vol
	local pdf = tools_dir .. "/sdm-vol" .. vol .. ".pdf"
	local function browse()
		pick_files(out, "-e txt", "Intel SDM v" .. vol .. "> ")
	end
	if #vim.fn.glob(out .. "/*.txt", false, true) > 0 then
		return browse()
	end
	vim.fn.mkdir(out, "p")
	-- Drop the figure extractor next to the other downloaded tools.
	local py = tools_dir .. "/sdm-figextract.py"
	vim.fn.mkdir(tools_dir, "p")
	pcall(vim.fn.writefile, vim.split(FIGEXTRACT_PY, "\n"), py)
	vim.notify("Fetching + splitting Intel SDM Vol " .. vol .. " … (first time; figures take a minute)")
	vim.system(
		{ "sh", "-c", SDM_BUILD, "sdm", pdf, out, SDM_URLS[vol], py },
		{ text = true, timeout = 600000 },
		function(res)
			vim.schedule(function()
				if #vim.fn.glob(out .. "/*.txt", false, true) > 0 then
					browse()
				else
					vim.notify("SDM build failed:\n" .. (res.stderr or ""):sub(1, 400), vim.log.levels.ERROR)
				end
			end)
		end
	)
end

-- ── man pages + cppman: reference at your fingertips while writing C/C++ ──
-- Rendered with filetype=man, so Neovim highlights them AND `K` on any word
-- opens that word's man page (e.g. K over `read` on the open(2) page).
local function render_shell(cmd, title, ft)
	vim.system({ "sh", "-c", cmd }, { text = true }, function(res)
		vim.schedule(function()
			local out = vim.split(res.stdout or "", "\n")
			while #out > 0 and out[#out]:match("^%s*$") do
				out[#out] = nil
			end
			if #out == 0 then
				local err = res.stderr ~= "" and res.stderr or ("Nothing for " .. title)
				return vim.notify(err, vim.log.levels.WARN)
			end
			render_lines(out, ft or "man", nil, title)
		end)
	end)
end

-- Section 2 = system calls, 3 = C library functions.
local function pick_man(section)
	if not have("man") then
		return vim.notify("man not found", vim.log.levels.WARN)
	end
	local list = vim.fn.systemlist("apropos -s " .. section .. " . 2>/dev/null | sort -u")
	if #list == 0 then
		list = vim.fn.systemlist(
			"for d in $(manpath 2>/dev/null | tr ':' ' '); do ls \"$d/man"
				.. section
				.. "\" 2>/dev/null; done | sed 's/\\.[0-9].*$//' | sort -u"
		)
	end
	if #list == 0 then
		return vim.notify("No man pages found in section " .. section, vim.log.levels.WARN)
	end
	fzf().fzf_exec(list, {
		prompt = "man " .. section .. "> ",
		fzf_opts = { ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				local name = sel and sel[1] and sel[1]:match("^(%S+)")
				if name then
					render_shell(
						"MANWIDTH=90 man " .. section .. " " .. vim.fn.shellescape(name) .. " 2>/dev/null | col -bx",
						name .. "(" .. section .. ")"
					)
				end
			end,
		},
	})
end

-- cppman renders cppreference.com pages as man pages. It lives in a pipx
-- venv, so it may not be on Neovim's PATH (resolve the binary explicitly).
local function cppman_bin()
	if have("cppman") then
		return "cppman"
	end
	local p = vim.fn.expand("~/.local/bin/cppman")
	return vim.fn.executable(p) == 1 and p or nil
end

-- Full-symbol fuzzy list if cppman's index db is populated, else a prompt
-- (rendering a page by name works even when the index isn't built).
local function pick_cppman()
	local bin = cppman_bin()
	if not bin then
		return vim.notify("cppman not found (install with: pipx install cppman)", vim.log.levels.WARN)
	end
	local function render(sym)
		render_shell(bin .. " --force-columns=90 " .. vim.fn.shellescape(sym) .. " 2>/dev/null | col -bx", "cppman " .. sym, "man")
	end
	-- cppman's index is a SQLite db with one "<source>_keywords" table of
	-- searchable symbol names. Dump those for the picker (read-only).
	local db = vim.fn.expand("~/.cache/cppman/index.db")
	local names = {}
	if vim.fn.filereadable(db) == 1 and have("python3") then
		names = vim.fn.systemlist({
			"python3",
			"-c",
			"import sqlite3,sys\n"
				.. "c=sqlite3.connect('file:'+sys.argv[1]+'?mode=ro',uri=True)\n"
				.. "s=set()\n"
				.. "for tbl in [r[0] for r in c.execute(\"SELECT name FROM sqlite_master WHERE type='table'\")]:\n"
				.. "  if not tbl.endswith('_keywords'): continue\n"
				.. "  try:\n"
				.. "    for r in c.execute('SELECT keyword FROM \"%s\"' % tbl):\n"
				.. "      k=(r[0] or '').strip()\n"
				.. "      if len(k)>1 and not k.startswith('('): s.add(k)\n"
				.. "  except Exception: pass\n"
				.. "print('\\n'.join(sorted(s)))",
			db,
		})
	end
	if #names > 0 then
		fzf().fzf_exec(names, {
			prompt = "cppman> ",
			fzf_opts = { ["--no-multi"] = true },
			actions = {
				["default"] = function(sel)
					if sel and sel[1] then
						render(sel[1])
					end
				end,
			},
		})
	else
		vim.ui.input({ prompt = "cppman (C++ symbol, e.g. std::vector): " }, function(sym)
			if sym and sym ~= "" then
				render(sym)
			end
		end)
	end
end

-- ── NetBSD kernel (9) + driver (4) man pages ─────────────────────────────
-- NetBSD's section 9 (kernel internals) and 4 (device drivers) man pages are
-- the reason to reach for NetBSD. Sparse-clone just those two dirs from the
-- source tree and render the mdoc with the local man(1) (groff handles mdoc).
local function pick_nbsd(section)
	if not (have("git") and have("fd") and have("man")) then
		return vim.notify("git, fd and man are needed for NetBSD docs", vim.log.levels.WARN)
	end
	local dir = data_root .. "/netbsd"
	ensure_repo(dir, "https://github.com/NetBSD/src", "/share/man/man9 /share/man/man4", "share/man/man9", function(d)
		local mandir = d .. "/share/man/man" .. section
		fzf().fzf_exec("fd --base-directory " .. vim.fn.shellescape(mandir) .. " --type f .", {
			prompt = "NetBSD (" .. section .. ")> ",
			cwd = mandir,
			fzf_opts = { ["--no-multi"] = true },
			actions = {
				["default"] = function(sel)
					if sel and sel[1] then
						local f = mandir .. "/" .. sel[1]
						render_shell("MANWIDTH=90 man -l " .. vim.fn.shellescape(f) .. " 2>/dev/null | col -bx", vim.fs.basename(sel[1]), "man")
					end
				end,
			},
		})
	end)
end

-- ── Haskell: search Hoogle, render the result's docs ──────────────────────
local function html_to_text(s)
	s = (s or ""):gsub("<pre>", "\n"):gsub("</pre>", "\n")
	s = s:gsub("<h%d[^>]*>", "\n"):gsub("</h%d>", "\n")
	s = s:gsub("<li>", "\n- "):gsub("</?[ou]l>", "\n"):gsub("</p>", "\n\n")
	s = s:gsub("<[^>]+>", "")
	s = s:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&quot;", '"'):gsub("&#39;", "'"):gsub("&amp;", "&")
	return s
end

local function pick_haskell()
	if not have("curl") then
		return vim.notify("curl needed for Hoogle", vim.log.levels.WARN)
	end
	vim.ui.input({ prompt = "Hoogle search: " }, function(q)
		if not q or q == "" then
			return
		end
		local url = "https://hoogle.haskell.org/?hoogle=" .. vim.uri_encode(q) .. "&mode=json&count=100"
		vim.system({ "curl", "-sSL", url }, { text = true, timeout = 20000 }, function(res)
			vim.schedule(function()
				local ok, data = pcall(vim.json.decode, res.stdout or "")
				if not ok or type(data) ~= "table" or #data == 0 then
					return vim.notify("Hoogle: no results for " .. q, vim.log.levels.WARN)
				end
				local entries, by_idx = {}, {}
				for i, r in ipairs(data) do
					local sig = html_to_text(r.item or ""):gsub("%s+", " "):gsub("^%s+", "")
					local mod = r.module and r.module.name or ""
					local pkg = r.package and r.package.name or ""
					entries[#entries + 1] = string.format("%d\t%s  (%s, %s)", i, sig, mod, pkg)
					by_idx[i] = r
				end
				fzf().fzf_exec(entries, {
					prompt = "Hoogle> ",
					fzf_opts = { ["--with-nth"] = "2..", ["--delimiter"] = "\\t", ["--no-multi"] = true },
					actions = {
						["default"] = function(sel)
							local r = sel and sel[1] and by_idx[tonumber(sel[1]:match("^(%d+)"))]
							if not r then
								return
							end
							local out = { html_to_text(r.item or ""):gsub("^%s+", ""), "" }
							if r.module then
								out[#out + 1] = "Module:  " .. (r.module.name or "")
							end
							if r.package then
								out[#out + 1] = "Package: " .. (r.package.name or "")
							end
							if r.url then
								out[#out + 1] = r.url
							end
							out[#out + 1] = ""
							for _, l in ipairs(vim.split(html_to_text(r.docs or ""), "\n")) do
								out[#out + 1] = l
							end
							render_lines(out, "markdown", nil, "hoogle: " .. q)
						end,
					},
				})
			end)
		end)
	end)
end

-- ── OCaml: browse the stdlib module index, render a module's API ──────────
local OCAML_IDX = [[curl -sSL https://ocaml.org/api/index_modules.html | grep -oE 'href="[A-Z][A-Za-z0-9_]*\.html"' | sed -E 's/.*"([^"]+)\.html".*/\1/' | sort -u]]

local function pick_ocaml()
	if not (have("curl") and have("pandoc")) then
		return vim.notify("curl and pandoc are needed for OCaml docs", vim.log.levels.WARN)
	end
	local dir = data_root .. "/ocaml"
	local idxfile = dir .. "/modules.txt"
	local function browse()
		fzf().fzf_exec(vim.fn.readfile(idxfile), {
			prompt = "OCaml module> ",
			fzf_opts = { ["--no-multi"] = true },
			actions = {
				["default"] = function(sel)
					if sel and sel[1] then
						render_shell(
							"curl -sSL " .. vim.fn.shellescape("https://ocaml.org/api/" .. sel[1] .. ".html")
								.. " | pandoc -f html -t gfm-raw_html --wrap=none 2>/dev/null | awk 'f||/OCaml library/{f=1}f'",
							"OCaml." .. sel[1],
							"markdown"
						)
					end
				end,
			},
		})
	end
	if vim.fn.filereadable(idxfile) == 1 then
		return browse()
	end
	vim.fn.mkdir(dir, "p")
	vim.system({ "sh", "-c", OCAML_IDX }, { text = true, timeout = 20000 }, function(res)
		vim.schedule(function()
			local mods = vim.split(res.stdout or "", "\n", { trimempty = true })
			if #mods == 0 then
				return vim.notify("OCaml: could not fetch the module index", vim.log.levels.WARN)
			end
			vim.fn.writefile(mods, idxfile)
			browse()
		end)
	end)
end

-- ── Ghidra: versioned API/docs (pick a release tag, all versions) ────────
local function pick_ghidra()
	if not (have("git") and have("fd")) then
		return vim.notify("git and fd are needed for Ghidra docs", vim.log.levels.WARN)
	end
	local repo = "https://github.com/NationalSecurityAgency/ghidra"
	vim.system({ "sh", "-c", "git ls-remote --tags --refs " .. repo .. " | sed 's#.*refs/tags/##' | sort -rV" }, { text = true, timeout = 30000 }, function(res)
		vim.schedule(function()
			local tags = vim.split(res.stdout or "", "\n", { trimempty = true })
			if #tags == 0 then
				return vim.notify("Ghidra: could not list versions", vim.log.levels.WARN)
			end
			fzf().fzf_exec(tags, {
				prompt = "Ghidra version> ",
				fzf_opts = { ["--no-multi"] = true },
				actions = {
					["default"] = function(sel)
						if not (sel and sel[1]) then
							return
						end
						local tag = sel[1]
						local dir = data_root .. "/ghidra/" .. tag
						local marker = dir .. "/GhidraDocs"
						local function browse()
							-- GhidraDocs/languages is the SLEIGH manual (writing processor
							-- modules); the x86 language dir gives real .slaspec/.sinc examples.
							pick_files(dir, "-e md -e html -e txt -e slaspec -e sinc -e cspec -e ldefs -e pspec", "Ghidra " .. tag .. "> ")
						end
						if vim.fn.isdirectory(marker) == 1 then
							return browse()
						end
						vim.fn.mkdir(vim.fs.dirname(dir), "p")
						vim.notify("Cloning Ghidra " .. tag .. " docs … (first time)")
						local script = table.concat({
							"rm -rf " .. vim.fn.shellescape(dir),
							"git -c core.autocrlf=false clone -n --depth=1 --filter=tree:0 --branch " .. vim.fn.shellescape(tag) .. " " .. repo .. " " .. vim.fn.shellescape(dir),
							"cd " .. vim.fn.shellescape(dir),
							"git sparse-checkout set --no-cone /GhidraDocs /Ghidra/Processors/x86/data/languages",
							"git checkout",
						}, " && ")
						vim.system({ "sh", "-c", script }, { text = true, timeout = 180000 }, function(r2)
							vim.schedule(function()
								if vim.fn.isdirectory(marker) == 1 then
									browse()
								else
									vim.notify("Ghidra clone failed:\n" .. (r2.stderr or ""):sub(1, 300), vim.log.levels.ERROR)
								end
							end)
						end)
					end,
				},
			})
		end)
	end)
end

-- ── Multiboot / Multiboot2 boot protocol specs (GNU GRUB, rendered) ───────
local function pick_multiboot()
	if not (have("curl") and have("pandoc")) then
		return vim.notify("curl and pandoc are needed for the Multiboot specs", vim.log.levels.WARN)
	end
	local specs = {
		["Multiboot (v1)"] = "https://www.gnu.org/software/grub/manual/multiboot/multiboot.html",
		["Multiboot2"] = "https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html",
	}
	fzf().fzf_exec(vim.tbl_keys(specs), {
		prompt = "Multiboot> ",
		fzf_opts = { ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				if sel and sel[1] and specs[sel[1]] then
					render_shell("curl -sSL " .. vim.fn.shellescape(specs[sel[1]]) .. " | pandoc -f html -t gfm-raw_html --wrap=none 2>/dev/null", sel[1], "markdown")
				end
			end,
		},
	})
end

-- ── pydoc: docs for any installed Python package (pexpect, requests, …) ───
-- Lazily covers third-party packages that the cpython stdlib docs don't have.
local function pick_pydoc()
	if not have("python3") then
		return vim.notify("python3 needed for pydoc", vim.log.levels.WARN)
	end
	-- Fuzzy list of every importable top-level module (stdlib + site-packages,
	-- e.g. pexpect, requests, numpy) so third-party packages are discoverable.
	local mods = vim.fn.systemlist({
		"python3",
		"-c",
		"import pkgutil,sys; print(chr(10).join(sorted(set([m.name for m in pkgutil.iter_modules()] + list(sys.builtin_module_names)))))",
	})
	if #mods == 0 then
		return vim.notify("pydoc: could not list modules", vim.log.levels.WARN)
	end
	fzf().fzf_exec(mods, {
		prompt = "pydoc> ",
		fzf_opts = { ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				if sel and sel[1] then
					render_shell("python3 -m pydoc " .. vim.fn.shellescape(sel[1]) .. " 2>&1", "pydoc " .. sel[1], "text")
				end
			end,
		},
	})
end

-- ── update: git-pull every cached doc repo to the most recent ────────────
local function update_all()
	if not have("git") then
		return vim.notify("git not found", vim.log.levels.WARN)
	end
	local repos = {}
	local function scan(glob)
		for _, d in ipairs(vim.fn.glob(glob, false, true)) do
			if vim.fn.isdirectory(d .. "/.git") == 1 then
				repos[#repos + 1] = d
			end
		end
	end
	scan(data_root .. "/*/master") -- simple providers
	scan(data_root .. "/*") -- netbsd and any flat clones
	scan(data_root .. "/linux/*") -- kernel versions
	scan(data_root .. "/ghidra/*") -- ghidra tags
	if #repos == 0 then
		return vim.notify("No cached doc repos to update yet", vim.log.levels.INFO)
	end
	vim.notify("Updating " .. #repos .. " cached doc repos … (git pull)")
	local done, failed = 0, {}
	for _, d in ipairs(repos) do
		vim.system({ "git", "-C", d, "pull", "--ff-only" }, { text = true, timeout = 180000 }, function(res)
			vim.schedule(function()
				done = done + 1
				if res.code ~= 0 then
					failed[#failed + 1] = vim.fs.basename(vim.fs.dirname(d)) .. "/" .. vim.fs.basename(d)
				end
				if done == #repos then
					if #failed == 0 then
						vim.notify("Docs update: all " .. #repos .. " repos up to date")
					else
						vim.notify(("Docs update: %d/%d ok; failed: %s"):format(#repos - #failed, #repos, table.concat(failed, ", ")), vim.log.levels.WARN)
					end
				end
			end)
		end)
	end
end

-- man-page / web providers rendered inline (no clone).
local function man_provider(cmd, title)
	return function()
		render_shell("MANWIDTH=90 " .. cmd .. " 2>/dev/null | col -bx", title, "man")
	end
end

-- ── generic chaptered-PDF provider (C/C++ ISO working drafts) ────────────
-- Same idea as the Intel SDM: fetch the PDF, split by the PDF outline into
-- per-clause text files (pdftotext -layout), stripping the ISO running
-- header / page numbers. Browsable, and <leader>fs gives the clause TOC.
local PDF_BUILD = [[
set -e
PDF="$1"; OUT="$2"; URL="$3"
if [ ! -f "$PDF" ]; then mkdir -p "$(dirname "$PDF")"; curl -fsSL "$URL" -o "$PDF"; fi
mkdir -p "$OUT"
JS="$OUT/.ol.js"
cat > "$JS" <<EOF2
var doc = Document.openDocument("$PDF");
function pageof(it){ try { var l = doc.resolveLink(it.uri); return (typeof l==="number")?l:(l&&l.page); } catch(e){ return -1; } }
function walk(items,d){ for(var i=0;i<items.length;i++){ var it=items[i]; print(d+"\t"+(pageof(it)+1)+"\t"+it.title); if(it.down) walk(it.down,d+1); } }
walk(doc.loadOutline(),0);
EOF2
mutool run "$JS" > "$OUT/.all.tsv" 2>/dev/null
TOTAL=$(pdfinfo "$PDF" | awk '/^Pages:/{print $2}')
D=$(awk -F'\t' '{c[$1]++} END{for(d=0;d<8;d++) if(c[d]>=5){print d; exit}}' "$OUT/.all.tsv")
idx=0; prev_p=""; prev_t=""
emit() {
  idx=$((idx+1)); n=$(printf '%03d' "$idx")
  f=$(printf '%s' "$3" | tr '/' '-' | cut -c1-80)
  pdftotext -layout -f "$1" -l "$2" "$PDF" - 2>/dev/null \
    | sed 's/\f//g' \
    | awk '{t=$0; gsub(/^[ \t]+|[ \t]+$/,"",t)} t ~ /^ISO\/IEC [0-9]/{next} t ~ /^© ISO\/IEC/{next} t ~ /^[0-9]+$/{next} {print}' \
    | cat -s > "$OUT/$n $f.txt"
}
if [ -n "$D" ]; then
  awk -F'\t' -v D="$D" '$1==D{print $2"\t"$3}' "$OUT/.all.tsv" > "$OUT/.ch.tsv"
  while IFS="$(printf '\t')" read -r p t; do
    [ -n "$prev_p" ] && emit "$prev_p" $((p-1)) "$prev_t"
    prev_p="$p"; prev_t="$t"
  done < "$OUT/.ch.tsv"
  [ -n "$prev_p" ] && emit "$prev_p" "$TOTAL" "$prev_t"
else
  p=1
  while [ "$p" -le "$TOTAL" ]; do e=$((p+39)); [ "$e" -gt "$TOTAL" ] && e="$TOTAL"; emit "$p" "$e" "pages $p-$e"; p=$((e+1)); done
fi
rm -f "$JS" "$OUT/.all.tsv" "$OUT/.ch.tsv"
]]

local STD_URLS = {
	["c-draft"] = "https://www.open-std.org/jtc1/sc22/wg14/www/docs/n3220.pdf",
	["cpp-draft"] = "https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf",
	["dwarf5"] = "https://dwarfstd.org/doc/DWARF5.pdf",
	["x86-64-abi"] = "https://gitlab.com/x86-psABIs/x86-64-ABI/-/jobs/artifacts/master/raw/x86-64-ABI/abi.pdf?job=build",
}

local function pick_pdf(name, prompt)
	for _, t in ipairs({ "curl", "mutool", "pdftotext", "pdfinfo" }) do
		if not have(t) then
			return vim.notify(t .. " needed for " .. name, vim.log.levels.WARN)
		end
	end
	local out = data_root .. "/std/" .. name
	local pdf = tools_dir .. "/" .. name .. ".pdf"
	local function browse()
		pick_files(out, "-e txt", prompt)
	end
	if #vim.fn.glob(out .. "/*.txt", false, true) > 0 then
		return browse()
	end
	vim.fn.mkdir(out, "p")
	vim.notify("Fetching + splitting " .. name .. " … (first time)")
	vim.system({ "sh", "-c", PDF_BUILD, "pdf", pdf, out, STD_URLS[name] }, { text = true, timeout = 300000 }, function(res)
		vim.schedule(function()
			if #vim.fn.glob(out .. "/*.txt", false, true) > 0 then
				browse()
			else
				vim.notify(name .. " build failed:\n" .. (res.stderr or ""):sub(1, 300), vim.log.levels.ERROR)
			end
		end)
	end)
end

-- ── GCC internals + manuals (texinfo, rendered with makeinfo) ────────────
-- gccint covers the internals: passes, RTL, GIMPLE, machine descriptions.
local function pick_gcc()
	if not (have("git") and have("makeinfo")) then
		return vim.notify("git and makeinfo (texinfo) are needed for GCC docs", vim.log.levels.WARN)
	end
	local docs = {
		["GCC Internals (gccint)"] = "gccint.texi",
		["GCC user manual (gcc)"] = "gcc.texi",
		["CPP (preprocessor)"] = "cpp.texi",
	}
	ensure_repo(data_root .. "/gcc", "https://github.com/gcc-mirror/gcc", "/gcc/doc", "gcc/doc", function(d)
		fzf().fzf_exec(vim.tbl_keys(docs), {
			prompt = "GCC docs> ",
			fzf_opts = { ["--no-multi"] = true },
			actions = {
				["default"] = function(sel)
					if not (sel and sel[1] and docs[sel[1]]) then
						return
					end
					local cmd = table.concat({
						"cd " .. vim.fn.shellescape(d .. "/gcc/doc"),
						"[ -f gcc-vers.texi ] || printf '@set version-GCC 15.0.0\\n@set BUGURL https://gcc.gnu.org/bugs/\\n@clear DEVELOPMENT\\n' > gcc-vers.texi",
						"makeinfo --no-split --plaintext -I include " .. vim.fn.shellescape(docs[sel[1]]),
					}, " && ")
					render_shell(cmd, sel[1], "text")
				end,
			},
		})
	end)
end

-- ── Android Common Kernel (versioned): binder + drivers + kernel docs ────
-- The attack surface for Android kernel research: drivers/android (binder),
-- drivers/staging/android (ashmem/ion), and the admin-guide/driver-api/
-- dev-tools (kasan, kcov) docs, at a chosen ACK branch (android14-6.1, …).
local function pick_android_kernel()
	if not (have("git") and have("fd")) then
		return vim.notify("git and fd are needed for the Android kernel", vim.log.levels.WARN)
	end
	local repo = "https://github.com/aosp-mirror/kernel_common"
	vim.system({ "sh", "-c", "git ls-remote --heads " .. repo .. " | sed 's#.*refs/heads/##' | grep -E '^android[0-9]+-[0-9]+\\.[0-9]+$' | sort -Vr" }, { text = true, timeout = 30000 }, function(res)
		vim.schedule(function()
			local branches = vim.split(res.stdout or "", "\n", { trimempty = true })
			if #branches == 0 then
				return vim.notify("Android kernel: could not list branches", vim.log.levels.WARN)
			end
			fzf().fzf_exec(branches, {
				prompt = "Android kernel (ACK)> ",
				fzf_opts = { ["--no-multi"] = true },
				actions = {
					["default"] = function(sel)
						if not (sel and sel[1]) then
							return
						end
						local br = sel[1]
						local dir = data_root .. "/android-kernel/" .. br
						local marker = dir .. "/drivers/android"
						local sparse = "/drivers/android /drivers/staging/android /Documentation/admin-guide /Documentation/driver-api /Documentation/dev-tools"
						local function browse()
							pick_files(dir, "-e c -e h -e rst -e md -e txt", "ACK " .. br .. "> ")
						end
						if vim.fn.isdirectory(marker) == 1 then
							return browse()
						end
						vim.fn.mkdir(vim.fs.dirname(dir), "p")
						vim.notify("Cloning Android kernel " .. br .. " … (first time)")
						local script = table.concat({
							"rm -rf " .. vim.fn.shellescape(dir),
							"git -c core.autocrlf=false clone -n --depth=1 --filter=tree:0 --branch " .. vim.fn.shellescape(br) .. " " .. repo .. " " .. vim.fn.shellescape(dir),
							"cd " .. vim.fn.shellescape(dir),
							"git sparse-checkout set --no-cone " .. sparse,
							"git checkout",
						}, " && ")
						vim.system({ "sh", "-c", script }, { text = true, timeout = 300000 }, function(r2)
							vim.schedule(function()
								if vim.fn.isdirectory(marker) == 1 then
									browse()
								else
									vim.notify("Android kernel clone failed:\n" .. (r2.stderr or ""):sub(1, 300), vim.log.levels.ERROR)
								end
							end)
						end)
					end,
				},
			})
		end)
	end)
end

-- ── Rust: pick one of the official mdbooks and browse its Markdown ───────
local function pick_rust()
	if not have("git") then
		return vim.notify("git needed for Rust docs", vim.log.levels.WARN)
	end
	local books = {
		["The Rust Programming Language (the book)"] = "https://github.com/rust-lang/book",
		["The Rust Reference"] = "https://github.com/rust-lang/reference",
		["The Rustonomicon (unsafe Rust)"] = "https://github.com/rust-lang/nomicon",
		["Rust by Example"] = "https://github.com/rust-lang/rust-by-example",
	}
	fzf().fzf_exec(vim.tbl_keys(books), {
		prompt = "Rust docs> ",
		fzf_opts = { ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				if not (sel and sel[1] and books[sel[1]]) then
					return
				end
				local url = books[sel[1]]
				ensure_repo(data_root .. "/rust/" .. url:match("([^/]+)$"), url, "/src", "src", function(d)
					pick_files(d .. "/src", "-e md", sel[1] .. "> ")
				end)
			end,
		},
	})
end

-- ── binutils: the analysis tools, rendered from their man pages ──────────
local function pick_binutils()
	if not have("man") then
		return vim.notify("man not found", vim.log.levels.WARN)
	end
	local tools = { "readelf", "objdump", "nm", "strings", "objcopy", "addr2line", "size", "strip", "ar", "ranlib", "c++filt", "ld", "as" }
	fzf().fzf_exec(tools, {
		prompt = "binutils> ",
		fzf_opts = { ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				if sel and sel[1] then
					render_shell("MANWIDTH=90 man " .. vim.fn.shellescape(sel[1]) .. " 2>/dev/null | col -bx", sel[1] .. "(1)", "man")
				end
			end,
		},
	})
end

-- ── providers + :Docs command ────────────────────────────────────────────
local providers = {
	{ name = "Linux Kernel", key = "kernel", run = pick_kernel_version },
	{ name = "BCC", key = "bcc", run = make_simple("bcc", simple.bcc) },
	{ name = "QEMU", key = "qemu", run = make_simple("qemu", simple.qemu) },
	{ name = "libbpf", key = "libbpf", run = make_simple("libbpf", simple.libbpf) },
	{ name = "bpftrace", key = "bpftrace", run = make_simple("bpftrace", simple.bpftrace) },
	{ name = "eBPF docs", key = "ebpf", run = make_simple("ebpf", simple.ebpf) },
	{ name = "drgn", key = "drgn", run = make_simple("drgn", simple.drgn) },
	{
		name = "libdrgn",
		key = "libdrgn",
		run = function()
			pick_doxygen("libdrgn", "https://github.com/osandov/drgn", "/libdrgn", "/libdrgn", "drgn.h")
		end,
	},
	{
		name = "SFML",
		key = "sfml",
		run = function()
			pick_doxygen("sfml", "https://github.com/SFML/SFML", "/include", "/include", "*.hpp *.h *.inl")
		end,
	},
	{ name = "SDL2", key = "sdl2", run = make_simple("sdl2", simple.sdl2) },
	{ name = "SDL3", key = "sdl3", run = make_simple("sdl3", simple.sdl3) },
	{ name = "OpenGL", key = "opengl", run = make_simple("opengl", simple.opengl) },
	{ name = "AFL++", key = "aflpp", run = make_simple("aflpp", simple.aflpp) },
	{ name = "Python", key = "python", run = make_simple("python", simple.python) },
	{ name = "LLVM", key = "llvm", run = make_simple("llvm", simple.llvm) },
	{ name = "Xen", key = "xen", run = make_simple("xen", simple.xen) },
	{ name = "Intel SDM Vol 1", key = "sdm1", run = function() pick_sdm(1) end },
	{ name = "Intel SDM Vol 2", key = "sdm2", run = function() pick_sdm(2) end },
	{ name = "Intel SDM Vol 3", key = "sdm3", run = function() pick_sdm(3) end },
	{ name = "Intel SDM Vol 4", key = "sdm4", run = function() pick_sdm(4) end },
	{ name = "C standard (C23 draft)", key = "cstd", run = function() pick_pdf("c-draft", "C draft> ") end },
	{ name = "C++ standard (draft)", key = "cppstd", run = function() pick_pdf("cpp-draft", "C++ draft> ") end },
	{ name = "DWARF 5 spec", key = "dwarf", run = function() pick_pdf("dwarf5", "DWARF 5> ") end },
	{ name = "x86-64 System V ABI (Intel/AMD64)", key = "abi", run = function() pick_pdf("x86-64-abi", "x86-64 ABI> ") end },
	{ name = "man 1 (commands)", key = "man1", run = function() pick_man(1) end },
	{ name = "man 2 (system calls)", key = "man2", run = function() pick_man(2) end },
	{ name = "man 3 (C library)", key = "man3", run = function() pick_man(3) end },
	{ name = "man 4 (devices)", key = "man4", run = function() pick_man(4) end },
	{ name = "man 5 (file formats)", key = "man5", run = function() pick_man(5) end },
	{ name = "man 7 (overviews)", key = "man7", run = function() pick_man(7) end },
	{ name = "man 8 (sysadmin)", key = "man8", run = function() pick_man(8) end },
	{ name = "cppman (C++ reference)", key = "cppman", run = pick_cppman },
	{ name = "NetBSD kernel (man 9)", key = "nbsd9", run = function() pick_nbsd(9) end },
	{ name = "NetBSD drivers (man 4)", key = "nbsd4", run = function() pick_nbsd(4) end },
	{ name = "OCaml (stdlib)", key = "ocaml", run = pick_ocaml },
	{ name = "Haskell (Hoogle)", key = "haskell", run = pick_haskell },
	{ name = "Rust (book / reference / nomicon)", key = "rust", run = pick_rust },
	{ name = "Frida", key = "frida", run = make_simple("frida", simple.frida) },
	{ name = "Triton", key = "triton", run = make_simple("triton", simple.triton) },
	{ name = "angr", key = "angr", run = make_simple("angr", simple.angr) },
	{ name = "QBDI (Quarkslab)", key = "qbdi", run = make_simple("qbdi", simple.qbdi) },
	{ name = "Capstone", key = "capstone", run = make_simple("capstone", simple.capstone) },
	{ name = "Binary Ninja API", key = "binja", run = make_simple("binja", simple.binja) },
	{ name = "LIEF", key = "lief", run = make_simple("lief", simple.lief) },
	{ name = "pyelftools", key = "pyelftools", run = make_simple("pyelftools", simple.pyelftools) },
	{ name = "QBinDiff", key = "qbindiff", run = make_simple("qbindiff", simple.qbindiff) },
	{ name = "Qiling", key = "qiling", run = make_simple("qiling", simple.qiling) },
	{ name = "PANDA", key = "panda", run = make_simple("panda", simple.panda) },
	{ name = "Volatility", key = "volatility", run = make_simple("volatility", simple.volatility) },
	{ name = "syzkaller", key = "syzkaller", run = make_simple("syzkaller", simple.syzkaller) },
	{ name = "Unicorn", key = "unicorn", run = make_simple("unicorn", simple.unicorn) },
	{ name = "Keystone", key = "keystone", run = make_simple("keystone", simple.keystone) },
	{ name = "pwntools", key = "pwntools", run = make_simple("pwntools", simple.pwntools) },
	{ name = "UEFI (edk2)", key = "uefi", run = make_simple("uefi", simple.uefi) },
	{ name = "coreboot", key = "coreboot", run = make_simple("coreboot", simple.coreboot) },
	{ name = "U-Boot", key = "uboot", run = make_simple("uboot", simple.uboot) },
	{ name = "Android (bionic internals)", key = "android", run = make_simple("android", simple.android) },
	{ name = "Android kernel (ACK, versioned)", key = "android-kernel", run = pick_android_kernel },
	{ name = "DynamoRIO (DBI, Pin alternative)", key = "dynamorio", run = make_simple("dynamorio", simple.dynamorio) },
	{ name = "Nyx (snapshot fuzzer)", key = "nyx", run = make_simple("nyx", simple.nyx) },
	{ name = "LibAFL", key = "libafl", run = make_simple("libafl", simple.libafl) },
	{ name = "CodeQL", key = "codeql", run = make_simple("codeql", simple.codeql) },
	{ name = "lld (LLVM linker)", key = "lld", run = make_simple("lld", simple.lld) },
	{ name = "lldb", key = "lldb", run = make_simple("lldb", simple.lldb) },
	{ name = "Mach-O format", key = "macho", run = make_simple("macho", simple.macho) },
	{ name = "Win32 API", key = "winsdk", run = make_simple("winsdk", simple.winsdk) },
	{ name = "Windows Driver (WDK)", key = "windriver", run = make_simple("windriver", simple.windriver) },
	{ name = "PE / COFF format", key = "pe", run = make_simple("pe", simple.pe) },
	{ name = "Ghidra API (versioned)", key = "ghidra", run = pick_ghidra },
	{ name = "Multiboot specs", key = "multiboot", run = pick_multiboot },
	{ name = "GNU Make manual", key = "make", run = function()
		render_shell("curl -sSL https://www.gnu.org/software/make/manual/make.html | pandoc -f html -t gfm-raw_html --wrap=none 2>/dev/null", "GNU Make manual", "markdown")
	end },
	{ name = "GNU ld (linker)", key = "ld", run = man_provider("man ld", "ld(1)") },
	{ name = "GNU as (assembler)", key = "as", run = man_provider("man as", "as(1)") },
	{ name = "GCC internals + manuals", key = "gcc", run = pick_gcc },
	{ name = "binutils (readelf/objdump/nm/…)", key = "binutils", run = pick_binutils },
	{ name = "ELF format", key = "elf", run = man_provider("man 5 elf", "elf(5)") },
	{ name = "Bash (man bash)", key = "bash", run = man_provider("man bash", "bash(1)") },
	{ name = "pydoc (any Python pkg)", key = "pydoc", run = pick_pydoc },
	{ name = "Update all cached docs", key = "update", run = update_all },
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
