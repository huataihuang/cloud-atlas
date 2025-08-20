.. _nvim_escope:

==============================
nvim环境使用escpe实现代码导航
==============================

``cscope`` 是类似传统的 ``ctags`` 的代码浏览工具，尤其适用于vim和emacs等编辑器。不过，由于neovim从0.9版本移除了 ``:escope`` 指令，所以需要通过插件来支持。最常用且推荐的插件是 `Github: dhananjaylatkar/cscope_maps.nvim <https://github.com/dhananjaylatkar/cscope_maps.nvim>`_

安装
=======

我在 :ref:`nvim_ide` 中使用 ``lazy.nvim`` 插件管理器，所以在此基础上修改 ``~/.config/nvim/lua/plugins.lua`` 添加一段:

.. literalinclude:: nvim_escope/plugins_escope.lua
   :caption: 在 ``plugins.lua`` 中添加一段安装 ``cscope`` 插件代码

使用
=======

- 在项目根目录下生成文件列表:

.. literalinclude:: nvim_escope/cscope.files
   :caption: 在项目根目录下生成文件列表 ``cscope.files`` (这里以go语言为例)

- 生成 ``cscope`` 数据库:

.. literalinclude:: nvim_escope/cscope_build
   :caption: 生成 ``cscope`` 数据库

此时会在项目根目录下生成一个 ``cscope.out`` 数据库文件

- 进入 ``nvim`` 之后，执行命令 ``:Cs db add cscope.out`` 加载数据库，不过也可以在插件配置自动加载

- 在函数上使用 ``ctrl-]`` 可以跳到函数定义，然后使用 ``ctrl-t`` 又可以跳回原先位置

参考
=======

- `Github: dhananjaylatkar/cscope_maps.nvim <https://github.com/dhananjaylatkar/cscope_maps.nvim>`_
