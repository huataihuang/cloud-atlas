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

   我在 :ref:`asahi_linux` ( :ref:`arm` 架构 )上，采用 ``zfs-dkms`` 来安装部署ZFS( :ref:`archlinux_archzfs` 没有提供ARM架构 )

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

.. note::

   如果不锁定内核包更新，确实有问题:

   - ``pacman -Syu`` 升级了内核，但是 :ref:`dkms` 编译时候会报错::

      (10/14) Install DKMS modules
      ==> ERROR: Missing 6.1.0-rc6-asahi-5-1-ARCH kernel headers for module zfs/2.1.6.

   但是实际上内核头文件包已经升级好了，原因排查见下文 ``升级内核问题排查``

- 加载内核模块:

.. literalinclude:: archlinux_zfs/archlinux_load_zfs
   :language: bash
   :caption: 加载zfs内核模块

检查zfs内核:

.. literalinclude:: archlinux_zfs/archlinux_lsmod_zfs
   :language: bash
   :caption: 检查zfs内核模块

此时可以看到zfs相关内核模块已经加载:

.. literalinclude:: archlinux_zfs/archlinux_lsmod_zfs_output
   :language: bash
   :caption: 检查zfs内核模块输出显示模块加载

升级内核问题排查
====================

我升级 ``pacman -Syu`` ，内核版本 ``6.1.0-rc6-asahi-5-1-ARCH`` ，但是 :ref:`dkms` 编译报错，显示头文件不存在

非常奇怪， ``pacman -Qe | grep header`` 可以看到::

   linux-asahi-headers 6.1rc6.asahi5-1

显示已经安装完成

参考 `[solved] dkms install hook fails when installing zfs-dkms <https://bbs.archlinux.org/viewtopic.php?id=280416>`_ 检查::

   # pacman -Q zfs-dkms
   zfs-dkms 2.1.6-1

   # pacman -Q linux
   linux-asahi 6.1rc6.asahi5-1

   # pacman -Q linux-asahi
   linux-asahi 6.1rc6.asahi5-1

   # pacman -Q linux-headers
   error: package 'linux-headers' was not found

   # pacman -Q linux-asahi-headers
   linux-asahi-headers 6.1rc6.asahi5-1

   # pacman -Q pahole
   pahole 1:1.24-1

我看出了一些差异:

- 最新的 :ref:`asahi_linux` 内核版本是 ``6.1rc6.asahi5-1`` ， ``uname -r`` 输出信息是 ``6.1.0-rc6-asahi-5-1-ARCH``
- 之前稳定版本内核版本是 ``5.19.asahi5-1`` ，对应的 ``uname -r`` 输出是 ``5.19.0-asahi-5-1-ARCH`` ，没有 ``rc6`` 这个中间版本字段

这或许是 ``zfs-dkms`` 去查找对应版本内核头文件出错的原因(猜测，但是不肯定，可能需要等后续 :ref:`asahi_linux` 使用稳定release 6.1 版本才能验证)

不过，查看了 `openzfs zfs-2.1.6 <https://github.com/openzfs/zfs/releases/tag/zfs-2.1.6>`_ relase文档确实说明: **Linux: compatible with 3.10 - 5.19 kernels**

在官方 `openzfs/zfs/META <https://github.com/openzfs/zfs/blob/master/META>`_ 提供了zfs软件版本支持信息::

   Meta:          1
   Name:          zfs
   Branch:        1.0
   Version:       2.1.99
   Release:       1
   Release-Tags:  relext
   License:       CDDL
   Author:        OpenZFS
   Linux-Maximum: 6.0
   Linux-Minimum: 3.10

看起来官方源代码尚未适配 6.0 以上内核

很巧，我执行 ``pacman -Syu`` 升级系统，正好遇到 :ref:`asahi_linux` 官方升级 `Updates galore! November 2022 Progress Report <https://asahilinux.org/2022/11/november-2022-report/>`_ 升级了最新内核 ``6.1``

最终解决方案(实际绕过)
---------------------------

考虑有以下解决方案:

- 参考 `AsahiLinux/linux Tags <https://github.com/AsahiLinux/linux/tags>`_ 查找适配内核版本，将内核版本降低到适配版本，即通过 :ref:`archlinux_downgrade_package`

  - :ref:`asahi_linux` 官方发行二进制版本没有提供 v6.0 内核，但是官方有源代码，理论上可以自己编译内核来满足ZFS内核版本要求
  - 或者直接采用上一个官方发行二进制版本 v5.19

- 暂时放弃使用ZFS，等 :ref:`asahi_linux` 官方发行 v6.1 正式版本，再尝试通过 :ref:`dkms` 重新编译ZFS内核模块

- 放弃在 :ref:`asahi_linux` 上使用ZFS，改为使用 :ref:`btrfs` (紧跟内核主线)，这样就不必使用 :ref:`dkms` ; 另外我在 Macbook Pro 2013 late (x86_64)上可以继续实践 :ref:`archlinux_archzfs`

我最终选择方法3: 在 :ref:`asahi_linux` 上采用 :ref:`btrfs` :

- 将精力集中在实践 :ref:`mobile_cloud_infra` 上，主攻 :ref:`kubernetes` ( :ref:`kind` )，同时也能实践 :ref:`btrfs`
- 在成熟的X86环境，相对稳定的Linux内核主线上实践 :ref:`zfs`

参考
=======

- `arch linux: zfs <https://wiki.archlinux.org/title/ZFS>`_
- `OpenZFS Getting Started: Arch Linux <https://openzfs.github.io/openzfs-docs/Getting%20Started/Arch%20Linux/index.html>`_
- `A reference guide to ZFS on Arch Linux <https://kiljan.org/2018/09/23/a-reference-guide-to-zfs-on-arch-linux/>`_ 提供了实践经验，可参考
