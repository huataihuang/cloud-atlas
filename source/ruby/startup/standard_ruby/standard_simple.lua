return {
	-- 1. 配置代码格式化（Conform.nvim）
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				ruby = { "standard" },
			},
		},
	},

	-- 2. 配置代码静态检查（nvim-lint）
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				ruby = { "standardrb" },
			},
		},
	},

	-- 3. 让 Mason 自动追踪管理 standardrb
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				table.insert(opts.ensure_installed, "standardrb")
			end
		end,
	},
}
