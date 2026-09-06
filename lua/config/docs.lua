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
-- The book library is pre-built and committed to the repo under Resources/docs;
-- it is read directly (no epub/pdf build step). stdpath("config") keeps this
-- portable. Other providers still fetch/convert into the volatile data_root.
local frozen_root = vim.fn.stdpath("config") .. "/Resources/docs"
-- The build scripts (PDF/SDM splitters, doxygen pipeline, kernel-doc index,
-- aya crate index, SDM figure extractor) live as files under Resources/tools
-- and are read only when a build actually runs; nothing is parsed at startup.
local tools_src = vim.fn.stdpath("config") .. "/Resources/tools"
local function tool_script(name)
	local ok, lines = pcall(vim.fn.readfile, tools_src .. "/" .. name)
	if not ok or #lines == 0 then
		-- Callers run this under `sh -c` and report a non-zero exit with its
		-- stderr, so a failing stub surfaces as a normal build error instead of
		-- a Lua traceback out of an async callback.
		return 'echo "docs: build tool missing: ' .. tools_src .. "/" .. name .. '" >&2; exit 1'
	end
	return table.concat(lines, "\n")
end
-- Shared helpers (config/util.lua). shq is POSIX single-quote escaping: every command string here runs under `sh`
-- (vim.system {"sh","-c",...}, and fzf-lua forces SHELL=sh for its streamed
-- commands), whereas shq() quotes for the user's 'shell': with
-- fish it doubles backslashes, which turned python's '\n' into '\\n'.
local util = require("config.util")
local shq, have, fzf = util.shq, util.have, util.fzf

-- mkdir -p that reports instead of throwing: vim.fn.mkdir raises, and an
-- unwritable cache directory turned any :Docs call into an E739 traceback.
-- Returns true when the directory exists afterwards.
-- `quiet` for best-effort cache writes, which already ran under pcall and
-- should not produce an error notification on every single document open.
local function mkdir(path, quiet)
	if vim.fn.isdirectory(path) == 1 then
		return true
	end
	local ok = pcall(vim.fn.mkdir, path, "p")
	if not ok and not quiet then
		vim.notify("Docs: cannot create " .. path, vim.log.levels.ERROR)
	end
	return ok
end
local cache_root = data_root .. "/linux"
local tags_cache = cache_root .. "/tags.txt"

local viewer_win -- reused doc-viewer window handle
local viewer_seq = 0 -- for unique scratch buffer names

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
				vim.keymap.set("n", k, clear_figure, { buffer = b, nowait = true, silent = true, desc = "docs: close figure" })
			end
		end)
		return
	end
	if have("xdg-open") then
		vim.system({ "xdg-open", png }, { detach = true }) -- hand off to the desktop; don't hold the handle
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
	-- Heading heuristics apply to prose only: in a C header `# define X`
	-- matched the Markdown heading pattern (26 false entries on sqlite3.h)
	-- and hid the treesitter symbol picker below.
	local ft = vim.bo.filetype
	local prose = ft == "" or ft == "markdown" or ft == "rst" or ft == "text" or ft == "man"
	for i, L in ipairs(prose and lines or {}) do
		local title, depth
		-- Leading whitespace allowed: pdftotext -layout indents the section
		-- headers of the C/C++/DWARF/ABI chapters, which left their TOC empty.
		local hashes, htext = L:match("^%s*(#+)%s+(.+)$")
		if hashes then
			depth, title = #hashes, htext
		else
			local num, sect = L:match("^%s*([%dA-Z][%d.]*%.%d[%d.]*)%s%s+([%u%d].*)$")
			if num then
				depth = select(2, num:gsub("%.", "")) + 1
				title = num .. "  " .. sect
			elseif L:match("^%s*%u[%u][%u &/,()'-]*$") then
				depth, title = 1, L -- man-page section header (NAME, SEE ALSO, …)
			end
		end
		if title then
			title = title:gsub("%s+$", "")
			entries[#entries + 1] = string.format("%d\t%s%s", i, string.rep("  ", depth - 1), title)
		end
	end
	if #entries == 0 then
		-- A code example (no headings): fall back to a treesitter symbol picker,
		-- which reads the read-only scratch buffer's syntax tree (no file needed).
		if not prose and pcall(function() fzf().treesitter() end) then
			return
		end
		return vim.notify("No headings or symbols in this document", vim.log.levels.INFO)
	end
	fzf().fzf_exec(entries, {
		prompt = "TOC> ",
		fzf_opts = { ["--with-nth"] = "2..", ["--delimiter"] = "\\t", ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				local lnum = sel and sel[1] and tonumber(sel[1]:match("^(%d+)"))
				if lnum and vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_set_current_win(win)
					-- Clamp: the buffer may have been replaced by a shorter doc
					-- since the picker was built, and an out-of-range line throws.
					lnum = math.min(lnum, vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win)))
					vim.api.nvim_win_set_cursor(win, { lnum, 0 })
					vim.cmd.normal({ "zz", bang = true })
				end
			end,
		},
	})
end

local follow_link -- forward declaration; assigned after open_file is defined
local render_shell -- forward declaration; gd on a man page (render_lines) renders through it
local gs_source -- forward declaration; assigned after the `simple` table exists
local last_picker -- re-open the current provider's fuzzy finder (D in a doc)
-- Bumped on every user-initiated open; an async render (pandoc/curl) checks it
-- before drawing so a slow conversion cannot clobber a doc opened after it.
local render_seq = 0

