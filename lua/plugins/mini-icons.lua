return {
	"nvim-mini/mini.icons",
	lazy = true, -- oil depends on it, so it loads with oil; the mock below covers the rest
	opts = {},
	init = function()
		-- Serve nvim-web-devicons from mini.icons only when a plugin asks for it.
		package.preload["nvim-web-devicons"] = function()
			require("mini.icons").mock_nvim_web_devicons()
			return package.loaded["nvim-web-devicons"]
		end
	end,
}
