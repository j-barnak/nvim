return {
	dir = "~/Projects/auditor.nvim",
	dependencies = { "kkharji/sqlite.lua" },
	config = function()
		require("auditor").setup()
	end,
}
