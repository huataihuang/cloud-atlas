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
      -- 👈 关键点 A：我们将映射名改为自定义的 "mystandard"
      opts.linters_by_ft.ruby = { "mystandard" }

      -- 👈 关键点 B：直接借用 rubocop 现成的 parser 逻辑，纯声明式定义你的专属检查器
      -- B. 核心安全防御：利用 LazyVim 的加载时机动态修改参数，绝不碰它的默认 parser
      opts.linters.mystandard = {
        cmd = "standardrb",
        stdin = true,
        args = { "--format", "json", "--stdin", "%:p" },
        ignore_exit_code = true,
        parser = function(output, bufnr)
          -- 健壮安全检查：如果什么都没吐出来或者不是标准的 json 格式，直接安全返回空数组，绝不引发弹窗崩溃
          if not output or output == "" or not output:match("^%s*[{[]") then
            return {}
          end

          -- 动态回退到标准的 rubocop 解析机制，平滑展示所有的黄色/红色波浪线
          local success, lint = pcall(require, "nvim-lint")
          if success and lint.linters.rubocop then
            return lint.linters.rubocop.parser(output, bufnr)
          end
          return {}
        end,
      }
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
