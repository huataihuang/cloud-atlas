.. _fedora_zfs:

===================
Fedora上运行ZFS
===================

.. note::

   本文实践是在 :ref:`fedora` 虚拟机 ，也就是 :ref:`z-dev` 上完成: 即在现有操作系统上安装ZFS

安装
=======

- 如果已经安装了 ``zfs-fuse`` 软件包，需要先卸载::

   rpm -e --nodeps zfs-fuse

- 添加ZFS仓库:

.. literalinclude:: fedora_zfs/fedora_zfs_repo
   :language: bash
   :caption: Fedora添加ZFS软件仓库

- 安装kernel headers:

.. literalinclude:: fedora_zfs/kernel-devel
   :language: bash
   :caption: 安装 ``kernel-devel``

- 安装ZFS:

.. literalinclude:: fedora_zfs/dnf_install_zfs
   :language: bash
   :caption: 安装ZFS

- 加载ZFS内核，并且配置每次启动操作系统时自动加载ZFS内核:

.. literalinclude:: fedora_zfs/zfs_kernel_module
   :language: bash
   :caption: 加载ZFS内核模块以及配置自动加载

如果提示内核模块加载失败，可以检查一下当前运行内核版本和安装ZFS模块对应内核版本是否一致(例如之前做了操作系统升级但尚未重启未切换到新内核)

一切正常的化，执行 ``lsmod | grep zfs`` 可以看到如下zfs内核模块已经加载::

   zfs                  3956736  6
   zunicode              335872  1 zfs
   zzstd                 589824  1 zfs
   zlua                  188416  1 zfs
   zavl                   16384  1 zfs
   icp                   323584  1 zfs
   zcommon               106496  2 zfs,icp
   znvpair               110592  2 zfs,zcommon
   spl                   126976  6 zfs,icp,zzstd,znvpair,zcommon,zavl

接下来，可以通过 :ref:`zfs_virtual_disks` 学习如何使用和维护ZFS

参考
=====

- `OpenZFS Getting Started: Fedora <https://openzfs.github.io/openzfs-docs/Getting%20Started/Fedora/index.html>`_
