.. _archlinux_archzfs:

===========================================
使用archzfs软件仓库在arch linux上部署ZFS
===========================================

由于ZFS代码的CDDL license和Linux内核GPL不兼容，所以ZFS开发不能被Linux内核支持。

这导致以下情况:

- ZFSonLinux项目必须紧跟Linux内核版本，当ZFSonLinux发布稳定版本，Arch ZFS维护者就发布
- 这种情况有时会通过不满足的依赖关系锁定正常的滚动更新过程，因为更新提出的新内核版本不受 ZFSonLinux 的支持。

安装
=======

在Arch Linux上安装有两种方式:

- 使用 `archzfs repo <https://github.com/archzfs/archzfs>`_
- 下载源代码编译安装

通过软件仓库二进制安装包
---------------------------

采用比较简单的方式，即直接使用 `archzfs repo <https://github.com/archzfs/archzfs>`_ 安装

- 导入 archzfs 仓库key:

.. literalinclude:: archlinux_zfs/import_archzfs_key
   :language: bash
   :caption: 导入 archzfs 软件仓库密钥

- 添加 archzfs 软件仓库，并更新 :ref:`pacman` 仓库:

.. literalinclude:: archlinux_zfs/add_archzfs_repo
   :language: bash
   :caption: 添加 archzfs 软件仓库

- archzfs 软件仓库提供了多种安装包组合，执行安装:

.. literalinclude:: archlinux_zfs/archzfs_install
   :language: bash
   :caption: 安装 archzfs 提供多种安装包组合，选择 ``zfs-linux`` 是面向Arch Linux默认内核和最新OpenZFS稳定版本
   :emphasize-lines: 8,12

我选择 5 ( ``zfs-linux`` )安装

archzfs的限制
----------------

- archzfs 安装的zfs和内核严密绑定，所以如果 archzfs 提供对应内核版本之前， :ref:`arch_linux` 无法升级内核，会提示类似如下错误:

.. literalinclude:: archlinux_archzfs/archzfs_kernel_break
   :language: bash
   :caption: 由于archzfs和内核紧密关联，需要同时升级archzfs和kernel
   :emphasize-lines: 10

如果要紧跟内核升级，那么需要采用 :ref:`archlinux_zfs-dkms`

ARM架构下无法使用archzfs
=========================

- 我在 :ref:`asahi_linux` 平台(ARM架构的 :ref:`apple_silicon_m1_pro` MacBook Pro 16")更新pacman仓库遇到以下报错::

   pacman -Sy

这里我遇到报错::

   archzfs.db failed to download
   error: failed retrieving file 'archzfs.db' from archzfs.com : The requested URL returned error: 404
   error: failed retrieving file 'archzfs.db' from mirror.sum7.eu : The requested URL returned error: 404
   error: failed retrieving file 'archzfs.db' from mirror.biocrafting.net : The requested URL returned error: 404
   error: failed retrieving file 'archzfs.db' from mirror.in.themindsmaze.com : The requested URL returned error: 404
   error: failed retrieving file 'archzfs.db' from zxcvfdsa.com : The requested URL returned error: 404
   error: failed to synchronize all databases (failed to retrieve some files)

难道是不能提供aarch64架构？

果然，我检查了 https://mirror.sum7.eu/archlinux/archzfs/archzfs/ 果然在目录下只有 ``x86_64`` ，放弃...

通过 :ref:`archlinux_aur` 编译安装
-------------------------------------

通过 :ref:`archlinux_aur` 有多个软件发行包: `arch linux: zfs General <https://wiki.archlinux.org/title/ZFS#General>`_ 提供不同版本信息，以下几个版本可能值得关注尝试:

- zfs-linux 稳定版本
- zfs-linux-lts 针对LTS内核的稳定版本
- zfs-dkms 用于支持动态内核模块的版本

- 安装(在 :ref:`asahi_linux` 上不满足条件，但可以在x86的 :ref:`arch_linux` 上实践)::

   yay -S zfs-linux

这里安装会检测内核版本，分别对应不同的 ``zfs-linux`` 软件包，例如:

  - ``zfs-linux`` 要求 linux=6.0.2
  - ``zfs-linux-lts`` 要求 linux-lts=5.15.74-1

比较尴尬，由于是Apple Silicon M1系列处理器，使用的是 :ref:`asahi_linux` 发行版，当前采用的内核是 ``5.19.0-asahi-5-1-ARCH``

参考
=======

- `arch linux: zfs <https://wiki.archlinux.org/title/ZFS>`_
- `OpenZFS Getting Started: Arch Linux <https://openzfs.github.io/openzfs-docs/Getting%20Started/Arch%20Linux/index.html>`_
- `A reference guide to ZFS on Arch Linux <https://kiljan.org/2018/09/23/a-reference-guide-to-zfs-on-arch-linux/>`_ 提供了实践经验，可参考
