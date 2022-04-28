.. _debian_init:

====================
Debian精简系统初始化
====================

实际上，众多的Linux发行版都是基于Debian构建的，包括:

- :ref:`ubuntu_linux`
- :ref:`kali_linux`
- ``Raspberry Pi OS``

我在 :ref:`pi_400` 上构建 :ref:`mobile_pi_dev` 采用Lite版本安装后定制，安装初始化步骤是所有debian系共通的。

精简步骤见 :ref:`mobile_pi_dev` ，本文记录安装软件列表：

- 精简图形系统 :ref:`sway`

- 中文字体 :ref:`linux_chinese_view`

- 中文输入: :ref:`fcitx_sway`

- 终端: ``qterminal`` / 浏览器: ``falkon``

软件安装步骤
===============

- 应用软件安装:

.. literalinclude:: debian_init/debian_init_app
   :language: bash
   :caption: debian系安装应用



