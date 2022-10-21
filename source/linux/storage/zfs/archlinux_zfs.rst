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

- 添加 archzfs 软件仓库:

.. literalinclude:: archlinux_zfs/add_archzfs_repo
   :language: bash
   :caption: 添加 archzfs 软件仓库

- 更新pacman仓库::

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

果然，我检查了 https://mirror.sum7.eu/archlinux/archzfs/archzfs/ 果然在目录下只有 ``x86_64``

通过 :ref:`archlinux_aur` 编译安装
-------------------------------------

通过 :ref:`archlinux_aur` 有多个软件发行包: `arch linux: zfs General <https://wiki.archlinux.org/title/ZFS#General>`_ 提供不同版本信息，以下几个版本可能值得关注尝试:

- zfs-linux 稳定版本
- zfs-linux-lts 针对LTS内核的稳定版本
- zfs-dkms 用于支持动态内核模块的版本

- 安装(在 :ref:`asahi_linux` 上不满足条件)::

   yay -S zfs-linux

这里安装会检测内核版本，分别对应不同的 ``zfs-linux`` 软件包，例如:

  - ``zfs-linux`` 要求 linux=6.0.2
  - ``zfs-linux-lts`` 要求 linux-lts=5.15.74-1

比较尴尬，由于是Apple Silicon M1系列处理器，使用的是 :ref:`asahi_linux` 发行版，当前采用的内核是 ``5.19.0-asahi-5-1-ARCH``

zfs-dkms
~~~~~~~~~~

需要自己按照内核来编译，也就是采用 :ref:`dkms` 安装对应的 ``zfs-dkms`` 

- 检查内核variant(变种):

.. literalinclude:: archlinux_zfs/archlinux_check_kernel_variant
   :language: bash
   :caption: 检查当前内核variant

验证::

   echo $INST_LINVAR

输出是::

   linux-asahi

- 检查内核版本:

.. literalinclude:: archlinux_zfs/archlinux_check_kernel_version
   :language: bash
   :caption: 检查当前内核版本

可以验证一下::

   echo $INST_LINVER

输出是::

   5.19.asahi5-1

- 安装内核头文件:

.. literalinclude:: archlinux_zfs/archlinux_install_kernel_headers
   :language: bash
   :caption: 安装当前内核版本对应头文件

可以看到对应安装的是::

   linux-asahi-headers-5.19.asahi5-1

- 安装zfs-dkms:

.. literalinclude:: archlinux_zfs/archlinux_install_zfs-dkms
   :language: bash
   :caption: 安装zfs-dkms

如果出现编译正常但是安装类似如下报错，则说明系统缺少内核对应头文件::

   ...
   (1/1) installing zfs-dkms                                                       [#############################################] 100%
   :: Running post-transaction hooks...
   (1/2) Arming ConditionNeedsUpdate...
   (2/2) Install DKMS modules
   ==> ERROR: Missing bin kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing proc kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing mnt kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing lib kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing boot kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing var kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing root kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing srv kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing usr kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing run kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing tmp kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing sbin kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing sys kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing dev kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing home kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing etc kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing lost+found kernel headers for module zfs/2.1.6.
   ==> ERROR: Missing opt kernel headers for module zfs/2.1.6.

这个报错是我疏忽了，没有遵照 `OpenZFS官方文档:Getting Started>>Arch Linux>>zfs-dkms <https://openzfs.github.io/openzfs-docs/Getting%20Started/Arch%20Linux/2-zfs-dkms.html>`_ ，遗漏安装内核头文件导致的。我重新按照该文档完整走一遍(已经修订上文)

- (我没有执行)忽略内核包更新::

   sed -i 's/#IgnorePkg/IgnorePkg/' /etc/pacman.conf
   sed -i "/^IgnorePkg/ s/$/ ${INST_LINVAR} ${INST_LINVAR}-headers/" /etc/pacman.conf

- 加载内核模块:

.. literalinclude:: archlinux_zfs/archlinux_load_zfs
   :language: bash
   :caption: 加载zfs内核模块


参考
=======

- `arch linux: zfs <https://wiki.archlinux.org/title/ZFS>`_
- `OpenZFS Getting Started: Arch Linux <https://openzfs.github.io/openzfs-docs/Getting%20Started/Arch%20Linux/index.html>`_
- `A reference guide to ZFS on Arch Linux <https://kiljan.org/2018/09/23/a-reference-guide-to-zfs-on-arch-linux/>`_ 提供了实践经验，可参考
