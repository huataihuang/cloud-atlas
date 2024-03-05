.. _update-alternatives:

========================
update-alternatives
========================

在安装了 :ref:`neovim` 之后(同时卸载了 :ref:`vim` )，遇到的问题是，系统没有了默认的 ``vim`` 或 ``vi`` ，而只有 ``nvim`` 。这对于习惯于使用 ``vi`` 命令有一点点不便。

.. note::

   :ref:`gentoo_linux` 没有提供 ``update-alternative`` ，而是采用了 :ref:`eselect` 来实现 ``update-alternative`` 相似的功能。

通常我们会想到使用 ``alias`` 命令，例如:

.. literalinclude:: update-alternatives/alias_nvim
   :caption: 使用 ``alias`` 来设置 ``nvim`` 替代 ``vim``

此外，在 :ref:`git` 配置编辑器，可以使用:

.. literalinclude:: update-alternatives/git_nvim
   :caption: 设置git使用nvim

不过， **Linux系统提供了一个非常有用的工具 update-alternatives** 提供了别名管理跟踪功能。

``update-alternatives`` 使用了符号链接来跟踪别名，然后 ``update-alternatives`` 接受命令来管理别名而无需直接处理底层链接。

参考
======

- `The update-alternatives Command in Linux <https://www.baeldung.com/linux/update-alternatives-command>`_
- `What exactly does 'update-alternatives' do? <https://askubuntu.com/questions/233190/what-exactly-does-update-alternatives-do>`_
- `Make Neovim your default vim — the right way <https://medium.com/@troelslenda/make-neovim-your-default-vim-the-right-way-73396c3570cd>`_
- `Change 'vim' and 'vi' command to 'nvim'? <https://www.reddit.com/r/neovim/comments/4r9kwa/change_vim_and_vi_command_to_nvim/>`_
