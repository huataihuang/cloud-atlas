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

  -- 2. 配置代码静态检查（nvim-lint）- 彻底修复版
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- A. 安全地注入你的语言映射
      opts.linters_by_ft = opts.linters_by_ft or {}
      -- 重新用回内置的 "standard" 槽位，但是采用 LazyVim 的非破坏性局部赋值，保证既不丢原生的 parser，又能继承安全参数
      opts.linters_by_ft.ruby = { "standard" }

      -- 如果原生的 standard 骨架未初始化，我们先给它一个空表
      opts.linters.standard = opts.linters.standard or {}

      -- 局部精准修正参数，绝不整块重写，确保原厂的 parser 函数完好无损
      opts.linters.standard.cmd = "standardrb"
      opts.linters.standard.stdin = true
      opts.linters.standard.args = { "--format", "json", "--stdin", "%:p" }
      opts.linters.standard.ignore_exit_code = true
    end,
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
