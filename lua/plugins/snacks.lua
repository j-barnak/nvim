-- snacks.image: inline images in the terminal via the kitty graphics protocol.
-- Renders :Docs diagrams (extracted Intel SDM figures, opened in a float) and
-- images embedded in the markdown providers (SDL wiki, CPython, AFL++, SFML).
--
-- Chosen over image.nvim because it handles tmux far better (no flicker/ghost
-- images across panes) and renders PNG natively — no ImageMagick/luarocks rock.
-- Works over SSH inside tmux because tmux has `allow-passthrough on`.
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		image = {
			enabled = true,
			doc = {
				enabled = true, -- render images embedded in markdown docs
				inline = true,
				float = true,
				max_width = 90,
				max_height = 45,
			},
		},
	},
}
