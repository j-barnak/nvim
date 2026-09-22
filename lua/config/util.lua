-- Small helpers shared by the docs browser, the source explorer, the health
-- check and the rust ftplugin, so the quoting function in particular exists
-- exactly once.
local M = {}

function M.have(bin)
	return vim.fn.executable(bin) == 1
end

function M.fzf()
	return require("fzf-lua")
end

-- POSIX single-quote escaping. Every command string built in this config
-- runs under `sh` (vim.system {"sh","-c",...}, and fzf-lua forces SHELL=sh
-- for its streamed commands), whereas vim.fn.shellescape() quotes for the
-- user's 'shell': with fish it doubles backslashes, which turned python's
-- '\n' into '\\n'.
function M.shq(s)
	return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

-- The command a raw fzf-lua source runs to list the files under `dir`, one
-- path per line relative to `dir`. fd when it is installed (Debian/Ubuntu
-- ship it as fdfind); otherwise find, translating the only argument shapes
-- this config passes: `-e EXT` / `--extension EXT` and `--exclude NAME`.
-- Like fd, the find form skips dot-entries (.git, .complete, .webcache).
-- Returns nil when no tool can run the request (a shape only fd knows, or a
-- machine with neither), so the caller can say so instead of showing nothing:
-- with fd missing every chapter book in Books silently opened no picker.
function M.find_cmd(dir, args)
	local fd = M.have("fd") and "fd" or (M.have("fdfind") and "fdfind")
	if fd then
		return fd .. " --base-directory " .. M.shq(dir) .. " --type f " .. args
	end
	if not M.have("find") then
		return nil
	end
	local names, prunes = {}, {}
	local toks = vim.split(args or "", "%s+", { trimempty = true })
	local i = 1
	while i <= #toks do
		local t, v = toks[i], toks[i + 1]
		if (t == "-e" or t == "--extension") and v then
			names[#names + 1] = "-name " .. M.shq("*." .. v)
		elseif t == "--exclude" and v then
			prunes[#prunes + 1] = "-name " .. M.shq(v) .. " -prune"
		else
			return nil
		end
		i = i + 2
	end
	local cmd = "find . -name '.?*' -prune"
	for _, pr in ipairs(prunes) do
		cmd = cmd .. " -o " .. pr
	end
	cmd = cmd .. " -o -type f"
	if #names > 0 then
		cmd = cmd .. " \\( " .. table.concat(names, " -o ") .. " \\)"
	end
	return "cd " .. M.shq(dir) .. " && " .. cmd .. " -print | sed 's|^\\./||'"
end

return M
