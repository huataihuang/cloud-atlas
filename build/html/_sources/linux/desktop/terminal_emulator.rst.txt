.. _terminal_emulator:

================
Linux终端模拟器
================

终端模拟器是Linux平台最重要和最常用的应用程序，我一直以阿来都期望使用轻量级同时具备良好中文支持和功能设置简便的终端模拟器。

通常我们都会使用各自使用的桌面内嵌的终端模拟器，例如，我青睐 :ref:`xfce` 桌面系统，所以我通常会使用 `xfce4-terminal` 。不过，在Linux桌面有各种终端模拟软件，有些还别具特色，特别是某些终端模拟器器软件对中文支持良好，有些则资源占用极少轻量级。

这里汇总一些从 `22 Best Free Linux Terminal Emulators (Updated 2020) <https://www.linuxlinks.com/ terminalemulators/>`_ 了解到对Linux终端模拟器(这个文档还提供了对比)，后续在桌面中我会选择部分使用并实践。

.. note::

   通过文档信息对比，目前我比较倾向于Alacriotty(GPU硬件加速，但需要编译安装)和uxvrt(轻量级性能最优，但需要解决 :ref:`uxvrt_ch_font` )。

Alacriotty
===============

.. note::

   参考 `Essential System Tools: Alacritty – hardware-accelerated terminal emulator <https://www.linuxlinks.com/essential-system-tools-alacritty-hardware-accelerated-terminal-emulator/>`_ 

   Alacritty是一个GPU硬件加速的终端模拟器，性能较好节约资源。由于 :ref:`pi_400` 这样的树莓派硬件资源有线，所以特别适合这种能够使用硬件加速显示的终端模拟。

Alacritty是一个比较新的开源软件，很可能没有提供二进制安装包，所以需要从github获取源代码进行编译安装

.. note::

   待实践

Terminus和Hyper
===================

``Terminus`` 和 ``Hyper`` 都是基于WEB技术(Electron app)，比较有特色，提供了很多现代化的功能特色。软件使用webpack构建，并且软件使用Typescript语言开发，并使用了Angular框架。

.. note::

   使用Electron构建的终端模拟器外观华丽，但是这类应用程序非常消耗内存(Hyper甚至可以占用240MB)，所以我个人不太喜欢，还是倾向于使用轻量级终端模拟器。

urxvt
==========

``rxvt-unicode`` (通常也称为 ``urxvt`` )还是一个轻量级并且运行迅速的xterm替代软件，非常节约内存使用(使用了客户服务器技术在多个窗口时可以降低内存消耗)，并且支持unicode。urxvt是很多发行版提供的基础软件。

我在使用urxvt遇到的问题是字体显示问题，暂时还没有实践中文字体显示美化。

对于系统资源有限的硬件平台(例如树莓派)，使用urxvt是一个比较好的选择。

Tilix
========

Tilix是一个平铺式终端模拟器，有些类似结合了 :ref:`i3` 的终端模拟器。不过，通过资料了解，我暂时看不出优势。毕竟我使用 :ref:`i3` 可以完全实现平铺，而 :ref:`xfce` 也可以配置使用平铺。

kitty
==========

Kitty和Alacritty类似，也是GPU加速的终端模拟器，不过内存使用较多，并且bug也较多。和Alacritty只提供基础系统工具能力(精简)，kitty还提供了较丰富的功能，这样也就比较沉重。

Guake/Tilda
==============

Guake针对Gnome平台开发的下拉式终端，Tilda则是GTK应用程序，可以根据你使用的平台选择。

参考
=====

- `22 Best Free Linux Terminal Emulators (Updated 2020) <https://www.linuxlinks.com/terminalemulators/>`_
