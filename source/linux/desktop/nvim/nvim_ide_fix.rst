.. _nvim_ide_fix:

=======================
重新配置NeoVim IDE
=======================

我之前 :ref:`nvim_ide` 参考 `从零开始配置 Neovim(Nvim) <https://martinlwx.github.io/zh-cn/config-neovim-from-scratch/>`_ ，原作者更新了博客，配置更为精简。正好我遇到了在 :ref:`nvim_ide_freebsd` ，所以再次参考这篇博客进行配置。

配置文件路径
==============

``nvim`` 配置目录 ``~/.config/nvim`` ，默认读取 ``~/.config/nvim/init.lua`` ，为方便维护，从 ``init.lua`` 划分出不同目标的配置:

.. literalinclude:: nvim_ide_fix/tree
   :caption: ``nvim`` 配置目录 ``~/.config/nvim`` 结构

选项配置
=========

- ``~/.config/nvim/lua/options.lua`` 配置实现功能:

  - 默认采用系统剪贴板，同时支持鼠标操控 Nvim
  - Tab 和空格的换算
  - UI 界面
  - “智能”搜索

.. literalinclude:: nvim_ide/options.lua
   :caption: ``~/.config/nvim/lua/options.lua``

- 在 ``init.lua`` 中添加以下配置激活使用 ``options.lua`` :

.. literalinclude:: nvim_ide/init.lua
   :language: lua
   :caption: 在 ``~/.config/nvim/lua/init.lua`` 中激活 ``options.lua``
   :emphasize-lines: 1

键盘映射配置
==============

- 以下配置 ``~/.config/nvim/lua/keymaps.lua`` 实现如下键盘映射:

  - 使用 ``<C-h/j/k/l>`` 在窗口间移动光标
  - 使用 ``Ctrl + 方向键`` 来调整窗口大小
  - 在select选择模式，可以使用 ``Tab`` 或者 ``Shift-Tab`` 来更改连续缩排(indentation repeatedly)

.. literalinclude:: nvim_ide/keymaps.lua
   :language: lua
   :caption: ``~/.config/nvim/lua/keymaps.lua``

- 同样在 ``init.lua`` 中添加以下配置激活使用 ``keymaps.lua`` :

.. literalinclude:: nvim_ide/init.lua
   :language: lua
   :caption: 在 ``~/.config/nvim/lua/init.lua`` 中激活 ``keymaps.lua``
   :emphasize-lines: 2

安装插件管理器
=================

``nvim`` 通过第三方插件提供了强大的能力。有多种插件管理器，其中 :ref:`lazy.nvim` 非常受欢迎，提供了很多神奇功能:

  - 修正以来顺序
  - 锁文件 ``lazy-lock.json`` 跟踪安装的插件
  - ...

- 创建 ``~/.config/nvim/lua/plugins.lua`` (这里的案例只完成 ``lazy.nvim`` 自身安装，没有指定其他第三方插件)):

.. literalinclude:: nvim_ide/plugins.lua
   :language: lua
   :caption: ``~/.config/nvim/lua/plugins.lua`` 管理插件

- 同样在 ``init.lua`` 中添加以下配置激活使用 ``plugins.lua`` :

.. literalinclude:: nvim_ide/init.lua
   :language: lua
   :caption: 在 ``~/.config/nvim/lua/init.lua`` 中激活 ``plugins.lua``
   :emphasize-lines: 3

主题配置
============

.. note::

   `Monokai Pro <https://monokai.pro>`_ 开发的 ``Monokai`` color scheme 是开发IDE中最流行的语法高亮配色，在 `THE HISTORY OF Monokai <https://monokai.pro/history>`_ 一文中有详细的介绍:

   - 2006年荷兰设计师兼开发者Wimer Hazenberg开发出最初的Monokai，主要是TextMate on macOS上暗黑背景的活泼色彩
   - 随后被各个主要IDE所接纳，并且用于终端色彩
   - 2017年发布了Monokai Pro，进一步采用了现代色彩系列，并且包含了用户接口设计和定制图标，提供了色彩过滤器，例如 ``Spectrum`` , ``Ristretto`` 和 ``Monokai Classic``
   - 2024年发布了Monokai Pro Light，采用了新的 ``Sun`` filter，适配了明亮环境，也就是说经过多年发展，Monokai已经完成了主流的 dark 和 light 两种环境适配