-- ── render lines in a reused right vsplit with the given filetype ─────────
-- Every caller that renders synchronously bumps render_seq through this, so an
-- async render still in flight cannot overwrite what the user is now reading.
local function render_lines(lines, ft, dir, title)
	render_seq = render_seq + 1
	if not lines or #lines == 0 then
		return vim.notify("Nothing to render", vim.log.levels.WARN)
	end
	-- Capture the picker that produced this doc, so D reopens THIS provider's
	-- finder even after another provider has since been browsed (last_picker is
	-- module-global; at render time it still points at this doc's provider).
	local reopen = last_picker

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
		-- Focus it only when it is on this tabpage: a slow render that lands
		-- after the user has moved on should fill the viewer, not drag them
		-- back (and never switch tabpage under them).
		if vim.api.nvim_win_get_tabpage(win) == vim.api.nvim_get_current_tabpage() then
			vim.api.nvim_set_current_win(win)
		end
	else
		vim.cmd.vsplit({ mods = { split = "belowright" } })
		win = vim.api.nvim_get_current_win()
	end
	viewer_win = win
	vim.w[win].docs_viewer = true

	-- Scratch buffer: buftype=nofile, noswapfile, nomodeline, unlisted are the
	-- defaults for nvim_create_buf(false, true); only bufhidden needs override.
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	-- Wiping the previous doc buffer re-sourced syntax/markdown.vim (the
	-- TSHighlighter teardown re-runs the syntaxset FileType autocmd), ~14 ms on
	-- every open whatever the size. Clearing its filetype first makes the wipe
	-- free (measured: median open 20.5 -> 8.4 ms).
	-- Only when this window is its last one: a doc the user :vsplit stays
	-- highlighted in the other split.
	local prev = vim.api.nvim_win_get_buf(win)
	if
		prev ~= buf
		and vim.api.nvim_buf_is_valid(prev)
		and vim.api.nvim_buf_get_name(prev):match("^docs://")
		and #vim.fn.win_findbuf(prev) == 1
	then
		pcall(function()
			vim.bo[prev].filetype = ""
		end)
	end
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

	-- vim-sleuth runs its indent heuristics on FileType for any named buffer;
	-- pointless on a read-only doc and 5-14 ms a pop. (With the wipe fix above:
	-- median open 3.5 ms, max 8 ms across the whole library.)
	vim.b[buf].sleuth_automatic = 0
	-- filetype last, while `win` is current, so ftplugin setlocal stays scoped.
	vim.bo[buf].filetype = ft or "markdown"
	vim.bo[buf].modifiable = false

	vim.keymap.set("n", "q", function()
		render_seq = render_seq + 1 -- an in-flight render must not reopen a closed viewer
		pcall(vim.api.nvim_win_close, 0, true)
	end, { buffer = buf, nowait = true, silent = true, desc = "Close docs viewer" })
	vim.keymap.set("n", "<leader>fs", docs_toc, { buffer = buf, desc = "Docs: table of contents" })
	-- D reopens whichever picker produced this doc. Bound for every viewer:
	-- web articles and man pages render with no dir and used to get no D.
	vim.keymap.set("n", "D", function()
		if reopen then
			reopen()
		end
	end, { buffer = buf, nowait = true, silent = true, desc = "Docs: reopen this provider's fuzzy finder" })
	if ft == "man" then
		-- gd follows the cross-reference under the cursor (e.g. gd on `read`
		-- opens read's man page) in a new split, so this page is not replaced.
		vim.keymap.set("n", "gd", function()
			-- Not :Man: man.lua reuses the current window when its filetype is
			-- already "man", which edited man:// over this viewer and, with
			-- bufhidden=wipe, destroyed the doc. Render into a fresh split with
			-- the same viewer (cached like the man pickers).
			local word = vim.fn.expand("<cword>")
			if word == "" then
				return
			end
			-- Confirm the page exists BEFORE splitting: splitting first leaked
			-- a window (marked docs_viewer, so later renders could land in it)
			-- every time the word under the cursor had no man page.
			vim.system({ "man", "-w", word }, { text = true, timeout = 5000 }, function(res)
				vim.schedule(function()
					if res.code ~= 0 then
						return vim.notify("No man page for " .. word, vim.log.levels.INFO)
					end
					vim.cmd.vsplit({ mods = { split = "belowright" } })
					-- Hand the new split over as the viewer, otherwise
					-- render_lines follows the tracked viewer_win and puts the
					-- new page back in the old window, leaving the stale one
					-- here and leaking a window on every jump.
					viewer_win = vim.api.nvim_get_current_win()
					vim.w[viewer_win].docs_viewer = true
					render_shell("MANWIDTH=90 man " .. shq(word) .. " 2>/dev/null | col -bx", word, "man", "man::" .. word)
				end)
			end)
		end, { buffer = buf, nowait = true, silent = true, desc = "Docs: follow man cross-reference" })
	end
	if dir then
		vim.b[buf].docs_dir = dir
		vim.keymap.set("n", "gd", function()
			follow_link()
		end, { buffer = buf, nowait = true, silent = true, desc = "Docs: follow link under cursor" })
		vim.keymap.set("n", "gs", function()
			gs_source(dir)
		end, { buffer = buf, silent = true, desc = "Docs: explore this project's source" })
		-- :Src, buffer-local so it exists only inside a docs viewer (not globally).
		vim.api.nvim_buf_create_user_command(buf, "Src", function()
			gs_source(dir)
		end, { desc = "Explore this project's source (docs viewer only)" })
		vim.keymap.set("n", "<leader>fe", function()
			require("oil").toggle_float(dir)
		end, { buffer = buf, desc = "Oil (this doc's directory)" })
	end
	-- <CR> in every viewer (the global <CR> is `ciw`, which raised E21 on
	-- these read-only buffers): an image link on the line shows that image,
	-- an SDM "Figure N-M" line shows the cropped diagram, anything else
	-- follows the link under the cursor.
	vim.keymap.set("n", "<CR>", function()
		local img = vim.api.nvim_get_current_line():match("!%[[^%]]*%]%(([^)%s]+)")
		if img and dir then
			local p = img:sub(1, 1) == "/" and img or vim.fs.normalize(dir .. "/" .. img)
			if vim.fn.filereadable(p) == 1 then
				return show_figure(p)
			end
		end
		if dir and dir:match("/sdm/vol%d") then
			return open_figure_under_cursor()
		end
		if dir then
			return follow_link()
		end
	end, { buffer = buf, nowait = true, silent = true, desc = "Docs: show figure or follow link" })
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

-- Pick the requested slice of an included file: "" = whole file; "N", "N:",
-- ":M", "N:M" = 1-based inclusive line range; a name = an mdBook ANCHOR block
-- (lines between "ANCHOR: name" and "ANCHOR_END: name", markers dropped).
local function include_select(body, sel)
	if not sel or sel == "" then
		return body
	end
	local a, colon, b = sel:match("^(%d*)(:?)(%d*)$")
	if a and (a ~= "" or colon == ":") then
		local s = tonumber(a) or 1
		local e = (b ~= "" and tonumber(b)) or (colon == ":" and #body) or s
		local sub = {}
		for i = s, math.min(e, #body) do
			sub[#sub + 1] = body[i]
		end
		return sub
	end
	local keep, inside = {}, false
	for _, l in ipairs(body) do
		if l:match("ANCHOR:%s*" .. vim.pesc(sel) .. "%s*$") then
			inside = true
		elseif l:match("ANCHOR_END:%s*" .. vim.pesc(sel) .. "%s*$") then
			inside = false
		elseif inside and not l:match("ANCHOR[_%u]*:") then
			keep[#keep + 1] = l
		end
	end
	return #keep > 0 and keep or body
end

-- Single-pass markdown cleanup (was four separate passes; the extra passes cost
-- ~40ms on the largest chapters). Per line it: expands mdBook {{#include}} /
-- {{#rustdoc_include}} / {{#playground}} (the Aya tutorials keep code under the
-- repo's examples/, resolved relative to the page) and drops {{#title}}; turns
-- Jekyll/Liquid tags into Markdown; normalizes ```lang,attr fences and GitHub
-- ">[!NOTE]" callouts; strips trailing {#anchor}/{:attrs} noise; absolutizes
-- True when `path` resolves inside one of the doc trees. Both gd and the
-- mdBook {{#include}} expansion use it, so a crafted ../-laden target cannot
-- pull an arbitrary file into the viewer. Defined here, above its first use
-- in clean_markdown, so the closure captures it as an upvalue.
local function within_docs(path)
	local real = vim.uv.fs_realpath(path) or path
	for _, r in ipairs({ data_root, frozen_root }) do
		local root = vim.uv.fs_realpath(r) or r
		if real:sub(1, #root + 1) == root .. "/" then
			return true
		end
	end
	return false
end

-- relative image links (so snacks.image finds them); and drops Sphinx ".. only::"
-- residue (Cilium's "not (...)" line + unreleased banner). Then trims leading
-- blanks. Runs after strip_frontmatter.
local function clean_markdown(lines, dir)
	-- Rewrite one line; returns the transformed line, or nil to drop it.
	local function xform(l)
		-- Fast path: most lines are plain prose with none of the trigger
		-- characters, so skip the dozen regex tries below (this, not the pass
		-- count, is what the postprocess spends its time on).
		if not l:find("[{`!>]") and not l:find("^%s*not %(") and not l:find("unreleased") then
			return l
		end
		local lang = l:match("^%s*{%%%s*highlight%s+(%S+)%s*%%}%s*$")
		if lang then
			l = "```" .. lang
		elseif l:match("^%s*{%%%s*endhighlight%s*%%}%s*$") then
			l = "```"
		elseif l:match("^%s*{%%.-%%}%s*$") then
			l = ""
		elseif l:match("^%s*```[%w_+-]+,") then
			l = l:gsub("^(%s*```[%w_+-]+),.*$", "%1") -- ```rust,ignore -> ```rust
		elseif l:match("^%s*>%s*%[!%u+%]%s*$") then
			l = l:gsub("^(%s*>%s*)%[!(%u)(%u*)%]%s*$", function(pre, h, t)
				return pre .. "**" .. h .. t:lower() .. "**"
			end)
		else
			l = l:gsub("%s*{[#:][^}]*}%s*$", "") -- trailing {#anchor}/{:attrs}
		end
		if dir then
			-- `post` keeps an optional pandoc link title (`media/x.png "caption"`).
			l = l:gsub("(!%[[^%]]*%]%()([^)%s]+)([^)]*%))", function(pre, url, post)
				if url:match("^%a[%w+.-]*://") or url:match("^/") then
					return pre .. url .. post
				end
				return pre .. vim.fs.normalize(dir .. "/" .. (url:gsub("^%./", ""))) .. post
			end)
		end
		if l:match("^%s*not %(.-or.-%)%s*$") or l:match("You are looking at unreleased.-documentation") then
			return nil -- Sphinx only:: residue / unreleased banner
		end
		return l
	end
	local out = {}
	local function push(l)
		local x = xform(l)
		if x ~= nil then
			out[#out + 1] = x
		end
	end
	for _, l in ipairs(lines) do
		local spec = dir
			and (l:match("^%s*{{#include%s+(.-)%s*}}%s*$")
				or l:match("^%s*{{#rustdoc_include%s+(.-)%s*}}%s*$")
				or l:match("^%s*{{#playground%s+(.-)%s*}}%s*$"))
		if spec then
			local rel, sel = spec:match("^([^:]+):?(.*)$")
			local full = vim.fs.normalize(dir .. "/" .. rel)
			-- Same containment as gd: an include must not reach outside the
			-- doc trees (a ../-laden target otherwise read any file).
			if vim.fn.filereadable(full) == 1 and within_docs(full) then
				for _, cl in ipairs(include_select(vim.fn.readfile(full), sel)) do
					push(cl)
				end
			else
				push(l) -- target missing: keep the marker, not a silent gap
			end
		elseif not (dir and l:match("^%s*{{#title%s+.-}}%s*$")) then
			push(l)
		end
	end
	while out[1] and out[1]:match("^%s*$") do
		table.remove(out, 1)
	end
	return out
end

-- ── render a doc or source file, by extension ────────────────────────────
--   .rst -> pandoc to Markdown (raw rst as `rst` if pandoc is missing);
--   .md -> as-is; anything else (code examples) -> raw with detected filetype.
-- Converted-markdown cache: pandoc (rst/xml/html -> gfm) dominates a doc open
-- (95%+ of a big .rst) and was run synchronously, freezing the UI for up to a
-- second on large kernel/python pages. Cache the conversion keyed by path+mtime
-- (a re-clone or new version reconverts) and run it async on a cache miss.
local convcache_dir = data_root .. "/.convcache"
local function open_file(path)
	render_seq = render_seq + 1
	local myseq = render_seq -- a later open supersedes this one's async render
	local ext = (path:match("%.([%w]+)$") or ""):lower()
	local dir = vim.fs.dirname(path)
	local base = vim.fs.basename(path)
	-- .rst via pandoc rst, .xml via pandoc DocBook (OpenGL refpages), .html via
	-- pandoc HTML (Ghidra CheatSheet, doxygen pages).
	local from
	if have("pandoc") then
		from = ext == "rst" and "rst"
			or ext == "xml" and "docbook"
			or (ext == "html" or ext == "htm") and "html"
			or nil
	end

	-- Render `lines`/`ft`; nil lines means "fall back to the raw file".
	local function finish(lines, ft)
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
		if ft == "markdown" then
			lines = clean_markdown(strip_frontmatter(lines), dir)
		end
		render_lines(lines, ft, dir, base)
	end

	-- An image is shown as a figure, never read into the text viewer (a PNG
	-- as "text" threw on newlines in the replacement and left an empty,
	-- modifiable buffer).
	if ({ png = 1, jpg = 1, jpeg = 1, gif = 1, svg = 1, webp = 1 })[ext] then
		return show_figure(path)
	end
	-- Any other binary (a tarball or PDF reached through a link) would throw
	-- the same way, so refuse it rather than wiping the current doc for it.
	local probe = io.open(path, "rb")
	if probe then
		local head = probe:read(1024) or ""
		probe:close()
		if head:find("\0", 1, true) then
			return vim.notify("Not a text document: " .. vim.fs.basename(path), vim.log.levels.WARN)
		end
	end
	if not from then
		return finish(nil, nil) -- markdown / code: raw read is already instant
	end

	local cf = convcache_dir .. "/" .. vim.fn.sha256(path .. ":" .. vim.fn.getftime(path)) .. ".md"
	if vim.fn.filereadable(cf) == 1 then
		return finish(vim.fn.readfile(cf), "markdown")
	end
	vim.system(
		{ "pandoc", "-f", from, "-t", "gfm-raw_html", "--wrap=none", path },
		{ text = true, timeout = 120000 },
		function(res)
			vim.schedule(function()
				local lines = vim.split(res.stdout or "", "\n")
				while #lines > 0 and lines[#lines] == "" do
					lines[#lines] = nil
				end
				if #lines == 0 then
					if myseq == render_seq then
						finish(nil, nil) -- conversion empty: show raw source
					end
					return
				end
				-- Only cache a clean exit: pandoc can print half a document and
				-- then fail, and that truncation would be served forever.
				if res.code == 0 then
					pcall(function() -- cache even if a newer open won the race
						mkdir(convcache_dir, true)
						vim.fn.writefile(lines, cf)
					end)
				end
				if myseq ~= render_seq then
					return -- superseded by a later open; do not clobber the viewer
				end
				finish(lines, "markdown")
			end)
		end
	)
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
		-- Reference-style link ([text][id], resolved by a "[id]: target" line
		-- elsewhere in the page), which the Rust mdBooks use heavily. The id
		-- under the cursor wins; otherwise the first on the line.
		local ids, under = {}, nil
		for a, id, b in line:gmatch("()%]%[([^%]]+)%]()") do
			ids[#ids + 1] = id
			if col >= a - 1 and col < b then
				under = id
			end
		end
		if under then
			table.insert(ids, 1, under)
		end
		for _, id in ipairs(ids) do
			local pat = "^%s*%[" .. id:gsub("%p", "%%%0") .. "%]:%s*(%S+)"
			for _, L in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
				local t = L:match(pat)
				if t then
					url = t
					break
				end
			end
			if url then
				break
			end
		end
	end
	if not url then
		-- Autolinks (<https://...>) and bare URLs are external, not "not found";
		-- prefer the one under the cursor, else the first on the line.
		local firsturl
		for a, u, b in line:gmatch("()(%a[%w+.-]*://[^%s<>\"')%]]+)()") do
			firsturl = firsturl or u
			if col >= a - 1 and col < b then
				url = u
				break
			end
		end
		url = url or firsturl
	end
	if not url then
		return vim.notify("No link on this line", vim.log.levels.INFO)
	end
	if url:match("^%a[%w+.-]*://") or url:match("^mailto:") then
		return vim.notify("External link: " .. url, vim.log.levels.INFO)
	end
	-- CommonMark destination forms: <path with spaces>, an optional quoted
	-- title after whitespace, a #fragment, and %XX escapes (decoded last, so
	-- %23 survives as a literal # in a file name).
	url = url:match("^<(.-)>%s*$") or url
	url = url:gsub("%s+[\"'(][^\"')]*[\"')]%s*$", ""):gsub("#.*$", ""):gsub("%s+$", "")
	url = url:gsub("%%(%x%x)", function(h)
		return string.char(tonumber(h, 16))
	end)
	if url == "" then
		return
	end
	-- clean_markdown already absolutized image links; don't re-join those to dir.
	local base = url:sub(1, 1) == "/" and url or vim.fs.normalize(dir .. "/" .. url:gsub("^%./", ""))
	-- Wiki links often omit the extension ([SDL_Event](SDL_Event) -> SDL_Event.md);
	-- mdBook cross-links point at the rendered .html of a source .md.
	local path
	for _, cand in ipairs({ base, base .. ".md", base .. ".markdown", base .. ".rst", base .. ".txt", base .. ".html", (base:gsub("%.html$", ".md")) }) do
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
		-- Containment: a crafted ../-laden link must not escape the docs trees
		-- and open an arbitrary file. Resolve symlinks/.. and require the target
		-- stay under the volatile cache (data_root) or the committed frozen
		-- library (frozen_root); cross-section links within either are fine.
		if not within_docs(path) then
			return vim.notify("Link escapes the docs tree: " .. url, vim.log.levels.WARN)
		end
		open_file(path)
	else
		vim.notify("Link target not found: " .. url, vim.log.levels.WARN)
	end
end

-- ── extract one kernel-doc symbol and render it (async) ──────────────────
local function open_api(dir, name, file)
	render_seq = render_seq + 1
	local myseq = render_seq -- a later open supersedes this (up to 15 s) render
	-- kernel-doc is perl on older trees and Python (needing the kdoc package on
	-- PYTHONPATH) on recent ones; pick the interpreter by shebang so both work.
	local cmd = string.format(
		"cd %s && KD=scripts/kernel-doc && "
			.. "if head -1 \"$KD\" 2>/dev/null | grep -qi perl; then perl \"$KD\" -rst -function %s %s 2>/dev/null; "
			.. "else PYTHONPATH=tools/lib/python python3 \"$KD\" -rst -function %s %s 2>/dev/null; fi "
			.. "| pandoc -f rst -t gfm-raw_html --wrap=none 2>/dev/null",
		shq(dir),
		shq(name),
		shq(file),
		shq(name),
		shq(file)
	)
	vim.system({ "sh", "-c", cmd }, { text = true, timeout = 15000 }, function(res)
		vim.schedule(function()
			local out = vim.split(res.stdout or "", "\n", { trimempty = true })
			if #out == 0 then
				return vim.notify("kernel-doc: nothing for " .. name .. "\n" .. (res.stderr or ""), vim.log.levels.WARN)
			end
			if myseq ~= render_seq then
				return -- something newer was opened while kernel-doc ran
			end
			render_lines(out, "markdown", dir, name)
		end)
	end)
end

-- Background pre-conversion of a browsed doc set's .rst/.xml/.html into the
-- convcache, so the first open of a big page (kernel kvm/api.rst: 1 s of
-- pandoc) is instant too. One nice'd sequential loop per set, sets queued one
-- at a time; the key must match open_file's sha256(path .. ":" .. mtime).
-- Skips what is already cached, so a re-run after a pull converts only the
-- changed files.
local PREWARM_SH = [[
# One find over the set (paths + mtimes) hashed into a stamp: an unchanged,
# already-converted set costs one process instead of three per file (~6 s of
# CPU for a kernel tree on every session). The stamp is written only after a
# complete pass, so an interrupted run re-scans.
sig=$(find "$1" -type f \( -name '*.rst' -o -name '*.xml' -o -name '*.html' -o -name '*.htm' \) -printf '%p %Ts\n' 2>/dev/null | sort | sha256sum | cut -d' ' -f1)
mkdir -p "$2/.stamps"
stamp="$2/.stamps/$(printf '%s' "$1" | sha256sum | cut -d' ' -f1)"
[ -f "$stamp" ] && [ "$(cat "$stamp")" = "$sig" ] && exit 0
find "$1" -type f \( -name '*.rst' -o -name '*.xml' -o -name '*.html' -o -name '*.htm' \) 2>/dev/null |
while IFS= read -r f; do
  m=$(stat -c %Y "$f" 2>/dev/null) || continue
  key=$(printf '%s:%s' "$f" "$m" | sha256sum | cut -d' ' -f1)
  out="$2/$key.md"
  [ -s "$out" ] && continue
  case "$f" in *.rst) from=rst ;; *.xml) from=docbook ;; *) from=html ;; esac
  if pandoc -f "$from" -t gfm-raw_html --wrap=none "$f" >"$out.tmp" 2>/dev/null && [ -s "$out.tmp" ]; then
    mv "$out.tmp" "$out"
  else
    rm -f "$out.tmp"
  fi
done
printf '%s' "$sig" > "$stamp"
]]
local prewarm_queue, prewarm_done, prewarm_busy, prewarm_job = {}, {}, false, nil
local function prewarm_next()
	local dir = table.remove(prewarm_queue, 1)
	if not dir then
		prewarm_busy = false
		return
	end
	prewarm_busy = true
	mkdir(convcache_dir)
	-- pcall: a spawn failure must not abort the picker or wedge the queue.
	-- setsid puts the loop, its subshell and every pandoc in their own
	-- process group, so the kill on exit reaches all of them (a plain kill
	-- of the parent sh left pandoc running after :qa).
	local ok, job = pcall(vim.system, { "setsid", "nice", "-n", "19", "sh", "-c", PREWARM_SH, "prewarm", dir, convcache_dir }, {}, function()
		prewarm_job = nil
		vim.schedule(prewarm_next)
	end)
	if ok then
		prewarm_job = job
	else
		prewarm_busy = false
	end
end
-- The loop would otherwise outlive Neovim (a kernel Documentation/ tree is
-- minutes of pandoc); stop it with the editor. It resumes from the cache
-- next time the set is browsed.
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = vim.api.nvim_create_augroup("DocsPrewarm", { clear = true }),
	callback = function()
		if prewarm_job and prewarm_job.pid then
			pcall(vim.uv.kill, -prewarm_job.pid, "sigterm") -- the whole process group
		end
	end,
})
-- Opt out with `vim.g.docs_prewarm = false`.
local function prewarm_convcache(dir)
	if
		prewarm_done[dir]
		or vim.g.docs_prewarm == false
		or dir:sub(1, #frozen_root) == frozen_root -- the frozen library is markdown/text already
		or not (have("pandoc") and have("sha256sum") and have("nice") and have("setsid"))
	then
		return
	end
	prewarm_done[dir] = true
	prewarm_queue[#prewarm_queue + 1] = dir
	if not prewarm_busy then
		prewarm_next()
	end
end

-- ── fuzzy-browse doc/source files under a directory ──────────────────────
local function pick_files(dir, fd_args, prompt)
	if not have("fd") then
		return vim.notify("fd not found (needed to browse docs)", vim.log.levels.WARN)
	end
	prewarm_convcache(dir)
	-- remember this picker so `D` in an opened doc reopens the same fuzzy finder
	last_picker = function()
		pick_files(dir, fd_args, prompt)
	end
	-- --base-directory guarantees the search root (fzf-lua's cwd isn't applied
	-- to the raw command); cwd lets the builtin previewer resolve the entries.
	fzf().fzf_exec("fd --base-directory " .. shq(dir) .. " --type f " .. fd_args, {
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
	last_picker = function()
		api_search(dir) -- D in a kernel-API doc reopens this search, not an older picker
	end
	fzf().fzf_exec("cat " .. shq(dir .. "/api-index.tsv"), {
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
	if not mkdir(cache_root) then
		return
	end
	vim.notify("Cloning kernel Documentation @ " .. version .. " … (first time only)")
	local tmp = dir .. ".tmp"
	local script = table.concat({
		"rm -rf " .. shq(tmp) .. " " .. shq(dir),
		"git -c core.autocrlf=false clone -n --depth=1 --filter=blob:none --branch "
			.. shq(version) .. " " .. repo .. " " .. shq(tmp),
		"git -C " .. shq(tmp) .. " sparse-checkout set --no-cone /Documentation",
		"git -C " .. shq(tmp) .. " checkout",
		"mv " .. shq(tmp) .. " " .. shq(dir),
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

local function ensure_api(version, cb)
	ensure_docs(version, function(dir, _)
		local index = dir .. "/api-index.tsv"
		if vim.fn.filereadable(index) == 1 then
			return cb(dir)
		end
		vim.notify("Fetching kernel API sources @ " .. version .. " … (first time, ~1-2 min)")
		vim.system(
			{ "sh", "-c", tool_script("api_build.sh"), "api", dir }, -- argv, not string.format (a % in the script would corrupt it)
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
	if not mkdir(cache_root) then
		return
	end
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
	mkdir(vim.fs.dirname(dir))
	-- Clone name: <name>/master -> "<name>"; a flat data_root/<name> -> "<name>".
	local label = vim.fs.basename(dir)
	if label == "master" then
		label = vim.fs.basename(vim.fs.dirname(dir))
	end
	vim.notify("Cloning " .. label .. " docs … (first time only)")
	-- Kill-atomic: build into <dir>.tmp then rename, so a clone/checkout killed
	-- midway never leaves a partial tree that the marker check treats as done.
	local tmp = dir .. ".tmp"
	local script = table.concat({
		"rm -rf " .. shq(tmp) .. " " .. shq(dir),
		"git -c core.autocrlf=false clone -n --depth=1 --filter=blob:none " .. shq(url) .. " " .. shq(tmp),
		"git -C " .. shq(tmp) .. " sparse-checkout set --no-cone " .. table.concat(vim.tbl_map(shq, vim.split(sparse, " ", { trimempty = true })), " "),
		"git -C " .. shq(tmp) .. " checkout",
		"mv " .. shq(tmp) .. " " .. shq(dir),
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
		-- All AFL++ docs across the repo: the mode docs (qemu/unicorn/frida/nyx/
		-- coresight), instrumentation, custom mutators, utils. (The submodules
		-- are the QEMU/Unicorn/Frida forks, covered by their own providers.)
		url = "https://github.com/AFLplusplus/AFLplusplus",
		sparse = "/docs /instrumentation /qemu_mode /unicorn_mode /frida_mode /nyx_mode /coresight_mode /custom_mutators /utils /dictionaries",
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
		-- Upstream /docs/*.md are just redirect stubs to docs.qiling.io; the real,
		-- runnable documentation is the example scripts, so browse those.
		url = "https://github.com/qilingframework/qiling",
		sparse = "/examples",
		marker = "examples",
		browse = "/examples",
		exts = "-e py -e md -e rst -e txt",
		prompt = "Qiling example> ",
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
		-- The LibAFL Book (docs/src), the example fuzzers, and every crate's
		-- own docs/README (libafl, libafl_bolts, libafl_qemu, libafl_asan, …).
		url = "https://github.com/AFLplusplus/LibAFL",
		sparse = "/docs/src /docs/listings /fuzzers /crates", -- listings: the book's {{#include}} targets
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
	armtf = {
		-- Arm Trusted Firmware-A: EL3/secure world, PSCI, SMCCC, boot flow.
		url = "https://github.com/ARM-software/arm-trusted-firmware",
		sparse = "/docs",
		marker = "docs",
		browse = "/docs",
		exts = "-e rst -e md",
		prompt = "Arm TF-A> ",
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
		-- The low-level eBPF ABI reference (ebpf-docs.dylanreimerink.nl): a page
		-- per helper function, kfunc, map type, program type, program context,
		-- and the bpf() syscall. (Cilium = architecture/XDP/tc guide; Aya = Rust.)
		url = "https://github.com/isovalent/ebpf-docs",
		sparse = "/docs",
		marker = "docs",
		browse = "/docs",
		exts = "-e md",
		prompt = "eBPF helpers/maps/program-types> ",
	},
	aya = {
		-- The Aya book (aya-rs.dev): writing eBPF programs in Rust. /examples holds
		-- the tutorial code the pages pull in via mdBook {{#include}} (expanded at
		-- render time by expand_includes), so browse /src but fetch both.
		url = "https://github.com/aya-rs/book",
		sparse = "/src /examples",
		marker = "src",
		browse = "/src",
		exts = "-e md",
		prompt = "Aya (Rust eBPF)> ",
	},
	cilium = {
		-- Cilium's BPF and XDP Reference Guide (architecture, instruction set,
		-- maps, helpers, tail calls, JIT, hardening, XDP, tc, toolchain, ...).
		url = "https://github.com/cilium/cilium",
		sparse = "/Documentation/reference-guides/bpf",
		marker = "Documentation/reference-guides/bpf",
		browse = "/Documentation/reference-guides/bpf",
		exts = "-e rst",
		prompt = "eBPF (Cilium Reference)> ",
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
		local dir = data_root .. "/" .. name .. "/master"
		-- An already-cloned doc set browses without git (offline, or git missing).
		if vim.fn.isdirectory(dir .. "/" .. spec.marker) == 1 then
			return pick_files(dir .. spec.browse, spec.exts, spec.prompt)
		end
		if not have("git") then
			return vim.notify("git not found (needed to fetch " .. name .. " docs)", vim.log.levels.WARN)
		end
		ensure_repo(dir, spec.url, spec.sparse, spec.marker, function(d)
			pick_files(d .. spec.browse, spec.exts, spec.prompt)
		end)
	end
end

-- Some projects keep their real docs in a GitHub *wiki* (a flat separate repo,
-- <repo>.wiki.git) where sparse-checkout-by-path doesn't help: shallow-clone it whole.
local function make_wiki(name, url, prompt)
	return function()
		if not (have("git") and have("fd")) then
			return vim.notify("git and fd are needed for " .. name, vim.log.levels.WARN)
		end
		local dir = data_root .. "/" .. name .. "/wiki"
		local function browse()
			pick_files(dir, "-e md -e rst -e org -e txt", prompt)
		end
		if #vim.fn.glob(dir .. "/*.md", false, true) > 0 then
			return browse()
		end
		mkdir(vim.fs.dirname(dir))
		vim.notify("Cloning " .. name .. " wiki … (first time)")
		-- Clone into <dir>.tmp and rename, so an interrupted clone never leaves
		-- a partial dir that makes every retry fail with "already exists".
		local tmp = dir .. ".tmp"
		vim.fn.delete(tmp, "rf")
		-- rm -rf the destination too: without it `mv` nests the new clone
		-- inside a leftover directory and every retry then fails.
		vim.system(
			{ "sh", "-c", 'rm -rf "$3" && git clone --depth=1 "$1" "$2" && mv "$2" "$3"', "wiki", url, tmp, dir },
			{ text = true, timeout = 120000 },
			function(res)
			vim.schedule(function()
				if #vim.fn.glob(dir .. "/*.md", false, true) > 0 then
					browse()
				else
					vim.notify(name .. " wiki clone failed:\n" .. (res.stderr or ""):sub(1, 200), vim.log.levels.ERROR)
				end
			end)
		end)
	end
end

-- gs from a docs buffer: explore that project's full source (config.src) in
-- the same split the docs occupy; `:q` on the source restores the doc there.
-- Skip only non-code dirs for the kernel (keep every arch + driver: the user
-- does cross-arch and driver work).
local KERNEL_EXCLUDE = { "Documentation", "samples", "tools", "scripts" }
-- Non-`simple` providers whose docs still have a real upstream source repo, so
-- gs works from them too (doxygen libs, sqlite, rust, ghidra, the bap wiki).
local SRC_URLS = {
	libdrgn = "https://github.com/osandov/drgn",
	sfml = "https://github.com/SFML/SFML",
	sqlite = "https://github.com/sqlite/sqlite",
	rust = "https://github.com/rust-lang/rust",
	bap = "https://github.com/BinaryAnalysisPlatform/bap",
	ghidra = "https://github.com/NationalSecurityAgency/ghidra",
}
-- Providers whose useful source is a different repo than their doc set: aya's
-- docs are the book, but "explore the source" means the crate itself.
local GS_OVERRIDE = {
	aya = "https://github.com/aya-rs/aya",
}
-- Books whose companion source is a real upstream repo worth exploring. Every
-- book's docs cache lives under docs/books/<key>/<slug>, so the shared "books"
-- path segment can't identify the repo; key on the slug instead.
local BOOK_SRC = {
	["xv6-x86"] = "https://github.com/mit-pdos/xv6-public",
}
gs_source = function(dir)
	if not dir then
		return
	end
	local srcname, url, excl
	-- First path segment under the docs cache is the provider name (simple
	-- providers live at <name>/master, others at <name>/… or <name>/<ver>).
	local name = dir:match("/docs/([^/]+)")
	if name == "books" then
		-- Books share the "books" segment; resolve the per-book repo by slug.
		local slug = dir:match("/docs/books/[^/]+/([^/]+)")
		if slug and BOOK_SRC[slug] then
			srcname, url = slug, BOOK_SRC[slug]
		end
	elseif name and GS_OVERRIDE[name] then
		srcname, url = name, GS_OVERRIDE[name]
	elseif name and simple[name] then
		srcname, url = name, simple[name].url
	elseif name == "linux" then
		srcname, url, excl = "linux", repo, KERNEL_EXCLUDE
	elseif name and SRC_URLS[name] then
		srcname, url = name, SRC_URLS[name]
	end
	if not url then
		return vim.notify("Source explorer: no git source for this doc set", vim.log.levels.INFO)
	end
	local buf = vim.api.nvim_get_current_buf()
	local restore = {
		lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false),
		ft = vim.bo[buf].filetype,
		title = vim.api.nvim_buf_get_name(buf):match("([^/]+)$") or "doc",
	}
	require("config.src").open(srcname, url, function()
		render_lines(restore.lines, restore.ft, dir, restore.title)
	end, excl)
end

-- ── doxygen providers: doxygen (XML) -> moxygen -> per-class/group Markdown ─
-- For libraries whose API lives in Doxygen-commented C/C++ headers (libdrgn,
-- SFML). Downloads a prebuilt doxygen binary on first use; moxygen (npm) turns
-- the XML into cross-linked per-class/per-group Markdown, browsed like the rest.
local tools_dir = data_root .. "/.tools"
-- Local book library (epub/pdf): converted chapters live under books_root, and
-- the source files are copied out of the ephemeral /tmp into books_src so the
-- providers keep working after a reboot.
-- Books are pre-built and committed under Resources/docs/books (read directly).
local books_root = frozen_root .. "/books"

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
			{ "sh", "-c", tool_script("dox_pipeline.sh"), "dox", dir .. input, md, tools_dir, patterns },
			-- cwd on the clone (never the nvim repo), so any stray relative
			-- output can only land in the throwaway cache, not the config repo.
			{ text = true, timeout = 300000, cwd = dir },
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

-- ── Intel SDM: download the PDF, split by chapter into text + figures ─────
-- The manuals aren't published as markdown, so fetch the latest PDF and
-- pdftotext -layout each chapter (page ranges from the PDF outline) into
-- per-chapter text files, stripping running headers/footers and form feeds.
-- Figures (vector diagrams) are then cropped to PNGs via Resources/tools/figextract.py so
-- <CR> on a "Figure N-M" line shows the diagram inline (snacks.image).

local SDM = "https://www.intel.com/content/dam/www/public/us/en/documents/manuals/"
local SDM_URLS = {
	[1] = SDM .. "64-ia-32-architectures-software-developer-vol-1-manual.pdf",
	[2] = SDM .. "64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf",
	[3] = SDM .. "64-ia-32-architectures-software-developer-system-programming-manual-325384.pdf",
	[4] = "https://www.intel.com/content/dam/develop/external/us/en/documents/335592-sdm-vol-4.pdf",
}

local function pick_sdm(vol)
	local out = data_root .. "/sdm/vol" .. vol
	local pdf = tools_dir .. "/sdm-vol" .. vol .. ".pdf"
	local function browse()
		pick_files(out, "-e txt", "Intel SDM v" .. vol .. "> ")
	end
	-- Browse a built cache first; the fetch/split tools are only needed to build.
	if vim.fn.filereadable(out .. "/.complete") == 1 then
		return browse()
	end
	for _, t in ipairs({ "curl", "mutool", "pdftotext", "pdfinfo" }) do
		if not have(t) then
			return vim.notify(t .. " needed to build Intel SDM", vim.log.levels.WARN)
		end
	end
	mkdir(out)
	local py = tools_src .. "/figextract.py" -- committed under Resources/tools, no runtime copy
	mkdir(tools_dir) -- the downloaded PDF lands here
	vim.notify("Fetching + splitting Intel SDM Vol " .. vol .. " … (first time; figures take a minute)")
	vim.system(
		{ "sh", "-c", tool_script("sdm_build.sh"), "sdm", pdf, out, SDM_URLS[vol], py },
		{ text = true, timeout = 600000 },
		function(res)
			vim.schedule(function()
				if vim.fn.filereadable(out .. "/.complete") == 1 then
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
-- Web pages fetched over the network are the one slow interactive path (curl +
-- pandoc is seconds, and every open refetched it). `cache_key`, when given,
-- serves the previously rendered result from disk instantly and works offline;
-- `:Docs update` clears this cache so pages can be refreshed on demand.
local webcache_dir = data_root .. "/.webcache"
render_shell = function(cmd, title, ft, cache_key)
	render_seq = render_seq + 1
	local myseq = render_seq -- a later open supersedes this fetch's render
	-- Locally generated pages (man, cppman) live in a `local/` subdir that
	-- :Docs update always clears, even offline; fetched web pages are only
	-- cleared after a successful update so they keep working offline.
	local sub = (cache_key and cache_key:match("^man:") or cache_key and cache_key:match("^cppman:")) and "/local" or ""
	local cf = cache_key and (webcache_dir .. sub .. "/" .. vim.fn.sha256(cache_key) .. ".txt")
	if cf and vim.fn.filereadable(cf) == 1 then
		local cached = vim.fn.readfile(cf)
		if #cached > 0 then
			return render_lines(cached, ft or "man", nil, title)
		end
	end
	-- 60 s cap: an unreachable host otherwise hung the fetch for minutes.
	-- coreutils timeout signals the whole process group, so curl/pandoc die
	-- with the shell and stdout closes (vim.system's own timeout only killed
	-- the sh, and the callback waited until curl gave up, 70-140 s later).
	local argv = have("timeout") and { "timeout", "60", "sh", "-c", cmd } or { "sh", "-c", cmd }
	vim.system(argv, { text = true, timeout = 65000 }, function(res)
		vim.schedule(function()
			local out = vim.split(res.stdout or "", "\n")
			while #out > 0 and out[#out]:match("^%s*$") do
				out[#out] = nil
			end
			if #out == 0 then
				local err = res.stderr ~= "" and res.stderr or ("Nothing for " .. title)
				return vim.notify(err, vim.log.levels.WARN)
			end
			-- Only cache a clean exit: a `timeout` kill (124) or a failing tool
			-- can still have written a partial page, and caching that would
			-- serve the truncation forever.
			if cf and res.code == 0 then
				pcall(function()
					mkdir(vim.fs.dirname(cf), true)
					vim.fn.writefile(out, cf)
				end)
			end
			if myseq ~= render_seq then
				return -- superseded by a later open; do not clobber the viewer
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
	-- Streamed straight into fzf as a shell command (like the fd browsers), not
	-- collected with systemlist first: apropos over a full manpath blocked the
	-- UI for 30-50 ms per open. When the apropos database is missing (no
	-- mandb run), fall back to listing the manpath directories.
	local cmd = ("apropos -s %s . 2>/dev/null | sort -u | grep . || { for d in $(manpath 2>/dev/null | tr ':' ' '); do ls \"$d/man%s\" 2>/dev/null; done | sed 's/\\.[0-9].*$//' | sort -u; }"):format(
		section,
		section
	)
	fzf().fzf_exec(cmd, {
		prompt = "man " .. section .. "> ",
		fzf_opts = { ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				local name = sel and sel[1] and sel[1]:match("^(%S+)")
				if name then
					-- Cached by page: big pages (bash(1)) take ~125 ms to format;
					-- :Docs update clears the cache after a package update.
					render_shell(
						"MANWIDTH=90 man " .. section .. " " .. shq(name) .. " 2>/dev/null | col -bx",
						name .. "(" .. section .. ")",
						nil,
						"man:" .. section .. ":" .. name
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
		render_shell(
			bin .. " --force-columns=90 " .. shq(sym) .. " 2>/dev/null | col -bx",
			"cppman " .. sym,
			"man",
			"cppman:" .. sym
		)
	end
	-- cppman's index is a SQLite db with one "<source>_keywords" table of
	-- searchable symbol names. Dump those for the picker (read-only), streamed
	-- into fzf rather than collected first (the dump blocked the UI ~45 ms).
	local db = vim.fn.expand("~/.cache/cppman/index.db")
	if vim.fn.filereadable(db) == 1 and have("python3") then
		local py = "import sqlite3,sys\n"
			.. "c=sqlite3.connect('file:'+sys.argv[1]+'?mode=ro',uri=True)\n"
			.. "s=set()\n"
			.. "for tbl in [r[0] for r in c.execute(\"SELECT name FROM sqlite_master WHERE type='table'\")]:\n"
			.. "  if not tbl.endswith('_keywords'): continue\n"
			.. "  try:\n"
			.. "    for r in c.execute('SELECT keyword FROM \"%s\"' % tbl):\n"
			.. "      k=(r[0] or '').strip()\n"
			.. "      if len(k)>1 and not k.startswith('('): s.add(k)\n"
			.. "  except Exception: pass\n"
			.. "print('\\n'.join(sorted(s)))"
		fzf().fzf_exec("python3 -c " .. shq(py) .. " " .. shq(db), {
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
		fzf().fzf_exec("fd --base-directory " .. shq(mandir) .. " --type f .", {
			prompt = "NetBSD (" .. section .. ")> ",
			cwd = mandir,
			fzf_opts = { ["--no-multi"] = true },
			actions = {
				["default"] = function(sel)
					if sel and sel[1] then
						local f = mandir .. "/" .. sel[1]
						render_shell("MANWIDTH=90 man -l " .. shq(f) .. " 2>/dev/null | col -bx", vim.fs.basename(sel[1]), "man")
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
		-- rfc2396, not the rfc3986 default: the latter leaves &, +, = and ; raw,
		-- so searching for "&&" or "(+)" built a malformed query.
		local url = "https://hoogle.haskell.org/?hoogle=" .. vim.uri_encode(q, "rfc2396") .. "&mode=json&count=100"
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
local OCAML_IDX = [[curl -fsSL https://ocaml.org/api/index_modules.html | grep -oE 'href="[A-Z][A-Za-z0-9_]*\.html"' | sed -E 's/.*"([^"]+)\.html".*/\1/' | sort -u]]

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
							"curl -fsSL " .. shq("https://ocaml.org/api/" .. sel[1] .. ".html")
								.. " | pandoc -f html -t gfm-raw_html --wrap=none 2>/dev/null | awk 'f||/OCaml library/{f=1}f'",
							"OCaml." .. sel[1],
							"markdown",
							"ocaml:" .. sel[1]
						)
					end
				end,
			},
		})
	end
	if vim.fn.filereadable(idxfile) == 1 then
		return browse()
	end
	if not mkdir(dir) then
		return
	end
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

-- ── Aya (Rust eBPF) crate API: browse rustdoc on docs.rs ─────────────────
-- The book (provider `aya`) is the tutorial; this is the crate reference. Like
-- the kernel provider it is a submenu: pick a module, then an item, then the
-- rustdoc page renders (cached web-fetch, chrome trimmed at the first heading).
-- Index line = "module<TAB>kind Name<TAB>href".
local AYA_API = "https://docs.rs/aya/latest/aya/"

local function pick_aya_api()
	if not (have("curl") and have("pandoc")) then
		return vim.notify("curl and pandoc are needed for the Aya API docs", vim.log.levels.WARN)
	end
	local dir = data_root .. "/aya-api"
	local idxfile = dir .. "/items.tsv"

	local function render_item(href, title)
		local url = AYA_API .. href
		render_shell(
			"curl -fsSL " .. shq(url)
				.. " | pandoc -f html -t gfm-raw_html --wrap=none 2>/dev/null | awk 'f||/^## /{f=1}f'",
			title,
			"markdown",
			url
		)
	end

	-- second level: the items within one module.
	local function items_in(mod, items)
		local sub = {}
		for _, line in ipairs(items) do
			if line:match("^([^\t]+)") == mod then
				sub[#sub + 1] = line
			end
		end
		fzf().fzf_exec(sub, {
			prompt = mod .. "> ",
			fzf_opts = { ["--with-nth"] = "2", ["--delimiter"] = "\\t", ["--no-multi"] = true },
			actions = {
				["default"] = function(sel)
					if not (sel and sel[1]) then
						return
					end
					local label, href = sel[1]:match("^[^\t]+\t([^\t]+)\t(.+)$")
					if href then
						render_item(href, mod .. "::" .. (label:match("%S+%s+(%S+)") or label))
					end
				end,
			},
		})
	end

	-- first level: the module list.
	local function modules_menu(items)
		last_picker = function() modules_menu(items) end -- D returns to the module list
		local mods, seen = {}, {}
		for _, line in ipairs(items) do
			local m = line:match("^([^\t]+)\t")
			if m and not seen[m] then
				seen[m] = true
				mods[#mods + 1] = m
			end
		end
		table.sort(mods)
		fzf().fzf_exec(mods, {
			prompt = "Aya module> ",
			fzf_opts = { ["--no-multi"] = true },
			actions = {
				["default"] = function(sel)
					if sel and sel[1] then
						items_in(sel[1], items)
					end
				end,
			},
		})
	end

	if vim.fn.filereadable(idxfile) == 1 then
		return modules_menu(vim.fn.readfile(idxfile))
	end
	if not mkdir(dir) then
		return
	end
	vim.notify("Fetching the Aya API index (docs.rs) … (first time)")
	vim.system({ "sh", "-c", tool_script("aya_api_idx.sh") }, { text = true, timeout = 30000 }, function(res)
		vim.schedule(function()
			local items = vim.split(res.stdout or "", "\n", { trimempty = true })
			if #items == 0 then
				return vim.notify("Aya API: could not fetch the item index from docs.rs", vim.log.levels.WARN)
			end
			vim.fn.writefile(items, idxfile)
			modules_menu(items)
		end)
	end)
end

-- ── site-scraped tutorials: learncpp.com, rayanfam.com ───────────────────
-- No git repo, so fetch the index page, list its links, and render a picked
-- page's main article. A small bs4 helper extracts just the content container
-- (dropping nav, scripts, and the reader-comment section) before pandoc, and
-- results are cached like the other web-fetch providers.

-- opts: name, index_url, link_filter, base, content_sel, prompt
-- learncpp.com and Hypervisor From Scratch are static content; their rendered
-- articles are committed under Resources/docs (index.tsv + .webcache/<sha>.txt),
-- so the picker reads them offline - no curl/pandoc, no fetch.
local function frozen_web_provider(name, prompt)
	return function()
		local idxfile = frozen_root .. "/" .. name .. "/index.tsv"
		if vim.fn.filereadable(idxfile) ~= 1 then
			return vim.notify(name .. ": frozen index missing", vim.log.levels.WARN)
		end
		local function browse()
			last_picker = browse -- D reopens the index
			fzf().fzf_exec(vim.fn.readfile(idxfile), {
				prompt = prompt,
				fzf_opts = { ["--with-nth"] = "1", ["--delimiter"] = "\\t", ["--no-multi"] = true },
				actions = {
					["default"] = function(sel)
						if not (sel and sel[1]) then
							return
						end
						local title, url = sel[1]:match("^([^\t]+)\t(.+)$")
						if not url then
							return
						end
						local cf = frozen_root .. "/.webcache/" .. vim.fn.sha256(url) .. ".txt"
						if vim.fn.filereadable(cf) == 1 then
							render_lines(vim.fn.readfile(cf), "markdown", nil, title)
						else
							vim.notify(title .. ": not in the frozen cache", vim.log.levels.WARN)
						end
					end,
				},
			})
		end
		browse()
	end
end

-- learncpp.com: the full C++ tutorial (356 lessons), lesson body only.
local pick_learncpp = frozen_web_provider("learncpp", "Learn C++ lesson> ")
-- rayanfam.com: the full Hypervisor From Scratch series (8 parts).
local pick_rayanfam = frozen_web_provider("rayanfam", "Hypervisor From Scratch> ")

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
						mkdir(vim.fs.dirname(dir))
						vim.notify("Cloning Ghidra " .. tag .. " docs … (first time)")
						-- Kill-atomic (tmp+mv), like ensure_repo/ensure_docs, so a
						-- checkout killed midway never leaves a partial tree whose
						-- marker dir makes the next run treat it as complete.
						local tmp = dir .. ".tmp"
						local script = table.concat({
							"rm -rf " .. shq(tmp) .. " " .. shq(dir),
							"git -c core.autocrlf=false clone -n --depth=1 --filter=blob:none --branch " .. shq(tag) .. " " .. repo .. " " .. shq(tmp),
							"git -C " .. shq(tmp) .. " sparse-checkout set --no-cone /GhidraDocs /Ghidra/Processors/x86/data/languages",
							"git -C " .. shq(tmp) .. " checkout",
							"mv " .. shq(tmp) .. " " .. shq(dir),
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
					render_shell("curl -fsSL " .. shq(specs[sel[1]]) .. " | pandoc -f html -t gfm-raw_html --wrap=none 2>/dev/null", sel[1], "markdown", specs[sel[1]])
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
	-- Streamed into fzf; collecting it first blocked the UI for ~35 ms.
	local py = "import pkgutil,sys; print(chr(10).join(sorted(set([m.name for m in pkgutil.iter_modules()] + list(sys.builtin_module_names)))))"
	fzf().fzf_exec("python3 -c " .. shq(py), {
		prompt = "pydoc> ",
		fzf_opts = { ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				if sel and sel[1] then
					render_shell("python3 -m pydoc " .. shq(sel[1]) .. " 2>&1", "pydoc " .. sel[1], "text")
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
	-- Every git clone under the cache, whatever its layout (<name>/master, a
	-- flat <name>, <name>/<version>, rust/<book>, bap/wiki, android-kernel/
	-- <branch>): glob depth 1..3 and dedupe, so nothing is silently skipped.
	-- The source clones :Src makes live in a sibling tree and are caches of
	-- upstream just as much as the doc repos, so update them too.
	local src_root = vim.fn.stdpath("data") .. "/src"
	local repos, seen = {}, {}
	for _, root in ipairs({ data_root, src_root }) do
		for _, glob in ipairs({ "/*", "/*/*", "/*/*/*" }) do
			for _, d in ipairs(vim.fn.glob(root .. glob, false, true)) do
				-- <dir>.tmp is an in-flight clone (renamed into place when done).
				if not seen[d] and not d:match("%.tmp$") and vim.fn.isdirectory(d .. "/.git") == 1 then
					seen[d] = true
					repos[#repos + 1] = d
				end
			end
		end
	end
	-- Cached man/cppman renders are regenerated locally, so drop them now
	-- (a package update changes the pages), whatever happens to the repos.
	pcall(vim.fn.delete, webcache_dir .. "/local", "rf")
	if #repos == 0 then
		return vim.notify("No cached doc repos to update yet (man page cache cleared)", vim.log.levels.INFO)
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
						-- Only now drop the cached web pages so they refetch fresh; an
						-- offline or failed update must never wipe what still works.
						-- Converted markdown is keyed by source mtime, so a pull
						-- invalidates exactly the changed files; just prune entries
						-- untouched for 90 days instead of re-converting whole doc sets.
						pcall(vim.fn.delete, webcache_dir, "rf")
						vim.system({ "find", convcache_dir, "-type", "f", "-mtime", "+90", "-delete" }, {}, function() end)
						prewarm_done = {} -- pulled sets get re-warmed (only changed files convert)
						-- Derived indexes are built once from a tree's contents and
						-- then reused forever, so a pull would otherwise leave them
						-- describing the old checkout. Drop them; each rebuilds on
						-- its next use.
						pcall(vim.fn.delete, tags_cache)
						for _, idx in ipairs(vim.fn.glob(data_root .. "/*/api-index.tsv", false, true)) do
							pcall(vim.fn.delete, idx)
						end
						for _, idx in ipairs(vim.fn.glob(data_root .. "/*/*/api-index.tsv", false, true)) do
							pcall(vim.fn.delete, idx)
						end
						pcall(vim.fn.delete, data_root .. "/ocaml/modules.txt")
						pcall(vim.fn.delete, data_root .. "/aya-api/items.tsv")
						-- ctags indexes of the source clones, now that those are
						-- pulled above; each rebuilds on the next gs.
						for _, t in ipairs(vim.fn.glob(src_root .. "/*/.srctags", false, true)) do
							pcall(vim.fn.delete, t)
						end
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
		render_shell("MANWIDTH=90 " .. cmd .. " 2>/dev/null | col -bx", title, "man", "man:" .. cmd)
	end
end

-- ── generic chaptered-PDF provider (C/C++ ISO working drafts) ────────────
-- Same idea as the Intel SDM: fetch the PDF, split by the PDF outline into
-- per-clause text files (pdftotext -layout), stripping the ISO running
-- header / page numbers. Browsable, and <leader>fs gives the clause TOC.

local STD_URLS = {
	["c-draft"] = "https://www.open-std.org/jtc1/sc22/wg14/www/docs/n3220.pdf",
	["cpp-draft"] = "https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf",
	["dwarf5"] = "https://dwarfstd.org/doc/DWARF5.pdf",
	["x86-64-abi"] = "https://gitlab.com/x86-psABIs/x86-64-ABI/-/jobs/artifacts/master/raw/x86-64-ABI/abi.pdf?job=build",
	["riscv"] = "https://github.com/riscv/riscv-isa-manual/releases/latest/download/riscv-spec.pdf",
	["arm-a"] = "https://www.cs.princeton.edu/courses/archive/fall19/cos217/reading/ArmArchitectureReferenceManual.pdf",
	["arm-m"] = "https://community.arm.com/cfs-file/__key/communityserver-discussions-components-files/471/DDI0553B_5F00_y_5F00_armv8m_5F00_arm.pdf",
}

local function pick_pdf(name, prompt)
	local out = data_root .. "/std/" .. name
	local pdf = tools_dir .. "/" .. name .. ".pdf"
	local function browse()
		pick_files(out, "-e txt", prompt)
	end
	-- Browse a built cache first; the fetch/split tools are only needed to build.
	if vim.fn.filereadable(out .. "/.complete") == 1 then
		return browse()
	end
	for _, t in ipairs({ "curl", "mutool", "pdftotext", "pdfinfo" }) do
		if not have(t) then
			return vim.notify(t .. " needed to build " .. name, vim.log.levels.WARN)
		end
	end
	mkdir(out)
	vim.notify("Fetching + splitting " .. name .. " … (first time)")
	vim.system({ "sh", "-c", tool_script("pdf_build.sh"), "pdf", pdf, out, STD_URLS[name] }, { text = true, timeout = 900000 }, function(res)
		vim.schedule(function()
			if vim.fn.filereadable(out .. "/.complete") == 1 then
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
	-- /libiberty/at-file.texi: the GCC user manual (gcc.texi) @includes it via srcdir.
	ensure_repo(data_root .. "/gcc", "https://github.com/gcc-mirror/gcc", "/gcc/doc /libiberty/at-file.texi", "gcc/doc", function(d)
		fzf().fzf_exec(vim.tbl_keys(docs), {
			prompt = "GCC docs> ",
			fzf_opts = { ["--no-multi"] = true },
			actions = {
				["default"] = function(sel)
					if not (sel and sel[1] and docs[sel[1]]) then
						return
					end
					local cmd = table.concat({
						"cd " .. shq(d .. "/gcc/doc"),
						-- @set srcdir ..: gcc.texi's invoke.texi does `@include @value{srcdir}/../libiberty/at-file.texi`;
						-- srcdir=.. (the repo's gcc/ dir, from gcc/doc) makes that resolve, else makeinfo aborts empty.
						"printf '@set version-GCC 15.0.0\\n@set BUGURL https://gcc.gnu.org/bugs/\\n@clear DEVELOPMENT\\n@set srcdir ..\\n' > gcc-vers.texi",
						"makeinfo --no-split --plaintext -I include " .. shq(docs[sel[1]]),
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
						mkdir(vim.fs.dirname(dir))
						vim.notify("Cloning Android kernel " .. br .. " … (first time)")
						-- Kill-atomic (tmp+mv), like ensure_repo/ensure_docs.
						local tmp = dir .. ".tmp"
						local script = table.concat({
							"rm -rf " .. shq(tmp) .. " " .. shq(dir),
							"git -c core.autocrlf=false clone -n --depth=1 --filter=blob:none --branch " .. shq(br) .. " " .. repo .. " " .. shq(tmp),
							"git -C " .. shq(tmp) .. " sparse-checkout set --no-cone " .. table.concat(vim.tbl_map(shq, vim.split(sparse, " ", { trimempty = true })), " "),
							"git -C " .. shq(tmp) .. " checkout",
							"mv " .. shq(tmp) .. " " .. shq(dir),
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
-- The Rust *reference* (the rust-lang books moved to Books -> Rust).
local function pick_rust()
	if not (have("git") and have("fd")) then
		return vim.notify("git and fd are needed for the Rust reference", vim.log.levels.WARN)
	end
	ensure_repo(data_root .. "/rust/reference", "https://github.com/rust-lang/reference", "/src", "src", function(d)
		pick_files(d .. "/src", "-e md", "Rust reference> ")
	end)
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
					render_shell("MANWIDTH=90 man " .. shq(sel[1]) .. " 2>/dev/null | col -bx", sel[1] .. "(1)", "man")
				end
			end,
		},
	})
end

-- ── SQLite C API: the fully-documented sqlite3.h header (rendered as C) ──
local function pick_sqlite()
	if not have("git") then
		return vim.notify("git needed for the SQLite API", vim.log.levels.WARN)
	end
	ensure_repo(data_root .. "/sqlite", "https://github.com/sqlite/sqlite", "/src/sqlite.h.in", "src", function(d)
		local f = d .. "/src/sqlite.h.in"
		if vim.fn.filereadable(f) == 1 then
			render_lines(vim.fn.readfile(f), "c", vim.fs.dirname(f), "sqlite3.h (C API)")
		else
			vim.notify("sqlite header not found", vim.log.levels.WARN)
		end
	end)
end

-- ── local book library (epub/pdf), grouped by subject module ─────────────
-- One :Docs entry per module (books-<key>): pick a book, then a chapter. epub
-- is preferred over pdf when a book exists as both (reflowed text/code splits
-- into cleaner chapters). Duplicate copies are collapsed to one file.
local BOOKS = {
	{ module = "C", key = "books-c", items = {
		{ title = "Expert C Programming", fmt = "epub", file = "Expert C Programming -- Peter van der Linden -- 2002 -- 6a6a0df494fc411c9842373f70197e46 -- Anna’s Archive.epub" },
	} },
	{ module = "C++", key = "books-cpp", items = {
		{ title = "Beautiful C++ (30 Core Guidelines)", fmt = "pdf", file = "Beautiful C++ _ 30 Core Guidelines for Writing Clean, Safe, -- J_ Guy Davidson & Kate Gregory -- 1, 2021 -- Pearson Education, Limited; Addison-Wesley -- 9780137647842 -- 3d6251a17d7996d9091349de.pdf" },
		{ title = "C++ Move Semantics (The Complete Guide)", fmt = "pdf", file = "C++ Move Semantics - The Complete Guide -- Nicolai M_ Josuttis -- 2022 -- c6f2c4fe3e0701d95a17354ad517147a -- Anna’s Archive.pdf" },
		{ title = "C++ Initialization Story", fmt = "epub", file = "C__ Initialization Story - Bartłomiej Filipek.epub" },
		{ title = "C++ Templates: The Complete Guide (2e)", fmt = "pdf", file = "CppTemplates-CompleteGuide-2e.pdf" },
		{ title = "Effective Modern C++", fmt = "epub", file = "Effective-Modern-C-.epub" },
	} },
	{ module = "Rust", key = "books-rust", items = {
		{ title = "Command-Line Rust", fmt = "epub", file = "Command-line Rust _ a project-based primer for writing Rust -- Ken Youens-Clark -- 2024 Updated Edition, 2024 -- O'Reilly Media, Incorporated; -- 9781098109400 -- 462825f45d6c0c1f3254f43a9f8062ee -- Anna’s Archive.epub" },
		{ title = "Programming Rust (2e)", fmt = "epub", file = "Programming Rust_ Fast, Safe Systems Development, -- Jim Blandy & Jason Orendorff & Leonora F _ S_ Tindall -- 2nd Edition, 2021 -- O'Reilly Media -- 42c3a550a65cf7d0fe19185d1c57c56e -- Anna’s Archive.epub" },
		{ title = "Rust in Action", fmt = "epub", file = "Rust_In_Action.epub" },
		{ title = "The Rust Programming Language (the book)", fmt = "mdbook", url = "https://github.com/rust-lang/book" },
		{ title = "The Rustonomicon (unsafe Rust)", fmt = "mdbook", url = "https://github.com/rust-lang/nomicon" },
		{ title = "Rust by Example", fmt = "mdbook", url = "https://github.com/rust-lang/rust-by-example" },
		{ title = "Learn Rust With Entirely Too Many Linked Lists", fmt = "mdbook", url = "https://github.com/rust-unofficial/too-many-lists" },
	} },
	{ module = "Operating Systems", key = "books-os", items = {
		{ title = "Operating Systems: Three Easy Pieces", fmt = "pdf", file = "OSTEP.pdf" },
		{ title = "xv6 (x86)", fmt = "epub", file = "x86-xv6.epub" },
		{ title = "Advanced Programming in the UNIX Environment", fmt = "pdf", file = "Advanced Programming in the UNIX Environment.pdf" },
		{ title = "System Programming in Linux", fmt = "epub", file = "System-Programming-in-Linux_-A-Hands-On-Introduction-Stewart-N_-Weiss-2025-No-Starch-Press_-Incorpor.epub" },
		{ title = "Unix Network Programming", fmt = "pdf", file = "Unix-Network-Programming.pdf" },
	} },
	{ module = "Compilers", key = "books-compilers", items = {
		{ title = "Crafting Interpreters", fmt = "epub", file = "Crafting Interpreters -- Robert Nystrom -- United States_] _, 2021 -- Genever Benning -- isbn13 9780990582939 -- c96d09f7d0933fc5c9b75228f7f3e2a3 -- Anna’s Archive.epub" },
		{ title = "Writing a C Compiler", fmt = "epub", file = "WritingaCCompiler.epub" },
		{ title = "SSA-based Compiler Design", fmt = "pdf", file = "Fabrice Rastello, Florent Bouchez Tichadou - SSA-based Compiler Design-Springer (2022).pdf" },
	} },
	{ module = "Databases", key = "books-db", items = {
		{ title = "Database Internals", fmt = "epub", file = "Database Internals _ A Deep Dive Into How Distributed Data -- Alex  Petrov -- O'Reilly Media, Sebastopol, CA, 2019 -- O'Reilly Media, Incorporated -- 9781492040316 -- 6ed4b5c9518da1d5ff76d1cd6c3aa813 -- Anna’s Arc.epub" },
	} },
	{ module = "Linux / Drivers", key = "books-linux", items = {
		{ title = "Linux Device Driver Development (Madieu)", fmt = "epub", file = "Linux Device Driver Development_ Everything you need to -- John Madieu -- Packt Publishing, [Place of publication not identified], -- Packt -- isbn13 9781803235943 -- e409561761c67e6644a54ed53a248850 -- Anna’s (1).epub" },
		{ title = "Linux Device Drivers, 3rd Edition", fmt = "epub", file = "Linux Device Drivers, 3rd Edition -- Jonathan Corbet, Alessandro Rubini, and Greg Kroah-Hartman -- 3rd Edition, 2009 -- O'Reilly Media, Incorporated -- isbn13 9780596159740 -- f4346a4d961cc1b0cb12d88c75e50c50 -- A.epub" },
		{ title = "The Linux Memory Manager", fmt = "epub", file = "The Linux Memory Manager - Lorenzo Stoakes.epub" },
		{ title = "Bootlin: Embedded Linux (BBB labs)", fmt = "epub", file = "bootlin-embedded-linux-bbb-labs.epub" },
		{ title = "Bootlin: Linux Kernel (slides)", fmt = "epub", file = "bootlin-linux-kernel-slides.epub" },
		{ title = "Bootlin: Embedded Linux (QEMU labs)", fmt = "epub", file = "embedded-linux-qemu-labs.epub" },
	} },
	{ module = "Algorithms", key = "books-algo", items = {
		{ title = "Algorithms Illuminated, Part 2", fmt = "epub", file = "Algorithms Illuminated (Part 2)_ Graph Algorithms and Data -- Tim Roughgarden -- First edition, San Francisco, CA, 2018 -- Soundlikeyourself -- 9780999282908 -- 60673f61ed5b43af2525a40cf00038f9 -- Anna’s Archive.epub" },
		{ title = "The Algorithm Design Manual", fmt = "pdf", file = "The-Algorithm-Design-Manual.pdf" },
	} },
	{ module = "Security", key = "books-security", items = {
		{ title = "Serious Cryptography (2e)", fmt = "epub", file = "Serious Cryptography, 2nd Edition_ A Practical Introduction -- Jean-Philippe Aumasson -- 2, 2024 -- No Starch Press, Incorporated -- isbn13 9781718503847 -- 98baee034c0a929a742dfde69353a637 -- Anna’s Archive.epub" },
		{ title = "Fuzzing Against the Machine", fmt = "pdf", file = "FuzzingAgainstTheMachine.pdf" },
	} },
	{ module = "Firmware", key = "books-firmware", items = {
		{ title = "Beyond BIOS", fmt = "epub", file = "Beyond BIOS - Vincent Zimmer,Michael Rothman,Suresh Marisetty.epub" },
	} },
	{ module = "Windows", key = "books-windows", items = {
		{ title = "Windows Kernel Programming (2e)", fmt = "pdf", file = "WindowsKernelProgramming.pdf" },
	} },
	{ module = "Haskell", key = "books-haskell", items = {
		{ title = "Programming in Haskell (2e)", fmt = "epub", file = "Programming in Haskell (9781316876152) -- Hutton, Graham -- Second Edition, 5th printing, 2018;2015 -- Cambridge University Press (Virtual Publishing) -- 9781139637534 -- f80c6f606a590ab38c7340907cab3be5 -- Anna’s.epub" },
	} },
	{ module = "OCaml", key = "books-ocaml", items = {
		{ title = "More OCaml: Algorithms, Methods, and Diversions", fmt = "epub", file = "More OCaml_ Algorithms, Methods, and Diversions -- John Whitington -- Reprint with corrections, Cambridge, United Kingdom, 2014 -- Coherent Press -- 9780957671119 -- 654b9e3e8e78e1a0d5c84ac0dcd6604c -- Anna’s Arch.epub" },
	} },
	{ module = "Python", key = "books-python", items = {
		{ title = "Python Crash Course", fmt = "pdf", file = "Python-Crash-Course.pdf" },
	} },
	{ module = "Java", key = "books-java", items = {
		{ title = "Java Concurrency in Practice", fmt = "pdf", file = "JavaConcurrencyInPractice.pdf" },
	} },
	{ module = "Graphics", key = "books-graphics", items = {
		{ title = "OpenGL SuperBible", fmt = "pdf", file = "OpenGL_Superbible.pdf" },
	} },
	{ module = "Version Control", key = "books-vcs", items = {
		{ title = "Building Git", fmt = "pdf", file = "Building_Git.pdf" },
	} },
	{ module = "Debugging", key = "books-debugging", items = {
		{ title = "Building a Debugger", fmt = "pdf", file = "Building-a-debugger.pdf" },
	} },
}

local function book_slug(t)
	return (t:lower():gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", ""))
end

-- Ensure a book is converted+split, then open its chapter picker.
-- Books are pre-built and committed under Resources/docs (books/ for epub+pdf,
-- rust/ for the mdBooks), so this just browses the frozen chapters - no build.
local function ensure_book(mkey, entry)
	if not have("fd") then
		return vim.notify("fd is needed to browse books", vim.log.levels.WARN)
	end
	if entry.fmt == "mdbook" then
		local d = frozen_root .. "/rust/" .. entry.url:match("([^/]+)$") .. "/src"
		return pick_files(d, "-e md", entry.title .. "> ")
	end
	local out = books_root .. "/" .. mkey .. "/" .. book_slug(entry.title)
	pick_files(out, entry.fmt == "epub" and "-e md" or "-e txt", entry.title .. "> ")
end

-- One provider per module: fuzzy-pick a book, then ensure_book opens chapters.
local function make_books_module(mod)
	return function()
		if not have("fd") then
			return vim.notify("fd not found (needed to browse books)", vim.log.levels.WARN)
		end
		local titles = {}
		for _, e in ipairs(mod.items) do
			titles[#titles + 1] = e.title
		end
		table.sort(titles)
		fzf().fzf_exec(titles, {
			prompt = mod.module .. " book> ",
			fzf_opts = { ["--no-multi"] = true },
			actions = {
				["default"] = function(sel)
					if not (sel and sel[1]) then
						return
					end
					for _, e in ipairs(mod.items) do
						if e.title == sel[1] then
							return ensure_book(mod.key, e)
						end
					end
				end,
			},
		})
	end
end

-- Aya: the book (aya-rs.dev) and the crate reference (docs.rs) under one entry.
local function pick_aya()
	fzf().fzf_exec({ "Book (aya-rs.dev)", "Crate reference (docs.rs)" }, {
		prompt = "Aya> ",
		fzf_opts = { ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				if not (sel and sel[1]) then
					return
				end
				if sel[1]:match("^Book") then
					make_simple("aya", simple.aya)()
				else
					pick_aya_api()
				end
			end,
		},
	})
end

-- All books under one entry: pick a subject module, then a book, then a chapter.
local function pick_books()
	local mods = {}
	for _, m in ipairs(BOOKS) do
		mods[#mods + 1] = m.module
	end
	fzf().fzf_exec(mods, {
		prompt = "Books (subject)> ",
		fzf_opts = { ["--no-multi"] = true },
		actions = {
			["default"] = function(sel)
				if not (sel and sel[1]) then
					return
				end
				for _, m in ipairs(BOOKS) do
					if m.module == sel[1] then
						return make_books_module(m)()
					end
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
	{ name = "eBPF ABI reference (helpers / kfuncs / maps / program types)", key = "ebpf", run = make_simple("ebpf", simple.ebpf) },
	{ name = "eBPF (Cilium Reference: architecture, XDP, tc, toolchain)", key = "cilium", run = make_simple("cilium", simple.cilium) },
	{ name = "Aya", key = "aya", run = pick_aya },
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
	{ name = "RISC-V ISA (unpriv + priv, H ext)", key = "riscv", run = function() pick_pdf("riscv", "RISC-V ISA> ") end },
	{ name = "Arm ARM (A-profile, application)", key = "arm-a", run = function() pick_pdf("arm-a", "Arm A-profile> ") end },
	{ name = "Arm ARM (M-profile, microcontroller)", key = "arm-m", run = function() pick_pdf("arm-m", "Arm M-profile> ") end },
	{ name = "Commands (man 1)", key = "man1", run = function() pick_man(1) end },
	{ name = "System calls (man 2)", key = "man2", run = function() pick_man(2) end },
	{ name = "Library functions (man 3)", key = "man3", run = function() pick_man(3) end },
	{ name = "Devices (man 4)", key = "man4", run = function() pick_man(4) end },
	{ name = "File formats (man 5)", key = "man5", run = function() pick_man(5) end },
	{ name = "Miscellaneous (man 7)", key = "man7", run = function() pick_man(7) end },
	{ name = "System administration (man 8)", key = "man8", run = function() pick_man(8) end },
	{ name = "CppReference", key = "cppman", run = pick_cppman },
	{ name = "learncpp.com", key = "cpp", run = pick_learncpp },
	{ name = "Hypervisor From Scratch", key = "rayanfam", run = pick_rayanfam },
	{ name = "NetBSD kernel internals (man 9)", key = "nbsd9", run = function() pick_nbsd(9) end },
	{ name = "NetBSD drivers (man 4)", key = "nbsd4", run = function() pick_nbsd(4) end },
	{ name = "OCaml (stdlib)", key = "ocaml", run = pick_ocaml },
	{ name = "Haskell (Hoogle)", key = "haskell", run = pick_haskell },
	{ name = "Rust reference", key = "rust", run = pick_rust },
	{ name = "Frida", key = "frida", run = make_simple("frida", simple.frida) },
	{ name = "Triton", key = "triton", run = make_simple("triton", simple.triton) },
	{ name = "angr", key = "angr", run = make_simple("angr", simple.angr) },
	{ name = "BAP (Binary Analysis Platform)", key = "bap", run = make_wiki("bap", "https://github.com/BinaryAnalysisPlatform/bap.wiki.git", "BAP> ") },
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
	{ name = "Arm Trusted Firmware-A", key = "armtf", run = make_simple("armtf", simple.armtf) },
	{ name = "SQLite C API", key = "sqlite", run = pick_sqlite },
	{ name = "Ghidra API (versioned)", key = "ghidra", run = pick_ghidra },
	{ name = "Multiboot specs", key = "multiboot", run = pick_multiboot },
	{ name = "GNU Make manual", key = "make", run = function()
		render_shell("curl -fsSL https://www.gnu.org/software/make/manual/make.html | pandoc -f html -t gfm-raw_html --wrap=none 2>/dev/null", "GNU Make manual", "markdown", "gnu-make-manual")
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

-- All books under one entry: Books -> subject module -> book -> chapter.
providers[#providers + 1] = { name = "Books", key = "books", run = pick_books }

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
						-- Same default as the `:Docs <key>` path: D reopens this
						-- provider unless it installs a narrower picker itself.
						last_picker = p.run
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
			-- Default for `D`: reopen this provider. Providers with a picker
			-- of their own (a browsed dir, a module list) narrow it further.
			last_picker = p.run
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
