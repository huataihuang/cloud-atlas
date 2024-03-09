.. _gentoo_neovim:

===================
Gentoo neovim
===================

:ref:`neovim` 是 :ref:`vim` 增强和改进，具有开箱即用的优点。( :ref:`vim_vs_neovim` )

安装
=======

- 如果系统已经按转过 :ref:`vim` 可以通过以下命令移除:

.. literalinclude:: gentoo_neovim/remove_vim
   :caption: 卸载系统已经安装的vim

- 安装 :ref:`neovim` :

.. literalinclude:: gentoo_neovim/install_neovim
   :caption: 安装neovim

配置默认编辑器
==================

为了方便使用，例如 ``vi`` 能够直接使用 ``nvim`` 并且默认编辑器设置为 ``nvim`` 执行以下命令(见 :ref:`eselect` )

- 执行以下命令创建 :ref:`neovim` 映射到 ``vi`` :

.. literalinclude:: eselect/vi_set
   :caption: 设置 :ref:`neovim` 映射到 ``vi``

- 设置默认 ``editor`` 编辑器:

.. literalinclude:: eselect/editor_set
   :caption: 设置 ``EDITOR``

参考
=======

- `gentoo linux wiki: Neovim <https://wiki.gentoo.org/wiki/Neovim>`_
- `GitHub: neovim/neovim <https://github.com/neovim/neovim>`_
