.. _rust_startup:

=======================
Rust快速起步
=======================

Rust简介
===========

Rust是开源基金会Mozilla推动开发，借鉴了现代语言研究成果，创造出天然安全性开发语言(无法在安全的Rust代码中执行非法内存操作)。

安装Rust
===========

- 在Linux或macOS中安装只需要执行一下命令:

.. literalinclude:: rust_startup/install_rust.sh
   :language: bash
   :caption: Liinux平台安装Rust

如果需要查看安装参数帮助::

   curl https://sh.rustup.rs -sSf | sh -s -- --help

更新Rust
------------

- 使用以下命令更新Rust版本::

   rustup update

- 也提供了卸载功能::

   rustup self uninstall

使用tips
==============

- 检查版本::

   rustc --version

- 安装工具在本地已经生成了一个离线文档，可以通过以下命令在浏览器中阅读::

   rustup doc

Hello, World!
================

- 创建项目目录::

   mkdir ~/projects
   cd ~/projects
   mkdir hello_world
   cd hello_world

- 最简单的Rust程序:

.. literalinclude:: rust_startup/main.rs
   :language: rust
   :caption: Rust Hello World

- 然后执行以下命令编译和运行::

   rustc main.rs
   ./main

输出显示::

   Hello, world!

参考
=======

- 「Rust权威指南」
