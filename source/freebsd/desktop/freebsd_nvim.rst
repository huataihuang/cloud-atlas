.. _freebsd_nvim:

===================
FreeBSD neovim
===================

.. note::

   采用在 :ref:`vnet_thin_jail` 基础上构建工作环境

   在FreeBSD上 :ref:`nvim_ide_fix` 存在一定的困难，所以我会重新实践 :ref:`nvim_ide_freebsd` 

安装
===========

- 使用FreeBSD发行版安装:

.. literalinclude:: freebsd_nvim/install
   :caption: 安装neovim

FreeBSD提供了基础的neovim安装，只需要大约20M空间，非常小巧

- 采用 :ref:`nvim_base_config` 简单配置一下方便日常编辑:

.. literalinclude:: ../../linux/desktop/nvim/startup/nvim_base_config/init.lua
   :caption: 在 ``~/.config/nvim/init.lua`` 中配置初始设置

.. note::

   我的开发环境准备构建在 :ref:`freebsd_jail` 中，类似于 :ref:`docker` 容器构建日常统一的开发环境

- 在 ``~/.cshrc`` 中配置 ``nvim`` 作为日常 ``vi`` 的替代(虽然 `Change default editor from vi to vim or nvim on FreeBSD <https://stackoverflow.com/questions/41409060/change-default-editor-from-vi-to-vim-or-nvim-on-freebsd>`_ 提到 ``/etc/login.conf`` 可以修订默认的 ``EDITOR=vi`` ，但是这个环境变量可以通过 ``~/.cshrc`` 自定义覆盖):

.. literalinclude:: freebsd_nvim/cshrc
   :caption: 在 ``~/.cshrc`` 中配置alias


参考
======

- `Change default editor from vi to vim or nvim on FreeBSD <https://stackoverflow.com/questions/41409060/change-default-editor-from-vi-to-vim-or-nvim-on-freebsd>`_
