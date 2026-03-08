return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	opts = {
		callbacks = {
			enter_note = function(note)
				vim.keymap.set("n", "<leader>o", require("obsidian.api").smart_action, {
					buffer = true,
					noremap = true,
					silent = true,
					expr = true,
				})
			end,
		},
		daily_notes = {
			enabled = true,
			folder = "Daily",
			default_tags = { "journal", "daily" },
		},
		ui = { enable = false },
		legacy_commands = false,
		workspaces = {
			{ name = "SystemsAndSecurity", path = "~/Documents/Obsidian Vault/" },
		},
	},
	init = function()
		local vault = vim.fs.normalize(vim.fn.expand("~/Documents/Obsidian Vault"))
		local loaded = false

		local function in_vault_path(p)
			if not p or p == "" then
				return false
			end
			p = vim.fs.normalize(vim.fn.fnamemodify(p, ":p"))
			return p:sub(1, #vault) == vault
		end

		local function maybe_load()
			if loaded then
				return
			end

			-- 1) load if cwd is in the vault
			if in_vault_path(vim.fn.getcwd()) then
				loaded = true
				require("lazy").load({ plugins = { "obsidian.nvim" } })
				return
			end

			-- 2) or load if the current buffer file is in the vault
			local name = vim.api.nvim_buf_get_name(0)
			if in_vault_path(name) then
				loaded = true
				require("lazy").load({ plugins = { "obsidian.nvim" } })
			end
		end

		vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged", "BufEnter", "BufReadPost", "BufNewFile" }, {
			callback = maybe_load,
		})
	end,
}
