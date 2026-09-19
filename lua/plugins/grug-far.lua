-- grug-far.nvim: project-wide find-and-replace driven by ripgrep, in a dedicated
-- buffer you edit like any other file. Requires ripgrep (rg) >= 14 (>= 15
-- recommended). Complements the fzf-lua live-grep (<leader>fg): that one finds,
-- this one finds AND replaces across the whole project.
--
-- Closing: when you are done, close the results buffer with <localleader>c (its
-- own keybinding) or :bd, to save resources since a big result set can get
-- beefy. The Close action (unlike a plain :bd) will ask you to confirm if a
-- replace/sync is in progress, since that would be aborted.
return {
	"MagicDuck/grug-far.nvim",
	cmd = "GrugFar",
	keys = {
		{
			"<leader>sr",
			function()
				require("grug-far").open()
			end,
			desc = "Search/replace in project (grug-far)",
		},
		{
			"<leader>sr",
			function()
				require("grug-far").with_visual_selection()
			end,
			mode = "x",
			desc = "Search/replace selection (grug-far)",
		},
		{
			"<leader>sw",
			function()
				require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
			end,
			desc = "Search/replace word under cursor (grug-far)",
		},
		{
			"<leader>sf",
			function()
				require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
			end,
			desc = "Search/replace in current file (grug-far)",
		},
	},
	opts = {},
}
