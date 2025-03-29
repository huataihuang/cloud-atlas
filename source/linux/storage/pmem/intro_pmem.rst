.. _intro_pmem:

=====================
持久内存技术简介
=====================

.. note::

   本文只是草稿，我对Intel Optane的持久内存技术很感兴趣，如果有条件想实践一下:

   - 采用Optane加速 :ref:`ceph` 存储RocksDB(元数据)
   - 采用Optane加速 ClickHouse LDAP数据库性能

英特尔在 2019 年 4 月的大规模数据中心活动中正式推出 Optane 持久内存产品线。 傲腾（Optane）属于相变存储器（Phase-change RAM），典型的性能水平都要超出NAND SSD的性能很多。但是，需要较新的CPU处理器，例如 Xeon8200 和 9200 系列可以充分利用 Optane 持久内存的优势。

由于 Optane 是英特尔的产品（与美光合作开发），所以意味着 AMD 和 ARM 的服务器处理器不能够支持它。

Optane 持久内存采用Intel与美光合作研发的 3D Xpoint 内存技术。3D Xpoint 是一种比 SSD 更快的非易失性内存，速度几乎与 DRAM 相近，而且它具有 NAND 闪存的持久性。

有2种使用模式:

- 作为标准NVMe-PCIe SSD: 通常采用 M.2 接口，NVMe PCIe 格式，或者是U.2接口。
- 作为内存或板载加速设备: 采用NVDIMM(非易失性主内存)，这种模式需要主板和芯片的特殊设置才能工作

傲腾(Optane)需要:

- Intel第七代CPU支持，也就是 ``Kaby Lake`` 处理器(2016年9月推出，14nm工艺)
- 主板芯片 Intel 200系列

.. note::

   目前我没有设备可以支持测试Intel Optane，可能会考虑购买一个 ``标准NVMe-PCIe SSD`` 来加速Ceph。根据 :ref:`hpe_dl360_gen9` 资料，DL360 Gen9 支持 :ref:`nvdimm_ram` (持久化内存)，速度和DRAM相当，但是容量较小；不过，确定不能在内存插槽安装Optane，所以无法适配。

   NVDIMM-N 对比 Optane DC DIMM 可参考 `Persistent Memory NVDIMM-N and Optane DC DIMM <https://www.smartm.com/api/download/fetch/61#:~:text=The%20NVDIMM%20has%2010x%20lower,DRAM%20memory%20module%2Dsized%20capacity.>`_

应用场景
=============

- Ceph 读写密集且性能关键的元数据存储(RocksDB)
- RocksDB内存型存储
- ClickHouse LDAP数据库
- 混合存储(加速机械硬盘作为大容量存储)，例如，部署 :ref:`gluster` 大容量存储，兼具机械硬盘大容量和SSD高速特性

参考
=========

- `英特尔 傲腾内存快速入门指南 <https://www.intel.cn/content/www/cn/zh/support/articles/000025009/memory-and-storage/intel-optane-memory.html>`_
- `Intel持久内存技术资料 <https://www.intel.cn/content/www/cn/zh/developer/topic-technology/persistent-memory/overview.html>`_
- `Provision Intel Optane DC Persistent Memory in Linux <https://www.intel.cn/content/www/cn/zh/developer/videos/provisioning-optane-dc-persistent-memory-modules-in-linux.html>`_ 视频
- `英特尔 Optane：用于数据中心内存缓存 <https://linux.cn/article-13109-1.html>`_
