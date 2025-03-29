.. _dl360_nvme_storage:

==================================================
HPE ProLiant DL360 Gen9服务器存储升级方案(构想)
==================================================

我的二手 :ref:`hpe_dl360_gen9` 已经使用了两年多，虽然二手早已过保，但是用于个人学习实践依然非常稳定可靠。不过，由于1U机架机型，存储扩展能力不足需要克服:

- X99服务器支持在PCIe 3.0插槽上通过 :ref:`pcie_bifurcation` 来转接 m2接口 :ref:`nvme` 或者 U2接口的nvme存储

  - 主板内置 :ref:`pcie_bifurcation` 有硬件限制(只能在Slot1上拆分成2个x8通道，也就是最多接两块 m2 接口)
  - 经过实测，通过 :ref:`plx_8747_pcie_bifurcation` 硬件卡可以在Slot1或Slot3上直接转接4块 m2 接口 nvme

- HP官方提供 ``HP DL360 Gen9 6 NVMe + 4 SAS/SATA Express Bay Enablement Kit  817676-B21`` 在ebay上售价高达800刀~1000刀，可以推测出也是一种 :ref:`pcie_bifurcation` 硬件卡转接U2；淘宝上有用于台式机的PCIe转U2接口的拆分卡，但是考虑到服务器使用可能有兼容性问题

构想方案
==========

.. note::

   目前我失业状态 ( :ref:`whats_past_is_prologue` )，经济紧张，并且2024年内存和固态存储再次达到价格高位，所以目前无法购买本方案的硬件进行实践。

   考虑到硬件终有便宜到白菜价的时候，或许在未来有机会入手进行升级:

   - :ref:`plx_8747_pcie_bifurcation` 硬件卡
   - :ref:`samsung_pm9a1` 4T规格 x4

   如果上述 **硬件组合总价** 能够降价到 1000~1500 RMB，我才会出手购买升级 (好遥远)

:ref:`hpe_dl360_gen9` 的PCIe插槽非常宝贵，只有3个，所以必须精打细算合理安排:

- PCIe Slot1，位于Primary (processor 1) PCI riser connector: 提供了GPU卡的外接电源(整个服务器只有Slot1提供了8pin扩展电源)，所以适合安装 :ref:`tesla_p10`
- PCIe Slot2，同样位于Primary (processor 1) PCI riser connector: 和Secondary PCI raiser相互影响，所以空间有限。可以安装单独的m2 NVMe存储，作为系统启动盘

  - 从 HP DL360 Gen9的BIOS配置中可以看到 ``Boot Order`` 中包含了 ``Slot 2: NVM Express Controller - S676... - SAMSUNG MZVL...`` 存储作为启动选项，这意味着如果将系统OS安装到位于Slot2的m2 NVMe存储，就能作为系统盘启动
  - 通过独立的m2 NVMe存储，可以实现高速性能的系统OS，对提升服务器性能会有很大帮助

- PCIe Slot3，位于 Secondary (processor 2) PCI raiser connector: 这个直连第二个CPU处理器的PCIe插槽，恰好适合安装 :ref:`plx_8747_pcie_bifurcation` 硬件卡

  - 同时安装4块4T的m2 NVMe存储(硬件 :ref:`pcie_bifurcation` 避免了服务器自身只能在Slot1拆分2个x8的限制)
  - 通过 :ref:`zfs` 构架服务器大容量RADZ存储，可以用户大规模 :ref:`kvm` 虚拟化模拟集群(高速NVMe存储确保了虚拟化存储性能，可以用来构建 :ref:`ceph` 集群存储)

- 服务器默认的SATA存储(前置热插拔)，共有8个存储插槽:

  - 如果HDD存储依然能够实现廉价的海量存储，例如4T控制到400元，那么非常适合构建离线存储
  - 存储不需要高速访问性能的冷文件存储，例如视频、软件等
