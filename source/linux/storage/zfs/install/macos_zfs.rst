.. _macos_zfs:

===============
macOS上运行ZFS
===============

:ref:`homebrew` 安装openzfs
============================

`Homebrew openzfs <https://openzfsonosx.org/wiki/Main_Page>`_ 提供了快速在macOS上安装ZFS的方法，其采用了 `OpenZFS on OS X <https://openzfsonosx.org>`_ 开发的版本。从支持列表来看X86系列可以支持最新 macOS Sequoia 15系列，而Appple Silicon 则支持操作系统落后。

.. literalinclude::  macos_zfs/brew_openzfs
   :caption: 使用 :ref:`homebrew` 安装OpenZFS

我在 :ref:`mbp15_2018` (Intel x86架构)笔记本上安装，操作系统是 ``sequoia`` 提示似乎没有正确安装对应版本，回落到上个发行版本 ``sonoma`` ? 不过看 `Homebrew openzfs <https://openzfsonosx.org/wiki/Main_Page>`_ 列表 sequoia 和 sonoma 都使用了相同的 ``2.2.2,509`` OpenZFS软件包:

.. literalinclude::  macos_zfs/brew_openzfs_output
   :caption: 使用 :ref:`homebrew` 安装OpenZFS输出

.. note::

   系统默认会阻止加载模块，在安装过程中会弹出macOS ``System Settings`` 页面，请注意其中 ``Privacy & Security`` 页面中有提示::

      System software from developer "Joergen Lundman" was blocked from loading.

   这个开发者 `Joergen Lundman <https://github.com/lundman>`_ 是OpenZFS开发者，需要允许加载，并重启操作系统生效

使用
======

- 尝试检查:

.. literalinclude::  macos_zfs/zfs_list
   :caption: ``zfs list`` 检查

提示需要加载扩展模块

.. literalinclude::  macos_zfs/zfs_list_output
   :caption: ``zfs list`` 提示需要加载 ``zfs.kext``

则说明前面安装过程没有在 ``System Settings => Privacy & Security`` 页面允许加载开发者 "Joergen Lundman" 的系统软件(即内核模块)


参考
=====

- `OpenZFS on OS X wiki: <https://openzfsonosx.org/wiki/Main_Page>`_
