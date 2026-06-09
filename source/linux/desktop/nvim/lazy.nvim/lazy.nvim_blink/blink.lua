return {
	"saghen/blink.cmp",
	opts = {
		keymap = {
			preset = "enter", -- 保持默认的预设

			-- 关键配置：将回车键（Enter/CR）改为：如果选中了就确认，没选择就直接换行
			["<CR>"] = { "accept", "fallback" },

			-- 如果你希望回车完全不触发补全（只用来换行），彻底交给 Tab 键确认：
			-- ["<CR>"] = { "fallback" },
			-- ["<Tab>"] = { "select_next", "fallback" },
		},
		-- 另外，确保 preselect（预选中第一个）关闭，这样回车不会误吞
		completion = {
			list = {
				selection = { preselect = false, auto_insert = false },
			},
		},
	},
}
