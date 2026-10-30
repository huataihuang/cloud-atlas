.. _freebsd_nvim_ide:

=======================
FreeBSD环境NeoVim IDE
=======================

之前在Linux平台 :ref:`nvim_ide_fix` ，但是 ``LSP`` 配置采用 `blink.cmp <https://github.com/saghen/blink.cmp>`_ 移植到FreeBSD平台有一些问题，所以我在前半部分采用 :ref:`nvim_ide_fix` 相同方法，后半部分再独立探索

.. warning::

   本文方法废弃，为了降低折腾，我现在改为采用更为通用的 ``init.lua`` 来配置 :ref:`nvim_lightweight_ide`


参考
======

- `从零开始配置 Neovim(Nvim) <https://martinlwx.github.io/zh-cn/config-neovim-from-scratch/>`_
- `Neovim as an IDE for programming <https://forums.freebsd.org/threads/neovim-as-an-ide-for-programming.97059/>`_
- `Perfect Neovim Ansible Setup <https://vermaden.wordpress.com/2024/03/13/perfect-neovim-ansible-setup/>`_
