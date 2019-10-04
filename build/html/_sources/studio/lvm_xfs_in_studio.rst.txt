.. _lvm_xfs_in_studio:

=======================
Studio环境的LVM+XFS存储
=======================

.. note::

   最初我选择 :ref:`btrfs_in_studio` ，主要考虑到Btrfs文件系统接近ZFS的特性，结合了卷管理和文件系统的高级特性，灵活并且充分利用好磁盘空间。在 :ref:`ubuntu_on_mbp` 采用Btrfs构建libvirt卷和Docker卷，确实非常方便管理和维护。

   不过， :ref:`archlinux_on_thinkpad_x220` 实践中，我为了体验技术，启用了Btrfs的磁盘透明压缩功能。这次尝试似乎带来了不稳定的因素，Btrfs出现csum错误。目前我还不确实是否是因为SSD磁盘存在硬件故障。

   从Red Hat Enterprise Linux 8开始，Red Hat放弃了Btrfs支持，这对于企业运行RHEL/CentOS环境，实际上已经变相阻止了Btrfs。原因可能比较复杂，一方面是Btrfs的高级特性(如RAID)一直不稳定，另一方面可能和Oracle和Red Hat的存储竞争策略冲突相关。

   Red Hat系列一直主推的是XFS系统，这个XFS文件系统在长期的发展中已经在数据库领域取得了很好的口碑。以我的运维经验和对我厂数据库部署的了解，当前XFS文件系统确实是数据库本地磁盘首选的文件系统。

方案选择
==========

- 存储分区需要能够灵活调整，所以需要采用LVM卷管理来划分磁盘分区
- 需要有高性能文件系统，对SSD存储优化，并适合大型应用运行

LVM + XFS是适合数据库应用运行的Linux存储组合，并且也是Red Hat主推的用于取代ZFS和Btrfs的 `Stratis项目 <https://stratis-storage.github.io/>`_ 底层技术堆栈。所以，我选择这个存储技术组合。