在完成了上文 :ref:`lazy.nvim` 配置之后，就可以安装配色插件，这里参考原文使用了 `monokai.nvim <https://github.com/tanvirtin/monokai.nvim>`_ 插件，并且选择了我对比之后认为较为美观的 ``monokai`` 风格:

- 修订 ``~/.config/nvim/lua/plugins.lua`` ，增加安装 ``monokai.nvim`` 的配置行:

.. literalinclude:: nvim_ide/plugins_colorscheme.lua
   :language: lua
   :caption: ``~/.config/nvim/lua/plugins.lua`` 增加 ``monokai.nvim`` 插件管理配色
   :emphasize-lines: 15

- 创建一个 ``~/.config/nvim/lua/colorscheme.lua`` 来定制 ``monokai.nvim`` 插件:

.. literalinclude:: nvim_ide/colorscheme.lua
   :language: lua
   :caption: ``~/.config/nvim/lua/colorscheme.lua`` 定制 ``monokai.nvim`` 插件
   :emphasize-lines: 2

- 最后在 ``~/.config/nvim/init.lua`` 激活配置

.. literalinclude:: nvim_ide/init.lua
   :language: lua
   :caption: 在 ``~/.config/nvim/lua/init.lua`` 中激活 ``colorscheme.lua``
   :emphasize-lines: 4

自动代码补全(Auto-completion)
================================

.. note::

   2024年之后 `从零开始配置 Neovim(Nvim) <https://martinlwx.github.io/zh-cn/config-neovim-from-scratch/>`_ 采用了 `blink.cmp <https://github.com/saghen/blink.cmp>`_ 替代了之前使用的自动补全插件 `nvim-cmp <https://github.com/hrsh7th/nvim-cmp>`_ 。配置更为简单且自动补全快(Rust代码)。

.. warning::

   `blink.cmp <https://github.com/saghen/blink.cmp>`_ 混合了部分Rust程序代码，所以安装是有平台要求的。如果不是常用平台Linux(x86和arm)/macOS/Windows，那么安装会比较麻烦，需要从源代码编译安装。

   之前使用的 `nvim-cmp <https://github.com/hrsh7th/nvim-cmp>`_ 由于是纯Lua代码，就没有这个困难。

   另外， ``blink.cmp`` 官方发布的release实际上对 ``nvim`` 版本要求很高，我在ARM平台的 :ref:`raspberry_pi` 系统上安装就遇到 ``nvim`` 版本过低无法config的问题。

   总之，有利有弊

.. note::

   - 在FreeBSD平台，我还是继续使用 `nvim-cmp <https://github.com/hrsh7th/nvim-cmp>`_ (纯Lua跨平台)
   - 在Raspberry Pi平台，我重新构建了 :ref:`debian_tini_image` (包含了编译 :ref:`nvim` 步骤)，以获得最新的nvim版本来适配 ``blink.cmp``

- 修订 ``~/.config/nvim/lua/plugins.lua`` 添加:

.. literalinclude:: nvim_ide_fix/plugins_blink.lua
   :caption: ``~/.config/nvim/lua/plugins.lua`` 添加 ``blink.cmp`` 插件配置
   
- 重启 ``nvim`` 后就会自动安装插件并得到初步的自动补全功能

异常排查
----------

我在配置了 ``blink.cmp`` 之后，启动遇到一个报错

.. literalinclude:: nvim_ide_fix/plugins_blink.cmp_error
   :caption: 启动nvim遇到的 ``blink.cmp`` 报错

