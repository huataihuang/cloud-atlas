return {
  -- 1. 让 Treesitter 在本地直接加载 macOS 自带的 swift 语法树解析器
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "swift" })
      end
    end,
  },

  -- 2. 将本地原生陆基的 sourcekit-lsp 挂载到 Neovim 的 LSP 核心管理器中
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          -- 物理定位 macOS 内部最高顺位的 Swift 语言服务引擎
          cmd = { "/usr/bin/xcrun", "sourcekit-lsp" },
          filetypes = { "swift", "objective-c", "objective-cpp" },
        },
      },
    },
  },
}
