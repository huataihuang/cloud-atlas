.. _build_rebaruefi:

========================
编译ReBarUEFI
========================

.. note::

   编译环境 Ubuntu 26.04

编译环境准备
===============

- 运行以下命令安装 EDK II 编译所需的基础工具、Python 运行环境、汇编器及依赖库：

.. literalinclude:: build_rebaruefi/apt
   :caption: 安装编译环境

说明:

  - acpica-tools 提供了 ASL 编译器 iasl
  - nasm 用于编译 16/32/64 位微处理器代码
  - qemu-system-x86 可选，用于后续通过 QEMU 测试编译出的 OVMF 固件

ReBarDxe
============

- 下载edk2并准备

.. literalinclude:: build_rebaruefi/edk2
   :caption: 下载edk2并准备

- 编辑 ``Conf/target.txt`` :

.. literalinclude:: build_rebaruefi/target.txt
   :caption: ``Conf/target.txt``

注意，原文写 ``TOOL_CHAIN_TAG        = GCC5`` 但是现在 ``Conf/tools_def.txt`` 的注释中说明了从 3.06 版本开始已经移出了 ``GCC48, GCC49 and GCC5`` 特定版本标签，现在统一将通用 GCC 工具链命名为 ``GCC``

- 编译:

.. literalinclude:: build_rebaruefi/build
   :caption: 编译FFS

上述编译过程最后有一个复制 .pdb 文件到调试目录，报错信息可以忽略

完成后可以在 ``edk2`` 的项目目录下 ``Build/ReBarUEFI/RELEASE_GCC/X64/`` 子目录中找到 ``ReBarDxe.ffs``

ReBarState
=============

.. literalinclude:: build_rebaruefi/rebarstate
   :caption: 编译ReBarState

完成编译以后，在当前 build 目录细就有一个 ``ReBarState`` 执行程序

参考
=======

- `xCuri0/ReBarUEFI Building <https://github.com/xCuri0/ReBarUEFI/wiki/Building>`_
