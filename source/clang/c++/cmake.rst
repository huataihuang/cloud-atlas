.. _cmake:

======================
CMake
======================

CMake 是构建 C++ 代码的事实标准:

- 干净、强大且优雅: 可以将大部分时间花在编码上，而不是向不可读、不可维护的 Make 文件添加行
- 每个 IDE 都支持 CMake（或 CMake 支持该 IDE）

安装
=====

.. note::

   - CMake 版本应该比编译器新
   - CMake 版本应该比正在使用的库（尤其是 Boost）更新
   - CMake 新版本更适合每个人

可以轻松地在系统级别或用户级别安装CMake 新版本

官方
-----

`KitWare下载CMake <https://cmake.org/download/>`_ Windows / macOS 版本(但 :ref:`macos` 使用 :ref:`homebrew` 会更好)

在 Linux 上，有多种选择:

- `KitWare下载CMake <https://cmake.org/download/>`_ 提供了通用 Linux 二进制文件
- Kitware 提供了 Debian/Ubuntu :ref:`apt` repo库以及 snap 包

运行
=====

几乎(一切)所有 CMake 项目 **经典的 CMake 构建过程** :

.. literalinclude:: cmake/cmake
   :caption: 经典的 CMake 构建过程

to be continue...

refer
===========

- `An Introduction to Modern CMake <https://cliutils.gitlab.io/modern-cmake/>`_
- `CMake Tutorial <https://medium.com/@onur.dundar1/cmake-tutorial-585dd180109b>`_
