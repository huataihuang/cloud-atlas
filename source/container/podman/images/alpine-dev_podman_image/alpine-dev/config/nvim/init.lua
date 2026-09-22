-- =============================================================================
-- 1. 基础体验优化
-- =============================================================================
vim.g.mapleader = " "              -- 设置 Leader 键为空格
vim.opt.number = true              -- 显示行号
vim.opt.relativenumber = true      -- 显示相对行号
vim.opt.termguicolors = true       -- 开启 24 位真彩色支持
vim.opt.shiftwidth = 4             -- 缩进空格数
vim.opt.tabstop = 4
vim.opt.expandtab = true           -- Tab 转空格
vim.opt.signcolumn = "yes"         -- 始终显示左侧警告/报错标记列

-- =============================================================================
-- 2. 健壮的 lazy.nvim 自动安装逻辑
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local status_ok, lazy = pcall(require, "lazy")
if not status_ok then return end

-- =============================================================================
-- 3. 插件配置列表
-- =============================================================================
lazy.setup({
  -- 【主题】：Tokyo Night
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },

  -- 【文件导航栏】：neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- 文件图标支持
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true, -- 如果只剩下文件树窗口，自动退出 nvim
        filesystem = {
          filtered_items = {
            visible = true,          -- 显示隐藏文件（如 .gitignore, .config 等）
          },
          follow_current_file = {
            enabled = true,          -- 打开文件时，文件树自动定位到当前文件
          },
        },
      })

      -- 快捷键设置：
      -- 按 <Ctrl + n> 切换文件树显隐
      vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", { silent = true })
      -- 按 <Leader + e>（即 空格 + e）也可以切换文件树
      vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { silent = true })
    end,
  },

  -- 【语法高亮】：Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ts_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
      if not ts_ok then return end
      ts_configs.setup({
        ensure_installed = { "c", "ruby", "python", "rust", "markdown", "markdown_inline", "bash", "lua" },
        highlight = { enable = true },
      })
    end,
  },

  -- 【LSP 配置库】
  "neovim/nvim-lspconfig",

  -- 【自动补全引擎与 UI 弹窗】
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP 补全源
      "hrsh7th/cmp-buffer",       -- 当前 Buffer 词汇补全
      "hrsh7th/cmp-path",         -- 文件路径补全
      "L3MON4D3/LuaSnip",         -- 代码片段引擎
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
        }),
      })
    end,
  },

  -- 【状态栏】
  {
    "nvim-lualine/lualine.nvim",
    config = function() require("lualine").setup() end,
  },
})

-- =============================================================================
-- 4. 绑定 Dockerfile 中内置的 LSP
-- =============================================================================
local capabilities = {}
local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_lsp_ok then
  -- 修复：修改为全小写划线命名 default_capabilities()
  capabilities = cmp_nvim_lsp.default_capabilities()
end

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)       -- 跳转定义
  vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)            -- 文档悬停
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)       -- 查找引用
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)   -- 变量重命名
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- 代码修复
end

local servers = { "clangd", "solargraph", "jedi_language_server", "ruff", "rust_analyzer", "marksman" }

for _, server in ipairs(servers) do
  if vim.lsp.config then
    vim.lsp.config(server, {
      capabilities = capabilities,
      on_attach = on_attach,
    })
    vim.lsp.enable(server)
  else
    local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
    if lspconfig_ok then
      lspconfig[server].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end
  end
end
