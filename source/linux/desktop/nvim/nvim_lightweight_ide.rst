.. _nvim_lightweight_ide:

============================
NeoVim轻量级IDE
============================

.. note::

   我曾经花费了大量时间来参考网上文章配置vim和nvim，但是一则浪费时间，二则随着时间推移各种配置方法层出不穷且很容易过时。所以现在采用AI自动生成配置，避免浪费精力，集中注意力在真正的开发工作上。

我在构建 :ref:`mba11_late_2010` 上使用的 :ref:`alpine-dev_podman_image` ，采用了gemini提供的一个快速构建nvim的IDE的 ``init.lua`` ，只需要将该配置文件复制到 ``~/.config/nvim/init.lua`` 然后启动 ``nvim`` 就能够快速完成一个轻量级IDE:

.. literalinclude:: ../../../container/podman/images/alpine-dev_podman_image/alpine-dev/config/nvim/init.lua
   :language: lua
   :linenos:
   :caption: ~/.config/nvim/init.lua

这个独立的 ``~/.config/nvim/init.lua`` 采用单文件架构，涵盖了从插件管理、主题UI、代码高亮、侧边栏文件树到 LSP 自动补全的核心开发体验:

- 基础体验与 UI 设定:

  - ``vim.g.mapleader = " "`` : 将空格键（Space）设为 Leader 键，符合现代 Neovim 快捷键习惯。
  - 开启行号、相对行号、24位真彩色（termguicolors）与默认 4 空格缩进。

- 插件管理器( ``lazy.nvim`` )自动初始化:

  - 启动时检查 ``lazy.nvim`` 是否存在，若不存在则阻塞执行 ``git clone`` 自动下载。
  - 加入了错误拦截与 ``pcall`` 异常包裹，确保即使网络抖动也不会导致 Neovim 启动崩溃。

- 精选插件组合:

  - ``tokyonight.nvim`` ：主题，提供深色视觉风格。
  - ``neo-tree.nvim`` ：IDE 风格的文件导航侧边栏，支持图标显示与自动追踪当前打开的文件。
  - ``nvim-treesitter`` : 基于语法树的高级语法高亮引擎，配置了 C、Ruby、Python、Rust、Markdown 等语言解析器。
  - ``nvim-cmp`` 体系: 自动补全前端 UI，融合了 LSP 接口、当前 Buffer 词汇、文件路径以及 ``LuaSnip`` 代码片段源。
  - ``lualine.nvim`` : 底部信息状态栏。

- 绑定 :ref:`alpine-dev_podman_image` 内置 LSP 服务:

  - 自动连接 Dockerfile 内置的 6 个系统级 LSP/Tools（clangd, solargraph, jedi_language_server, ruff, rust_analyzer, marksman）。
  - 适配 Neovim 0.11+ 的原生 ``vim.lsp.config`` API，同时兼容旧版 lspconfig 语法。

常用开发技巧与快捷键指南
==========================

所有快捷键均已在 ``init.lua`` 中配置完毕，开箱即用:

文件导航栏（Neo-tree）
-----------------------

.. csv-table:: 文件导航栏（Neo-tree）
   :file: nvim_lightweight_ide/neo-tree.csv
   :widths: 20,80
   :header-rows: 1

代码自动补全（nvim-cmp）
------------------------

在插入模式（Insert Mode）下编写代码时，补全菜单会自动弹出

.. csv-table:: 代码自动补全（nvim-cmp）
   :file: nvim_lightweight_ide/nvim-cmp.csv
   :widths: 20,80
   :header-rows: 1

LSP 跳转、查阅与代码重构
-------------------------

打开任意 C、Python、Ruby、Rust 或 Markdown 文件时，LSP 会自动在后台静默启动。把光标移动到目标变量、函数或类名上，在普通模式（Normal Mode）下操作:

.. csv-table:: LSP 跳转、查阅与代码重构
   :file: nvim_lightweight_ide/lsp.csv
   :widths: 10,30,60
   :header-rows: 1

界面与编辑器基础
------------------

- 折叠/展开：进入文件后，Treesitter 会自动识别代码块，在普通模式下按 ``zc`` 折叠代码块，按 ``zo`` 展开代码块。

- 分屏操作：

  - ``:vsplit`` ：垂直拆分窗口。
  - ``:split`` ：水平拆分窗口。
  - ``Ctrl + w`` 加上方向键（ ``h/j/k/l`` ）：在拆分出来的各个窗口间快速移动光标。

参考
=======

- gemini
