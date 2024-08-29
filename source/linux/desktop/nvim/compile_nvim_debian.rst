.. _compile_nvim_debian:

========================
Debian环境编译neovim
========================

在 :ref:`nvim_ide` 中使用 :ref:`lazy.nvim` 发现， Debian 12 仓库默认提供的 neovim 版本是 0.7.x ，不能满足运行 ``lazy.nvim`` 导致如下报错: 

.. literalinclude:: nvim_ide/nvim_ver_err
   :caption: ``nvim`` 版本低于 0.8.0 导致不能使用 lazy.nvim 报错

参考reddit上帖子 `Neovim on debian? <https://www.reddit.com/r/debian/comments/188d3wc/neovim_on_debian/>`_ 讨论，建议通过源代码编译进行安装，基本步骤如下:

.. literalinclude:: compile_nvim_debian/build_nvim
   :caption: 编译nvim的debian安装包

不过，我实践遇到 :ref:`lazy.nvim_lua_treesitter` 异常报错，所以实际修正为如下安装方式(参考官方 `neovim/INSTALL.md <https://github.com/neovim/neovim/blob/master/INSTALL.md>`_ ):

.. literalinclude:: compile_nvim_debian/build_nvim_source
   :caption: 编译nvim安装到用户目录

.. note::

   除了源代码编译可以获得最新的Neovim外，另外一种常用方式是通过Github官方release的二进制程序，官方Relase页面还提供了一种AppImage格式可以让程序运行在大多数Linux平台( `How to install Neovim on Debian the right way <https://mansoorbarri.com/neovim-debian/>`_ )

参考
======

- `Neovim on debian? <https://www.reddit.com/r/debian/comments/188d3wc/neovim_on_debian/>`_
- `Github: neovim/INSTALL.md <https://github.com/neovim/neovim/blob/master/INSTALL.md>`_
