require("config.remap")
require("config.options")

-- :Docs loads its 2,600-line module on first use instead of at startup. The
-- module replaces this stub with the real command (and its completer) when
-- it loads, so after the first call both go straight to it.
vim.api.nvim_create_user_command("Docs", function(o)
	require("config.docs")
	vim.cmd.Docs({ args = o.fargs })
end, {
	nargs = "?",
	desc = "Browse documentation",
	complete = function(arg_lead)
		require("config.docs")
		return vim.fn.getcompletion("Docs " .. arg_lead, "cmdline")
	end,
})
-- The same stub for the module's other commands, so :DocsGrep / :DocsFile /
-- :DocsRust work in a fresh session before :Docs has ever been run (the module
-- defines the real commands over these when it loads).
for _, name in ipairs({ "DocsGrep", "DocsFile", "DocsRust" }) do
	vim.api.nvim_create_user_command(name, function()
		require("config.docs")
		vim.cmd[name]()
	end, { desc = "Browse documentation (" .. name .. ")" })
end
