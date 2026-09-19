-- smart-splits.nvim: split resizing and cursor movement that is seamless across
-- Neovim windows AND terminal-multiplexer panes (tmux/wezterm/kitty). Recommended
-- mappings from the README:
--   <A-h/j/k/l>            resize the current split (prefix a count to scale it)
--   <C-h/j/k/l>            move to the split/pane in that direction (into tmux too)
--   <C-\>                  move to the previous split/pane
--   <leader><leader>h/j/k/l  swap the current buffer with the one in that direction
-- These <C-h/j/k/l> maps replace the plain <C-w> hops that used to live in
-- lua/config/remap.lua. Not lazy-loaded (the README recommends against it when
-- using multiplexer integration, which is auto-detected on tmux).
return {
	"smart-splits-nvim/smart-splits.nvim",
	lazy = false,
	opts = {},
	keys = {
		-- resizing splits
		{ "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
		{ "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
		{ "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
		{ "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize split right" },
		-- moving between splits (and into tmux/wezterm panes)
		{ "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Go to split left" },
		{ "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Go to split down" },
		{ "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Go to split up" },
		{ "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Go to split right" },
		{ "<C-\\>", function() require("smart-splits").move_cursor_previous() end, desc = "Go to previous split" },
		-- swapping buffers between splits
		{ "<leader><leader>h", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer left" },
		{ "<leader><leader>j", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer down" },
		{ "<leader><leader>k", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer up" },
		{ "<leader><leader>l", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer right" },
	},
}
