.. _lazy.nvim_lua_treesitter:

===========================
lazy.nvim Lua Treesitter
===========================

现在Neovim已经集成了lua treesitter parser，我在最近的 :ref:`compile_nvim_debian` 源代码是最新版本

.. literalinclude:: ../compile_nvim_debian/build_nvim
   :caption: 编译nvim的debian安装包

遇到如下报错:

使用自己编译的 ``nvim`` 配置 :ref:`nvim_ide` ，在进行 ``plugins.lua`` 部分时，使用:

.. literalinclude:: ../nvim_ide/plugins.lua
   :language: lua
   :caption: ``~/.config/nvim/lua/plugins.lua`` 管理插件

一旦 ``init.lua`` 应用了这个 ``plugins.lua`` ，则使用 ``nvim`` 编辑任何 ``.lua`` 文件都会出现如下报错:

.. literalinclude:: lazy.nvim_lua_treesitter/lua_language_err
   :caption: 不能正确处理 ``.lua`` 文件类型的 ``treesitter-parsers`` 报错

`nvim-treesitter <https://github.com/nvim-treesitter/nvim-treesitter>`_ 是在Neovim中提供使用 ``tree-sitter`` 的简单易用方式，并且提供一些基于 ``tree-sitter`` 基本功能，如高亮。

这个报错在 `bug: Encountered Error detected while processing BufReadPost Autocommands for "*": while loading a Lua file failing in Neovim nightly #1343 <https://github.com/folke/lazy.nvim/issues/1343>`_ 和发行版有关(例如fedora)。所以我修改了编译安装方法，参考Neovim官方安装文档 `neovim/INSTALL.md <https://github.com/neovim/neovim/blob/master/INSTALL.md>`_ 重新安装:

.. literalinclude:: ../compile_nvim_debian/build_nvim_source
   :caption: 编译nvim安装到用户目录

参考
=======

- `bug: Encountered Error detected while processing BufReadPost Autocommands for "*": while loading a Lua file failing in Neovim nightly #1343 <https://github.com/folke/lazy.nvim/issues/1343>`_