这个问题似乎和 `Config failing - preset: expected function: 0x7ff7cc3683b8, got string (default) #881 <https://github.com/Saghen/blink.cmp/issues/881>`_ 类似，issue中说明要升级nvim。报告issue的nvim是 ``NVIM v0.11.0-dev-979+g84623dbe9`` ，比我的发行版使用的 ``NVIM v0.11.0-dev-790+g0fe4362e2`` 还要新一些，报告升级到 ``NVIM v0.11.0-dev-1479+g548f19ccc3`` 解决。

我重新构建了 :ref:`debian_tini_image` (包含了编译 :ref:`nvim` 步骤)，获得了最新的 ``NVIM v0.12.0-dev-695+g63a7b92e58`` 解决了这个异常问题。

LSP
======

要将 ``Nvim`` 作为IDE，需要依赖LSP实现。但是手动安装和配置LSP很麻烦，因为不同的LSP有不同的安装步骤，对后期的管理来说很不方便。所以就有了 `mason.nvim <https://github.com/williamboman/mason.nvim>`_ 和 `mason-ispconfig.nvim <https://github.com/williamboman/mason-lspconfig.nvim>`_ 来简化配置:

- `mason.nvim <https://github.com/williamboman/mason.nvim>`_ : LSP 管理器，可以实现 LSP 的下载、更新等
- `mason-ispconfig.nvim <https://github.com/williamboman/mason-lspconfig.nvim>`_ : 主要功能是处理 mason.nvim 和 nvim-lspconfig 之间名字不一致的问题; mason-lspconfig.nvim 还会自动调用 vim.lsp.enable 启动安装好的 LSP

- 修改 ``plugins.lua`` 添加如下行:

.. literalinclude:: nvim_ide_fix/plugins_lsp.lua
   :language: lua
   :caption: ``~/.config/nvim/lua/plugins.lua`` 增加 ``nason.nvim`` 相关设置

说明:

  - ``mason.nvim`` 采用默认配置即可，所以用的是 ``opts = {}``
  - ``mason-lspconfig.nvim`` 配置项使用 ``ensure_installed`` 确保 ``pylsp`` 会被自动安装(pylsp 是 Python 语言的一个 LSP)
  - 通过 ``nvim-lspconfig`` 对 ``pylsp`` 进行配置

    - 这里没有采用 ``opts = { ... }`` 进行插件配置，而是使用 ``config = function() ... end`` 自定义一个配置函数，该函数会被自动执行
    - 主要的功能是调用 ``lspconfig.pylsp.setup({})`` ，这里的 ``{}`` 表示采用该 ``LSP`` 的默认行为

完成上面的配置之后，LSP 已经可用了: 默认安装了 ``pylsp``


- 编辑 ``~/.config/nvim/lua/lsp.lua`` ，添加一些Mason的特定配置:

.. literalinclude:: nvim_ide_fix/lsp.lua
   :caption: 配置 LSP ``~/.config/nvim/lua/lsp.lua``

typescript LSP
---------------

.. warning::

   Mason的LSP支持列表实际上比 ``nvim-lspconfig`` 少，所以有些LSP无法通过Mason安装。此外 Mason 是强Linux绑定，对FreeBSD支持不佳，所以在 :ref:`freebsd_programming_tools` ，我后续将尝试直接使用 ``nvim-lspconfig`` 。或者改为使用 ``helix`` 编辑器。

要支持更多的LSP，则参考 `nvim-lspconfig/doc/configs.md <https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md>`_

- 现在配置非常简单，只需要只需要修订 ``opts`` 配置段，在 ``ensure_installed`` 加入对应LSP名字就可以了

- 支持 :ref:`javascript` 和 :ref:`typescript` 可以使用 `typescript-tools.nvim <https://github.com/pmizio/typescript-tools.nvim>`_ ，修订 ``lua/plugins.lua`` :

.. literalinclude:: nvim_ide_fix/plugins_typescript_lsp.lua
   :caption: 安装 ``typescript-tools.nvim``

参考
======

- `从零开始配置 Neovim(Nvim) <https://martinlwx.github.io/zh-cn/config-neovim-from-scratch/>`_

