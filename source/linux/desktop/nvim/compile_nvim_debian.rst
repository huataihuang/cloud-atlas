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

参考
======

- `Neovim on debian? <https://www.reddit.com/r/debian/comments/188d3wc/neovim_on_debian/>`_
