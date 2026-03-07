return {
	"j-barnak/auditor.nvim",
	dependencies = { "kkharji/sqlite.lua" },
	config = function()
		require("auditor").setup()
	end,
}
