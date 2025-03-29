.. _lazy.nvim_startup:

=====================
lazy.nvim快速起步
=====================

`GitHub: folke/lazy.nvim <https://github.com/folke/lazy.nvim>`_ 是neovim的流程插件管理器，可以快速将neovim转变成全功能的IDE，方便我们进行开发。

安装
===========

按照 :ref:`nvim_base_config` 在 ``~/.config/nvim/init.lua`` 配置添加一段 bootstrap:

.. literalinclude:: lazy.nvim_startup/init.lua
   :caption: 在 ``init.lua`` 中添加 ``lazy.nvim`` 插件管理器bootstrap

.. note::

   最后一行　``require("lazy").setup()`` 当前是空的内容，后续在这部分　``setup()`` 添加需要安装的插件以及操作指令

然后重新进入 ``nvim`` ，并运行检查:

.. literalinclude:: lazy.nvim_startup/checkhealth
   :caption: 检查 lazy 是否安装正确

.. literalinclude:: lazy.nvim_startup/checkhealth_output
   :caption: 检查输出信息

:ref:`homebrew` 安装异常排查
------------------------------

在 :ref:`homebrew` 中安装的 ``nvi`` 使用上述安装方法，在 ``checkhealth lazy`` 输出信息中有报错:

.. literalinclude:: lazy.nvim_startup/checkhealth_output_error
   :caption: :ref:`homebrew` 安装 ``nvim`` 的 ``lazy.nvim`` 后检查 ``checkhealth lazy`` 报错
   :emphasize-lines: 14,18

方法一: 通过安装 `Gighub: vhyrro/luarocks.nvim <https://github.com/vhyrro/luarocks.nvim>`_ 解决
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

上述报错参考 `Gighub: vhyrro/luarocks.nvim <https://github.com/vhyrro/luarocks.nvim>`_ ，使用 ``luarocks.nvim`` 来方便安装 luarocks 包:

- 先安装 ``luajit`` :

.. literalinclude:: lazy.nvim_startup/brew_install_luajit
   :caption: 使用 :ref:`homebrew` 安装 ``luajit``

- 修改 ``~/.config/nvim/init.lua`` 代码如下:

.. literalinclude:: lazy.nvim_startup/init_luarocks.lua
   :caption: 在 ``init.lua`` 中添加 ``luarocks.nvim`` 配置来安装 ``luarocks`` 软件包，避免 ``lazy.nvim`` 因缺少 ``luarocks`` 报错
   :emphasize-lines: 16-19

此时当调用 ``lazy.nvim`` 就会自动变易一个本地 ``luarocks`` 安装。 **如果没有自动完成，则可以手工执行** ``:Lazy build luarocks.nvim`` (注意，这里必须是 ``Lazy`` ，第一个字母大写，否则会报错没有这个指令)

方法二: 直接安装 ``LuaRocks``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   `LuaRocks <https://luarocks.org/>`_ 是Lua模块的包管理器

我后来发现一个非常简单的解决方法，就是在系统中直接安装 ``LuaRocks`` 就完全解决了( 之前在 :ref:`gentoo_linux` 上实践 :ref:`nvim` 使用的 USE Flags是 ``lua_single_target_luajit`` Build for LuaJIT only，似乎没有启用 ``LuaRocks`` ):

- 安装 ``LuaRocks`` 是会自动依赖安装Lua 5.4:

.. literalinclude:: lazy.nvim_startup/brew_install_luarocks
   :caption: 在 :ref:`macos` 上使用 :ref:`homebrew` 安装 ``luarocks``

.. note::

   `luarocks Installing <https://github.com/luarocks/luarocks/wiki/Download>`_ 提供了不同平台安装 LuaRocks 的方法，其中 macOS 平台推荐使用 :ref:`homebrew` 方式安装

上述 ``luarocks`` 安装完成后，再次执行 ``:checkhealth lazy`` 就会看到 ``luarocks`` 报错消失:

.. literalinclude:: lazy.nvim_startup/checkhealth_output_luarocks
   :caption: 系统安装了 ``luarocks`` 之后报错消失
   :emphasize-lines: 13-15

插件
======

在完成上述 ``lzay.nvim`` 初始化之后，安装一个主题插件，一方面验证 ``lazy.nvim`` 工作是否正常(我实际上也是为了增加感性认识)，另一方面，本案例中安装的theme插件确实美观好用:

- 修订上文的初始化 ``~/.config/nvim/init.lua`` ，修订 ``require("lazy").setup()`` 内容，添加需要安装的插件　``catppuccin.nvim`` ，并且通过最后一行指令应用这个theme:

.. literalinclude:: lazy.nvim_startup/init_first.lua
   :caption: 在 ``init.lua`` 中添加 ``catppuccin.nvim`` 插件theme
   :emphasize-lines: 15-18

完成配置修订后重新进入 ``nvim`` ，就会看到自动安装过程，并且nvim的编辑风格转换

.. note::

   不知为何，在 macOS Terminal 中使用 ``catppuccin`` theme时候，会出现灰绿色背景，但是在 :ref:`tmux` 中使用这个theme则非常完美... Why?

参考
========

- `GitHub: folke/lazy.nvim <https://github.com/folke/lazy.nvim>`_
- `How To Use lazy.nvim For A Simple And Amazing Neovim Config <https://www.youtube.com/watch?v=6mxWayq-s9I>`_ 视频
- `neovim入门指南(一)：基础配置 <https://www.cnblogs.com/youngxhui/p/17730419.html>`_ 非常详细，我参考此文学习
