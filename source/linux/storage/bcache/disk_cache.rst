.. _disk_cache:

=================
磁盘缓存技术
=================

方案选型
===========

在研究Intel和美光开发的 :ref:`linux_pmem` ，即 Intel Optane Memory技术时，仔细对比了 :ref:`hpe_dl360_gen9` 所支持的类似 :ref:`nvdimm_ram` 非易失RAM技术，感觉这种高速固态存储确实有极大性能加速优势。然而，
新技术也要求极高的硬件环境，作为个人技术磨练的二手服务器，无法找到匹配的方式。

不过，我在查找资料时候，曾经想我使用 :ref:`samsung_pm9a1` 通过 :ref:`ovmf` 虚拟机 :ref:`install_ceph_manual` ，那么能否用类似 Intel Optane Memory的技术进行加速？

在早期SSD极为昂贵的时期，云计算厂商会采用SSD配合HDD，来实现混合存储。类似的技术，有 `bcache <https://en.wikipedia.org/wiki/Bcache>`_ ，已经进入Linux内核主线，并且持续开发。而LVM也内置了卷缓存技术，采用 ``lvmcache`` 可以混合SSD和HDD，加速性能。这种LVM内置的缓存技术，使用和维护较为方便。

除了这种透明的混合SSD+HDD技术，还可以考虑对日志型文件系统，采用分离日志和数据存储方式，甚至将元数据分离，将关键数据(日志/元数据)独立到高速SSD上来加速:

- ZFS
- XFS ( :ref:`stratis`  )
- :ref:`gluster`

目前我在 :ref:`hpe_dl360_gen9` 配置了1块SSD，另外准备再购买3块HDD，来构建一种混合存储的 :ref:`gluster` 。后续， :strike:`可以采购3块小规格的SSD` 再购买3块SSD磁盘，通过SSD磁盘(划分一个缓存分区或卷)，来加速使用HDD的GlusterFS的性能。 - 我准备构建2个GlusterFS集群，一个采用全SSD，运行 :ref:`ovirt` 构建虚拟化和在线存储，另一个使用HDD混合SSD，构建 :ref:`gluster_geo-replication` ，模拟远程灾备。此外，第二个HDD混合SSD的集群，也运行 :ref:`ceph_geo-replication` 模式模拟远程灾备。

参考
=========

- `Bcache against Flashcache for Ceph Object Storage <https://blog.selectel.com/bcache-vs-flashcache/>`_ 对比了Bcache和Flashcache，推荐采用Bcache，后续可以参考该文档进行对比测试
- `Disk caching in the year 2020 <https://gilslotd.com/blog/disk_caching_year_2020>`_
