.. _hpe_dl360_gen9:

================================
HPE ProLiant DL360 Gen9服务器
================================

DL360服务器外观
=================

前面板
----------

HPE ProLiant DL360 Gen9服务器是通用型1U机架式服务器，提供了不错的计算能力和高密度存储(目前SSD存储技术已经向微型化发展，所以即使1U服务也能提供非常高的存储容量)。

.. figure:: ../../../../_static/linux/server/hardware/hpe/hpe_dl360_gen9_front.png
   :scale: 60

标准配置是采用 8 个SFF，也可以订购不同 :ref:`storage_spec` 组合，其中比较有特色的是:

- 4 SAS/SATA (Drive 1-4)+6 NVMe (Drive 5-10)

我觉得可以配置成:

- Drive 1-2 采用常规SAS SSD组成RAID1，构建操作系统，确保本机服务器始终可用
- Drive 3-4 采用大容量 HDD ，构建基于 :ref:`gluster` 的镜像近线存储，提供NAS文件存储功能
- Drive 5-10 采用 NVMe SSD，通过虚拟化构建 :ref:`ceph` 存储集群，提供整个虚拟化 :ref:`openstack` 分布式存储，实现云计算底层存储

不过服务器的部件价格是家用计算机部件的2倍价格，例如同样1T容量的NVMe家用型只需要600元，但是U.2接口的NVMe SFF存储(2.5" NVMe SSD)则售价在1200~1800元，对于组件模拟分布式存储，还是推荐采用家用NVMe设备(转接卡+M.2 NVMe)。详细实践待后续...

后面版
---------

.. figure:: ../../../../_static/linux/server/hardware/hpe/hpe_dl360_gen9_front.png
   :scale: 60

值得关注点:

- 板载集成4端口千兆网卡，可以组建network bonding实现高速网络交换，或者可以尝试实践一个以Linux为基础的高速交换网络，学习SDN技术
- 可选的FlexibleLOM bay可以安装附加的4口网卡，扩展性更强的交换网络
- 电源可能需要购买高功率，因为如果使用高性能CPU没有大功率电源支持会导致不稳定 - 具体待查询资料和实践

内部
--------

.. figure:: ../../../../_static/linux/server/hardware/hpe/hpe_dl360_gen9_inside.png
   :scale: 60

重点:

- 主板内部提供了Micro-SD卡接口，功能待查
- 支持2种存储卡: HPE Flexible Smart Array 和 Smart HBA，型号是 H240ar 和 P440ar
- PCIe 规格是 3.0，需要注意插槽1和2和处理器1关联，插槽3和处理器2关联
- 提供了2个主板SATA控制器插口

配置
========

HPE ProLiant DL360 Gen9 服务器综合配置介于 :ref:`dell_r630` 和 :ref:`dell_r640` 之间:

- 主板芯片和 :ref:`dell_r630` 相同，采用 :ref:`intel_c610` 系列
- CPU支持和 :ref:`dell_r630` 相同，支持 :ref:`xeon_e5-2600_v3` 和 :ref:`xeon_e5-2600_v4` ，这款服务器支持的CPU型号较多(比DL160):

.. csv-table:: HPE ProLiant DL360 Gen9 支持E5-2600 v3/v4处理器
   :file: hpe_dl360_gen9/hpe_dl360_gen9_cpu.csv
   :widths: 25, 15, 10, 10, 10, 15, 15
   :header-rows: 1

- 内存支持和 :ref:`dell_r640` 类似，同时支持不同类型(超越了Dell R630)

  - :ref:`lrdimm_ram` 3TB (24 x 128GB LRDIMM @ 2400 MHz)
  - :ref:`rdimm_ram` 768GB (24 x 32GB RDIMM @ 2133 MHz)
  - :ref:`nvdimm_ram` 128GB (16 x 8GB NVDIMM)
  
.. note::

   不过从淘宝可以看到 LRDIMM 内存目前非常昂贵，不如 RDIMM内存 性价比高。不过，技术发展迅速，或许未来也可能进入二手市场的高性价比范围。

存储
========

DL360服务器内置驱动器分为8盘位和10盘位两种，有以下集中配置规格:

存储控制器
-------------

主板内置存储控制芯片: HPE Dynamic Smart Array B140i控制器 (对于E5-2600v3 CPU处理器，主板集成的B140i只能工作在UEFI模式)。默认B140i设置为AHCI模式，如果要使用SATA only模式则需要配置激活。

支持2种阵列卡：

- H240ar 阵列卡，适合少量硬盘，只支持RAID 0和1模式，硬盘也可以设置为无阵列模式
- H440ar 阵列卡，配置2G缓存和电池，支持多硬盘RAID 5,6,10,50,60等模式，硬盘也可以设置为无阵列模式

HP官方支持网站提供了部件安装视频指南，例如 `HP Smpart Array Controller <https://support.hpe.com/hpesc/public/docDisplay?docId=psg000107aen_us&page=GUID-F16DC03B-D44C-4C4C-B314-BD207D305DF1.html>`_ 介绍了如何替换阵列卡。其他组件的安装替换也有相应指导，非常方便

内置硬盘配置组合:

- Hot Plug SFF NVMe PCIe + SSD : 可以组合 6个NVMe + 4个SSD 不过由于存储是服务器最大的投资部分，可以采用渐进升级方法

电源支持
=========

- 500W标配
- 800W
- 1400W
- 750W +

UEFI
========

Unified Extensible Firmware Interface (UEFI)是服务器启动管理，HP提供了 `HPE UEFI支持 <http://www.hpe.com/servers/uefi>`_ :

- 结合UFEI安全启动(通过内建可信任密钥签名)，并且HPE ProLiant Gen10服务器还支持Trusted Platform Module(TPM)
- 嵌入的UEFI Sheel 和 `iLo RESTful API <https://www.hpe.com/us/en/servers/restful-api.html>`_ ，可以管理UEFI以及BIOS
- UEFI支持PXE从IPv6网络启动，这样可以通过网络快速部署大量服务器

我的服务器组合
=================

- HPE ProLiant DL360 Gen9 Server
- :ref:`xeon_e5-2670_v3`
- 三星 32G DDR4 2R*4 2400MHz 内存 (实际上v3只支持2133MHz，考虑到后续可能升级v4处理器支持2400MHz)

  - DL360支持每个DIMM插槽最高32GB RDIMM内存，满配24根最高768GB。为了不浪费插槽和内存，选择2根32G

- 硬盘暂时采用原先的购买的笔记本2.5" SSD SATA硬盘，后续再做升级到 U.2 接口NVMe SSD

参考
=======

- `HPE ProLiant DL360 Gen9 Server <https://support.hpe.com/connect/s/product?language=en_US&ismnp=0&l5oid=7252836&kmpmoid=7252838&cep=on#t=All>`_
- `HPE ProLiant DL360 Gen9 Server QuickSpecs <https://support.hpe.com/hpesc/public/docDisplay?docLocale=en_US&docId=c04346229>`_
