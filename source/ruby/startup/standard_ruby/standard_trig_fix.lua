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

  -- 2. 配置代码静态检查（nvim-lint）- 极简配置，绝不提前触碰属性
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        ruby = { "standard" },
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

  -- 4. 🚀 终结技：利用 Neovim 的事件机制，在全环境完全就绪后，再安全修正标准命令
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- 创建一个针对 Ruby 文件的自动命令
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "ruby",
        callback = function()
          -- 延迟 100 毫秒执行，死死确保 nvim-lint 的内部对象已经完全由原厂安全初始化完毕
          vim.defer_fn(function()
            local success, lint = pcall(require, "nvim-lint")
            if success and lint.linters and lint.linters.standard then
              -- 此时原厂的 parser 已经 100% 就绪，我们只安全地修正它的路径和参数
              lint.linters.standard.cmd = "standardrb"
              lint.linters.standard.stdin = true
              lint.linters.standard.args = { "--format", "json", "--stdin", "%:p" }
              lint.linters.standard.ignore_exit_code = true
            end
          end, 100)
        end,
      })
    end,
  },
}
