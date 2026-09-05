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

return M
