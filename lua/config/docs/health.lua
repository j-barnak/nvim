-- :checkhealth config.docs
-- Reports which external tools the :Docs providers can use, and whether the
-- committed (frozen) library is present. Nothing here is required at startup;
-- each provider degrades to a notify when its tool is missing.
local M = {}

local have = require("config.util").have

-- tool -> what it enables (missing = that feature is unavailable, not an error)
local TOOLS = {
	{ "fd", "browsing any file picker (books, docs, source)", true },
	{ "git", "cloning/updating the live doc repos (kernel, QEMU, Ghidra, ...)" },
	{ "pandoc", "rendering .rst/.xml/.html docs and web articles" },
	{ "curl", "web providers and PDF spec downloads" },
	{ "mutool", "splitting PDF specs (C/C++/DWARF/ABI/RISC-V/Arm, Intel SDM)" },
	{ "pdftotext", "extracting PDF spec text" },
	{ "pdfinfo", "PDF page counts for the spec splitter" },
	{ "man", "man 1-8, ld/as/elf/bash, binutils, NetBSD pages" },
	{ "col", "man page rendering (col -bx)" },
	{ "python3", "web article extraction, kernel-doc (recent trees)" },
	{ "perl", "kernel-doc on older kernel trees" },
	{ "makeinfo", "GCC internals/user/cpp manuals (texinfo)" },
	{ "ctags", ":Src source explorer tag index" },
	{ "cppman", "CppReference provider" },
	{ "sha256sum", "background pre-conversion of browsed .rst/.xml/.html sets (optional)" },
	{ "nice", "background pre-conversion runs at low priority (optional)" },
	{ "setsid", "background pre-conversion is killed cleanly on exit (optional)" },
	{ "timeout", "network fetches and man renders are capped at 60 s (optional)" },
	{ "pdftoppm", "Intel SDM figure extraction (optional)" },
	{ "convert", "Intel SDM figure cropping (optional, ImageMagick)" },
	{ "xdg-open", "opening a figure when snacks.image is unavailable (optional)" },
}

function M.check()
	local health = vim.health
	health.start("External tools")
	for _, t in ipairs(TOOLS) do
		local bin, what, required = t[1], t[2], t[3]
		if have(bin) then
			health.ok(bin .. ": " .. what)
		elseif required then
			health.error(bin .. " missing: " .. what, { "Install " .. bin })
		else
			health.warn(bin .. " missing: " .. what)
		end
	end

	health.start("Frozen library (Resources/docs, committed)")
	local fr = vim.fn.stdpath("config") .. "/Resources/docs"
	if vim.fn.isdirectory(fr) ~= 1 then
		health.error("Resources/docs not found at " .. fr, { "git checkout the repo's Resources/ tree" })
		return
	end
	local books = vim.fn.glob(fr .. "/books/*/*/.complete", false, true)
	health.ok(("%d books frozen (epub/pdf chapters)"):format(#books))
	local mdbooks = vim.fn.glob(fr .. "/rust/*/src", false, true)
	health.ok(("%d rust mdBooks frozen"):format(#mdbooks))
	local listings = vim.fn.isdirectory(fr .. "/rust/book/listings") == 1
	if listings then
		health.ok("rust/book/listings present (code {{#include}}s inline)")
	else
		health.warn("rust/book/listings missing: The Rust Programming Language will show {{#rustdoc_include}} markers")
	end
	-- Every frozen web provider, so a truncated or missing index is reported
	-- rather than passing silently.
	for _, w in ipairs({ { "learncpp", 356 }, { "osdev", 778 }, { "rust-atomics", 13 }, { "rayanfam", 8 }, { "herd7", 3 },
		{ "astra", 7 }, { "kernel-ctf", 10 },
		{ "packer", 18 }, { "snapshot-fuzzer", 13 }, { "kernel-labs", 27 },
		{ "slub", 14 }, { "kernel-internals", 482 } }) do
		local idx = fr .. "/" .. w[1] .. "/index.tsv"
		if vim.fn.filereadable(idx) == 1 then
			local n = #vim.fn.readfile(idx)
			health.ok(("%s: %d articles indexed"):format(w[1], n))
		else
			health.warn(w[1] .. " index missing: " .. idx)
		end
	end
	local cache = vim.fn.glob(fr .. "/.webcache/*.txt", false, true)
	health.ok(("%d frozen web articles cached"):format(#cache))
	local tools = vim.fn.isdirectory(vim.fn.stdpath("config") .. "/Resources/tools") == 1
	if tools then
		health.ok("Resources/tools present (builders for regenerating the library)")
	else
		health.warn("Resources/tools missing: PDF spec / SDM / doxygen builds need it")
	end

	health.start("Plugins")
	local ok_fzf = pcall(require, "fzf-lua")
	if ok_fzf then
		health.ok("fzf-lua available (all pickers)")
	else
		health.error("fzf-lua not available: :Docs pickers cannot open", { "Install ibhagwan/fzf-lua" })
	end
	local ok_snacks, snacks = pcall(require, "snacks")
	if ok_snacks and snacks.image then
		health.ok("snacks.image available (inline figures)")
	else
		health.warn("snacks.image not available: figures open externally (xdg-open)")
	end
end

return M
