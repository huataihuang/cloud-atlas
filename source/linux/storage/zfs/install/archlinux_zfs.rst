.. _archlinux_zfs:

===================
Arch Linux上运行ZFS
===================

由于ZFS代码的CDDL license和Linux内核GPL不兼容，所以ZFS开发不能被内核支持。

这导致以下情况:

- ZFSonLinux项目必须紧跟Linux内核版本，当ZFSonLinux发布稳定版本，Arch ZFS维护者就发布
- 这种情况有时会通过不满足的依赖关系锁定正常的滚动更新过程，因为更新提出的新内核版本不受 ZFSonLinux 的支持。

安装
=======

在Arch Linux上安装有3种方式:

- :ref:`archlinux_archzfs`
- :ref:`archlinux_zfs-dkms_arm` / :ref:`archlinux_zfs-dkms_x86`
- zfs-linux 针对不同内核进行安装

.. note::

   推荐采用 :ref:`dkms` 方式，可以在每次内核升级变动时自动重新编译ZFS内核模块

使用
========

参考
=======

- `arch linux: zfs <https://wiki.archlinux.org/title/ZFS>`_
- `OpenZFS Getting Started: Arch Linux <https://openzfs.github.io/openzfs-docs/Getting%20Started/Arch%20Linux/index.html>`_
- `A reference guide to ZFS on Arch Linux <https://kiljan.org/2018/09/23/a-reference-guide-to-zfs-on-arch-linux/>`_ 提供了实践经验，可参考
