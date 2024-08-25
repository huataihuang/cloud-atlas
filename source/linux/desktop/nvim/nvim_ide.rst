.. _nvim_ide:

============
NeoVim IDE
============

`Transform Your Neovim into a IDE: A Step-by-Step Guide <https://martinlwx.github.io/en/config-neovim-from-scratch/>`_ 作者提供的指南(借鉴):

- 从0开始构建基于 :ref:`lua` 的 ``nvim`` 配置，努力理解每个配置选项
- 学习一些 :ref:`lua` 编程语言，可以参考一下 `Learn Lua in Y minutes <https://learnxinyminutes.com/docs/lua/>`_ (这个 `Learn X in Y minutes <https://learnxinyminutes.com/>`_ 比较有意思，通过案例让你快速入门一门语言)

配置文件路径
==============

- 先构建配置文件初始化

.. literalinclude:: nvim_ide/config_init
   :caption: 初始化 ``nvim`` 的配置路径
   :emphasize-lines: 3

上述创建了一个空的 ``~/.config/nvim/init.lua`` ，这样进入 ``nvim`` 之后执行 ``checkhealth`` 至少能够看到 ``Configuration`` 是OK状态；每次修改 ``init.lua`` 都需要重启 ``nvim`` 才能看到修改的变化

配置选项
===========

- 以下配置 ``~/.config/nvim/lua/options.lua`` 实现了功能:

  - 使用系统剪贴板
  - 在 ``nvim`` 中使用鼠标
  - Tab和空格键
  - UI配置
  - 灵活搜索

.. literalinclude:: nvim_ide/options.lua
   :language: lua
   :caption: ``~/.config/nvim/lua/options.lua``

- 在 ``init.lua`` 中添加以下配置激活使用 ``options.lua`` :

.. literalinclude:: nvim_ide/init.lua
   :language: lua
   :caption: 在 ``~/.config/nvim/lua/init.lua`` 中激活 ``options.lua``
   :emphasize-lines: 1

现在显示的效果:

.. figure:: ../../../_static/linux/desktop/nvim/options.png

   显示效果

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

安装包管理器
================

``nvim`` 通过第三方插件提供了强大的能力。有多种插件管理器，其中 :ref:`lazy.nvim` 非常受欢迎，提供了很多神奇功能:

  - 修正以来顺序
  - 锁文件 ``lazy-lock.json`` 跟踪安装的插件
  - ...

- 创建 ``~/.config/nvim/lua/plugins.lua`` :

.. literalinclude:: nvim_ide/plugins.lua
   :language: lua
   :caption: ``~/.config/nvim/lua/plugins.lua`` 管理插件

- 同样在 ``init.lua`` 中添加以下配置激活使用 ``plugins.lua`` :

.. literalinclude:: nvim_ide/init.lua
   :language: lua
   :caption: 在 ``~/.config/nvim/lua/init.lua`` 中激活 ``plugins.lua``
   :emphasize-lines: 3

这里我遇到一个报错:

.. literalinclude:: nvim_ide/nvim_ver_err
   :caption: ``nvim`` 版本低于 0.8.0 导致不能使用 lazy.nvim 报错

解决方法是 :ref:`compile_nvim_debian` ，安装自己编译的最新版本后，重新执行上述安装包管理器

参考
===========

- `Transform Your Neovim into a IDE: A Step-by-Step Guide <https://martinlwx.github.io/en/config-neovim-from-scratch/>`_
- `Learn How To Use NeoVim As an IDE <https://programmingpercy.tech/blog/learn-how-to-use-neovim-as-ide/>`_
- `GitHub: ldelossa/nvim-ide <https://github.com/ldelossa/nvim-ide>`_
