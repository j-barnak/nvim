return {
	"kernel-docs.nvim",
	dir = "/home/jared/Projects/KernelDocs",
	dependencies = { "ibhagwan/fzf-lua" },
	cmd = {
		"KernelDocs",
		"KernelDocsVersion",
		"KernelDocsRefresh",
		"KernelDocsRefs",
		"KernelDocsGrep",
		"KernelDocsApi",
		"KernelDocsSync",
		"KernelDocsProvider",
	},
	keys = {
		{ "<leader>kk", "<cmd>KernelDocs<cr>", desc = "Docs: browse" },
		{ "<leader>kv", "<cmd>KernelDocsVersion<cr>", desc = "Docs: pick version" },
		{ "<leader>kg", "<cmd>KernelDocsGrep<cr>", desc = "Docs: keyword grep" },
		{ "<leader>ka", "<cmd>KernelDocsApi<cr>", desc = "Docs: API search" },
		{ "<leader>kp", "<cmd>KernelDocsProvider<cr>", desc = "Docs: switch provider (kernel/bcc)" },
		{ "<leader>kb", "<cmd>KernelDocsProvider bcc<cr><cmd>KernelDocs<cr>", desc = "Docs: browse BCC" },
	},
	opts = {
		-- Default provider is the Linux kernel (torvalds/linux). "bcc" (iovisor/bcc)
		-- is also built in. Switch at runtime with :KernelDocsProvider or <leader>kp.
		-- provider = "kernel",
		-- To read from local checkouts instead of GitHub, set per-provider paths:
		-- providers = {
		--   kernel = { local_path = "~/src/linux" },
		--   bcc = { local_path = "~/src/bcc" },
		-- },
		picker = "fzf",
	},
	config = function(_, opts)
		require("kernel-docs").setup(opts)
	end,
}
