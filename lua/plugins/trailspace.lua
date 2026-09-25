-- Highlight only: trailing whitespace is trimmed on save by conform's
-- trim_whitespace (or the filetype's formatter), see conform.lua.
return {
	"nvim-mini/mini.trailspace",
	event = { "BufReadPost", "BufNewFile" },
	opts = {},
}
