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

- :ref:`btrfs_facebook`

发行版对Btrfs的使用
=====================

SUSE
------

SUSE Linux Enterprise Server(SLES)在很久之前的发行版就默认采用Btrfs。由于SLES是面向企业用户，已经在很多企业环境中得到使用。

Fedora/RHEL/CentOS
---------------------

2020年8月发布的最新的Fedora 33修改了桌面系列(Fedora Workstation, Fedora KDE等)的默认文件系统，采用了Btrfs替代了以前版本采用的默认Ext4文件系统。在此之前，2012年开始，Fedora就已经试验性引入了Btrfs，经过8年的社区验证，终于迈出了一大步。

这意味着Btrfs的现代化特性：数据一致性、SSD优化、压缩、可写快照、多设备支持等等已经进入了稳定和成熟的状态。

.. note::

   Fedora作为Red Hat Enterprise Linux的上游版本，是很多新技术进入企业级应用阶段的前奏。Fedora验证测试的技术从一定程度上证明了技术的可靠性和稳定性，在经过几轮发行版后，验证成熟的技术极有可能融入到最新的RHEL发行版。


参考
=====

- `Btrfs SysadminGuide <https://btrfs.wiki.kernel.org/index.php/SysadminGuide>`_
- `Btrfs Coming to Fedora 33 <https://fedoramagazine.org/btrfs-coming-to-fedora-33/>`_
