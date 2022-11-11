.. _archlinux_zfs-dkms:

====================================
使用zfs-dkms在arch linux编译安装ZFS
====================================

``zfs-dkms`` 软件包提供了 :ref:`dkms` 支持，可以自动为兼容内核编译ZFS内核模块

优点:

- 可以定制自己的内核
- 可以不必等待内核发行版更新

缺点:

- 编译比较缓慢(对于现代超强CPU可以忽略)
- 如果DKMS编译失败很少有告警(需要仔细关注)

需要自己按照内核来编译，也就是采用 :ref:`dkms` 安装对应的 ``zfs-dkms`` 

.. note::

   我在 :ref:`asahi_linux` ( :ref:`arm` 架构 )上，采用 ``zfs-dkms`` 来安装部署ZFS

安装
=======

- 检查内核variant(变种):

.. literalinclude:: archlinux_zfs-dkms/archlinux_check_kernel_variant
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
