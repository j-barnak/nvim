return {
	"HiPhish/rainbow-delimiters.nvim",
	-- Configured through g:rainbow_delimiters (defaults are fine); no setup()
	-- call is needed, and loading on buffer read keeps it off the start path.
	event = { "BufReadPost", "BufNewFile" },
}
