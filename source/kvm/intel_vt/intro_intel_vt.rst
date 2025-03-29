.. _intel_vt_infra:

===========================================
Intel VT(Virtualizaition Technology)架构
===========================================

虚拟化的优势
==============

虚拟化为现代化硬件提供了一种(软件化)抽象能力:

- 多个工作负载共享一组公共的硬件
- 不同(资源需求)的工作负载可以混布，同时保持彼此完全隔离
- 工作负载可以跨基础架构自由迁移并按需扩展

企业通过虚拟化获得显著的资本和运营效率:

- 提高服务器利用率
- 整合、动态资源分配和管理
- 工作负载隔离
- 安全性
- 自动化

**虚拟化使得服务的按需自配置和资源的软件定义编排成为可能**

Intel虚拟化技术
==================

Intel虚拟化技术(Virtualization Technology,VT)技术采用支持Intel虚拟化技术组件的处理器，使得多个操作系统和应用程序运行在独立分区(independent partitions)。每个分区的行为都像一个虚拟机并且提供隔离和跨分区保护。这种基于硬件的虚拟化解决方案以及虚拟化软件支持多种用途，如:

- 服务器整合(server consolidation)
- 活动分区(activity partitioning)
- 工作负载隔离(workload isolation)
- 嵌入式管理(embedded management)
- 遗留软件迁移(legacy software migration)
- 灾难恢复(disaster recovery)

Intel虚拟化技术堆栈
---------------------

Intel虚拟化技术包含了以下硬件和软件组合:

- CPU虚拟化: 将Intel CPU的全部功能抽象为虚拟机(VM)，使得VM中所有软件可以在没有任何性能或兼容性影响的情况下运行，就好像软件是在专有的CPU上本地运行。这样就能够非常方便地从上一代Intel处理器实时迁移到下一代Intel处理器，并且能够实现 :ref:`kvm_nested_virtual`
- 内存虚拟化: 内存虚拟化使得每个虚拟机(VM)可以实现抽象隔离和监控内存，这样就能实现VM的 :ref:`kvm_live_migration` ，增加容错能力并增强安全性

  - 直接内存访问(DMA)重映射(DMA remapping)
  - :ref:`intel_ept` 

- I/O虚拟化: I/O虚拟化是在网络层面和存储层面实现：多核数据包处理卸载到网络适配器 ，磁盘I/O直接虚拟化分配给虚拟机:

  - Intel Virtual Technology for Directed I/O(Intel VT-d)技术，也就是 :ref:`iommu` 技术(intel和AMD各自有自己的实现)
  - :ref:`sr-iov`
  - :ref:`intel_ddio`

- :ref:`intel_gvt` : 提供虚拟机完全和共享图形处理单元(GPU)以及集成在Intel片上系统产品中的视频转码加速期引擎

- 安全和网络虚拟化: 将传统网络和安全工作负载转为计算

  - Intel QuickAssist Technology(Intel QAT)
  - :ref:`dpdk`


参考
======

- `Intel® Virtualization Technology (Intel® VT) <https://www.intel.com/content/www/us/en/virtualization/virtualization-technology/intel-virtualization-technology.html>`_
- `Intel Virtualization Technology for Directed I/O <https://www.intel.com/content/dam/develop/external/us/en/documents/vt-directed-io-spec.pdf>`_
