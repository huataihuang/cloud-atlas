# Use Edge Alpine for dev env
FROM alpine:edge

# prepare proxy for GFW, ss run on Host
# ENV for "podman build & run"
# if only for "podman build", change ENV to ARG
#ARG http_proxy=socks5://127.0.0.1:1082
#ARG https_proxy=socks5://127.0.0.1:1082
#ARG HTTP_PROXY=socks5://127.0.0.1:1082
#ARG HTTPS_PROXY=socks5://127.0.0.1:1082

#!!! Don't use ARG or ENV to set proxy globally, in China GFW break github.com and golang.org, so only set proxy for these site, others are direct access

# Go support GOPROXY, In China, please use "https://goproxy.cn" ，else use "https://proxy.golang.org"
ARG GOPROXY=https://goproxy.cn,direct

# if podman run use "--net=host" then proxy point to 127.0.0.1 (same as host), else
# proxy point to host.containers.internal, but need change sing-box(ss client) listen to 0.0.0.0, and DONT forget config iptables/nftables
# HERE setup proxyon/proxyoff alias in container, user can control proxy switch easyly.
RUN echo 'alias proxyon="export http_proxy=socks5://127.0.0.1:1082 https_proxy=socks5://127.0.0.1:1082 HTTP_PROXY=socks5://127.0.0.1:1082 HTTPS_PROXY=socks5://127.0.0.1:1082 GOPROXY=https://goproxy.cn,direct"' > /etc/profile.d/proxy.sh && \
    echo 'alias proxyoff="unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY GOPROXY"' >> /etc/profile.d/proxy.sh && \
    chmod +x /etc/profile.d/proxy.sh

RUN apk update && apk upgrade

# Devops utilities
RUN apk add --no-cache openssh openssl bind-tools tmux git neovim

# install system core tools 
RUN apk add --no-cache \
    tini \
    su-exec \
    bash \
    git \
    curl \
    doas \
    ripgrep \
    fd \
    fzf \
    ca-certificates

# base compile suit(GCC/Make/Headers), LSP and code format provide by Clang
RUN apk add --no-cache \
    build-base \
    musl-dev \
    gdb \
    cmake \
    linux-headers \
    clang \
    clang-extra-tools

# install language develop env
# Go, Python, Ruby, Rust
# Not install nodesjs, because my Macbook Air 11" Late 2010 too old to run
# If need, you can "apk add nodejs npm"
# NOTE: "py3-pysocks" for pip support socks proxy, else will fail if use "ENV http_proxy=socks5://127.0.0.1:1082"
RUN apk add --no-cache \
    go \
    python3 \
    py3-pip \
    py3-pysocks \      
    ruby \
    ruby-dev \
    rust \
    cargo

# Lightweight LSP and Code Analyszer (without Node.js heavy dependence)
# - C/C++: clangd (include in clang-extra-tools)
# - Rust: rust-analyzer
RUN apk add --no-cache rust-analyzer

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# create admin (UID/GID 1000)
ARG USER=admin
ARG GROUP=admin
ARG UID=1000
ARG GID=1000

RUN addgroup -g ${GID} ${GROUP} && \
    adduser -u ${UID} -G ${GROUP} -s /bin/bash -D ${USER} && \
    echo "permit nopass :${GROUP}" >> /etc/doas.conf && \
    chmod 0400 /etc/doas.conf && \
    chown root:root /etc/doas.conf

# WorkSpace
WORKDIR /workspace
RUN chown ${USER}:${GROUP} /workspace

USER admin

# develop enviroment
# Go PATH
ENV HOME=/home/${USER}
ENV GOPATH=$HOME/go
ENV GEM_HOME=$HOME/.gem/ruby/3.4.0
ENV PATH=$GOPATH/bin:$GEM_HOME/bin:$HOME/.cargo/bin:$HOME/venv/dev/bin:/usr/local/go/bin:$PATH

# - Go: gopls
RUN go install golang.org/x/tools/gopls@latest

# python program: virtualenv
RUN bash -c 'mkdir -p $HOME/venv && cd $HOME/venv && python3 -m venv dev'

# - python-frontmatter: Python batch handle YAML frontmatter properties of Astro Markdown
RUN bash -c 'source $HOME/venv/dev/bin/activate && pip install python-frontmatter'
# - Python: ruff + jedi-language-server
RUN bash -c 'source $HOME/venv/dev/bin/activate && pip install jedi-language-server ruff'
# sphinx doc for My "Cloud-Atlas"
RUN bash -c 'source $HOME/venv/dev/bin/activate && pip install sphinx sphinx_rtd_theme sphinxnotes-strike sphinxcontrib-video sphinxcontrib-youtube myst-parser jieba'

# - Ruby: solargraph
# 设置了GEM_PATH之后，不需要 --user-install 参数
RUN gem install --no-document solargraph

# - asciidoctor: AsciiDoc / Antora Offline Analyzer
RUN gem install --no-document asciidoctor asciidoctor-diagram

# - Markdown / Astro MDX: marksman (Markdown LSP write by Rust)
RUN mkdir -p $HOME/.cargo/bin && \
    http_proxy=socks5://127.0.0.1:1082 https_proxy=socks5://127.0.0.1:1082 \
    curl -fsSL https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64 -o $HOME/.cargo/bin/marksman && \
    chmod +x $HOME/.cargo/bin/marksman

# -----------------------------------------------------------------------------
# 配置 Neovim 开发环境 (单文件 init.lua + 插件离线预热)
# -----------------------------------------------------------------------------
USER admin
WORKDIR /home/admin

# 1. 创建 Neovim 配置目录并注入 init.lua
RUN mkdir -p /home/admin/.config/nvim && \
    cat << 'EOF' > /home/admin/.config/nvim/init.lua
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
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          filtered_items = { visible = true },
          follow_current_file = { enabled = true },
        },
      })
      vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", { silent = true })
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
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
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
-- 4. 绑定系统内置的 LSP
-- =============================================================================
local capabilities = {}
local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_lsp_ok then
  capabilities = cmp_nvim_lsp.default_capabilities()
end

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
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
EOF

# 2. 在构建阶段提前下载并编译所有 Neovim 插件 (实现离线开箱即用)
RUN nvim --headless "+Lazy! sync" +qa

# =============================================================================
# 2. 恢复默认开发工作目录（关键步骤）
# =============================================================================
WORKDIR /workspace

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

CMD ["/bin/bash"]
