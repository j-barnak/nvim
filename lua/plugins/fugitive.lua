return {
	"tpope/vim-fugitive",
	-- Every command fugitive actually defines (checked against plugin/fugitive.vim):
	-- Ggrep, Gsplit and Glog do not exist, and naming them here loaded the plugin
	-- and then failed with E492. Logs are Gclog / Gllog.
	cmd = {
		"G",
		"Git",
		"Gcd",
		"Glcd",
		"Gclog",
		"Gllog",
		"Gdiffsplit",
		"Gvdiffsplit",
		"Ghdiffsplit",
		"Gedit",
		"Gpedit",
		"Gread",
		"Gwrite",
		"Gwq",
		"Gdelete",
		"Gmove",
		"Grename",
		"Gdrop",
		"GBrowse",
	},
}
