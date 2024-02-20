.. _gentoo_wine:

=====================================
Gentoo平台wine环境运行Windows程序
=====================================

32位程序
==========

Wine依赖必须启用 ``abi_x86_32`` ，这是不可避免的设置，所以操作系统不能禁用 ``abi_x86_32`` 而仅使用 ``abi_x86_64`` 安装。如果仅安装没有32位支持的wine，将无法安装或启动应用程序。

Wine的某些依赖需要在内核中配置设置 ``CONFIG_COMPAT_32BIT_TIME`` 才能工作，否则会出现类似以下报错::

   The futex facility returned an unexpected error code.

受影响的软件包包括 ``dev-libs/icu`` 和 ``sys-devel/llvm``

.. note::

   最初，我想构建纯64位的操作系统。:ref:`install_gentoo_on_mbp` 我特意选择了 no-multilib ，所以整个操作系统不需要兼容32位，我也去除了内核的32位支持。

   但是Wine需要32位支持，如果我后续需要实践Wine来运行Windows程序，甚至我想构建基于 :ref:`xpra` 来远程运行Windows程序，都需要底层操作系统来支持32位运行Wine。

   :strike:`为了不影响我的纯粹64位底座操作系统，我准备运行一个 multilib 的Gentoo Linux  虚拟机来实验这个场景。`




参考
======

- `gentoo wiki: Wine <https://wiki.gentoo.org/wiki/Wine>`_
