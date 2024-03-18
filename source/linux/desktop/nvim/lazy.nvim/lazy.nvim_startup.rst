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

插件
======

在完成上述 ``lzay.nvim`` 初始化之后，安装一个主题插件，一方面验证 ``lazy.nvim`` 工作是否正常(我实际上也是为了增加感性认识)，另一方面，本案例中安装的theme插件确实美观好用:

- 修订上文的初始化 ``~/.config/nvim/init.lua`` ，修订 ``require("lazy").setup()`` 内容，添加需要安装的插件　``catppuccin.nvim`` ，并且通过最后一行指令应用这个theme:

.. literalinclude:: lazy.nvim_startup/init_first.lua
   :caption: 在 ``init.lua`` 中添加 ``catppuccin.nvim`` 插件theme
   :emphasize-lines: 15-18

完成配置修订后重新进入 ``nvim`` ，就会看到自动安装过程，并且nvim的编辑风格转换

参考
========

- `GitHub: folke/lazy.nvim <https://github.com/folke/lazy.nvim>`_
- `How To Use lazy.nvim For A Simple And Amazing Neovim Config <https://www.youtube.com/watch?v=6mxWayq-s9I>`_ 视频
- `neovim入门指南(一)：基础配置 <https://www.cnblogs.com/youngxhui/p/17730419.html>`_ 非常详细，我参考此文学习
