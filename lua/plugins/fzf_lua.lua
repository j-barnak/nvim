return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },

	opts = {
		keymap = {
			fzf = {
				["tab"] = "down",
				["btab"] = "up",
			},
		},
		lsp = {
			symbols = {
				exec_empty_query = true,
			},
		},
		files = {
			fd_opts = [[--color=never --hidden --follow
                --type f --exclude .git --exclude exports --exclude build]],
		},
		grep = {
			rg_opts = [[--color=never --hidden --line-number --column --no-heading --smart-case -g "!build/*" -g "!.git/*" -g "!exports/*"]],
		},
	},

	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "find file" },
		{ "<leader>ft", "<cmd>FzfLua tags<cr>", desc = "project tags" },
		{ "<leader>fb", "<cmd>FzfLua btags<cr>", desc = "buffer tags" },
		{
			"<leader>fg",
			function()
				require("fzf-lua").grep_project()
			end,
			desc = "grep (fuzzy filter immediately)",
		},
		{ "<leader>fd", "<cmd>FzfLua lsp_definitions<cr>", desc = "definitions (LSP)" },
		{ "<leader>rr", "<cmd>FzfLua lsp_references<cr>", desc = "references (LSP)" },
		{ "<leader>fi", "<cmd>FzfLua lsp_implementations<cr>", desc = "implementations (LSP)" },
		-- Use LSP document symbols when available, fall back to treesitter otherwise
		{
			"<leader>fs",
			function()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				local has_lsp = false
				for _, client in ipairs(clients) do
					if client.server_capabilities.documentSymbolProvider then
						has_lsp = true
						break
					end
				end
				if has_lsp then
					require("fzf-lua").lsp_document_symbols()
				else
					require("fzf-lua").treesitter()
				end
			end,
			desc = "document symbols",
		},
		{ "<leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "workspace symbols (LSP)" },
	},
}
