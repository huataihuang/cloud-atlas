return {
	"nvim-treesitter/nvim-treesitter",
	opts = {
		indent = {
			enable = true,
			-- 在这里禁用 treesitter 对 ruby 的缩进控制，让 vim 原生缩进接管
			disable = { "ruby" },
		},
	},
}
