.. _introduce_btrfs:

====================
Btrfs文件系统简介
====================

Btrfs的优点
==============

- 卷管理可以避免分区不合理

目前在Fedora的Btrfs使用单分区磁盘配置，并且Btrfs内建了卷管理功能。之前的Ext4文件系统需要非常小心磁盘分区设置，并且对于普通用户难以调整(例如在安装时分配了过小的根目录或home目录)。而Btrfs集成了卷管理，可以避免初始分配不合理的隐患。

- 内建了数据校验功能防止数据损坏

数据存储在磁盘或者SSD中，可能存在数据腐败，物理扇区损坏，甚至辐射破坏。Btrfs的通过checksums来保障数据安全，并且在每次读取时执行校验。这样损坏的数据不会导致问题，也不会被错误备份导致在某天无法恢复。

- 写时复制特性节约存储空间也提高了性能

Btrfs的 ``copy-on-write`` 模式可以确保数据和文件系统不会覆盖，也保障了crash时数据安全。当复制文件时，Btrfs不会写入新数据，直到你真正修改了旧数据，这种方式解决了空间。

- 透明压缩功能节约空间

Btrfs的内建透明压缩功能可以降低写入消耗，节约空间并延长flash设备寿命。很多情况下，文件系统压缩功能也提高了性能。文件系统压缩可以在整个文件系统激活，也可以在子卷、目录甚至单个文件激活。

企业级使用Btrfs
==================

根据网上信息了解，Facebook可能是最积极采用Btrfs的超级互联网公司，并且雇佣了Btrfs的核心开发者，也是能够在生产环境采用Btrfs高级特性并保证稳定性的底气。

Facebook使用Btrfs的快照和镜像来隔离容器，在 `Btrfs at Facebook(facebookmicrosites) <https://facebookmicrosites.github.io/btrfs/docs/btrfs-facebook.html>`_ 透露了F厂应用Btrfs遇到的问题和解决方案。同时在LWN源代码新闻网站， `Btrfs at Facebook(LWN) <https://lwn.net/Articles/824855/>`_ 记录了Btrfs开发 Josef Bacik 在 `2020 Open Source Summit North America <https://events.linuxfoundation.org/open-source-summit-north-america/>`_ 演讲，介绍了Facebook利用Btrfs进行快速测试的隔离解决方案。

- :ref:`btrfs_facebook`

.. note::

   完整的 ``Btrfs`` 文档可以参考 `BTRFS documentation <https://btrfs.readthedocs.io/en/latest/index.html>`_

发行版对Btrfs的使用
=====================

SUSE
------

SUSE Linux Enterprise Server(SLES)在很久之前的发行版就默认采用Btrfs。由于SLES是面向企业用户，已经在很多企业环境中得到使用。

Fedora/RHEL/CentOS
---------------------

参考 `Red Hat banishes Btrfs from RHEL <https://www.theregister.co.uk/2017/08/16/red_hat_banishes_btrfs_from_rhel>`_ 报道，Red Hat在RHEL 7.4还保持Btrfs上游补丁更新，但之后放弃了Btrfs功能更新。从 RHEL 8 `Considerations in adopting RHEL 8Chapter 12. File systems and storage <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/considerations_in_adopting_rhel_8/file-systems-and-storage_considerations-in-adopting-rhel-8>`_ 可以看到Red Hat Enterprise Linux 8已经完全移除了Btrfs支持，已经不能在RHEL中创建、挂载和安装Btrfs文件系统。

.. note::

   `why redhat abandon btrfs where SUSE makes it default.? <https://access.redhat.com/discussions/3138231>`_ 最新的2021年8月 Red Hat Expert Andrew Puch 有一个详尽的答复，说明了Red Hat的文件系统路线:

   - RedHat正在从btrfs转向 :ref:`stratis` 用户层文件系统(采用Rust重写)

2020年8月发布的最新的Fedora 33修改了桌面系列(Fedora Workstation, Fedora KDE等)的默认文件系统，采用了Btrfs替代了以前版本采用的默认Ext4文件系统。在此之前，2012年开始，Fedora就已经试验性引入了Btrfs，经过8年的社区验证，终于迈出了一大步。

这意味着Btrfs的现代化特性：数据一致性、SSD优化、压缩、可写快照、多设备支持等等已经进入了稳定和成熟的状态。所以，我估计可能在后续的 Red Hat Enterprise Linux 发行版中会再度加入Btrfs支持。

.. note::

   Fedora作为Red Hat Enterprise Linux的上游版本，是很多新技术进入企业级应用阶段的前奏。Fedora验证测试的技术从一定程度上证明了技术的可靠性和稳定性，在经过几轮发行版后，验证成熟的技术极有可能融入到最新的RHEL发行版。

虚拟化和Btrfs
================

.. warning::

   参考 `rockstable libvirt文档 <https://wiki.rockstable.it/libvirt>`_ 以及 `archlinux - QEMU <https://wiki.archlinux.org/title/QEMU>`_ 如果将QEMU的虚拟磁盘镜像存储到Btrfs文件系统，需要事先关闭Btrfs目录的Copy-on-Write(CoW)功能，否则存储性能会受到影响。(这个关闭也会同时禁用了Btrfs的checksum功能，会导致Btrfs无法检测到腐败的 ``nodatacow`` 文件) 

   实际上限制很多，所以我在 KVM 实践中，将转为采用 :ref:`stratis` 作为存储文件系统(对于非 :ref:`redhat_linux` 系，也有发行版提供软件包，如 :ref:`archlinux_stratis` )

NAS方案
========

:ref:`rockstor` 提供了结合 :ref:`docker_btrfs_driver` 实现容器化运行NAS的方案，使用了很多开源架构，值得分析和研究。请参考 :ref:`introduce_rockstor` 以及我的后续实践。

我的观点
===========

Btrfs和ZFS是目前Linux系统功能最丰富同时也是最具发展潜力的本地文件系统。两者各自有独特的发展历史和技术优势，当前都已经逐步进入稳定生产状态，比早期动辄crash已经不可同日而语。

Btrfs和ZFS需要非常精心的部署和调优，以充分发挥最佳性能。但是，这两个文件系统也是非常复杂，在使用中实际上有很多需要仔细理解原理和精心配置，否则会导致数据损坏和系统异常。

建议保持持续跟进观察，并不断做性能和稳定性测试，在合适的时候正式采用Btrfs。

参考
=====

- `Btrfs SysadminGuide <https://btrfs.wiki.kernel.org/index.php/SysadminGuide>`_
- `Btrfs Coming to Fedora 33 <https://fedoramagazine.org/btrfs-coming-to-fedora-33/>`_
- `why redhat abandon btrfs where SUSE makes it default.? <https://access.redhat.com/discussions/3138231>`_
- `archlinux - QEMU <https://wiki.archlinux.org/title/QEMU>`_
