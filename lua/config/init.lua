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
