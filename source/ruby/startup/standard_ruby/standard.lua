return {
	-- 1. 配置代码格式化（Conform.nvim）：保存时自动用 standard fix 修复代码
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				-- 将 ruby 文件的默认格式化工具改为 standard
				ruby = { "standard" },
			},
		},
	},

	-- 2. 配置代码静态检查（nvim-lint）：在输入时动态提示不符合 standard 规范的地方
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				-- 将 ruby 文件的默认 linter 改为 standard
				ruby = { "standard" },
			},
		},
	},

	-- 3. （可选）如果你使用了 Mason 管理工具，让它自动帮你下载 standard 的 LSP 支持（如果需要）
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				-- 告诉 Mason 自动下载 standardrb 的语言服务
				table.insert(opts.ensure_installed, "standardrb")
			end
		end,
	},
}
