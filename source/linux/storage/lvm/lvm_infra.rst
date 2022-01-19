.. _lvm_infra:

================
LVM架构
================

逻辑卷LVM
===========

LVM是基于Linux kernel的逻辑卷管理，通过将多个磁盘或类似的存储设备组合成大存储。LVM最初由Heinz Mauelshagen公司开发，基于HP-UX的LVM设计。多数Linux发行版本已经支持在逻辑卷上的根文件系统上安装一个启动系统。

通过使用逻辑卷(LVM)可已在物理存储上创建一个抽象层，比直接使用物理存储具有更大灵活性: LVM软件抽象层隐藏了底层硬件存储，使得调整文件系统大小以及移动，无需停止应用或卸载文件系统。

相比直接使用物理存储，逻辑卷具有以下优势:

- 灵活的容量: 使用逻辑卷时，文件系统可以跨多个物理磁盘或分区(物理卷, physical volumes, PV)，而且底层物理磁盘添加对上层文件系统无感知，可以实现不停机动态在线扩展
- 调整存储池大小: 可以扩展或减小逻辑卷，无需重新格式化或者重新分区基础磁盘设备
- 在线数据重定位( ``需要实践`` ): 可以在系统在线使用时移动数据，重新分配磁盘，清空热插拔磁盘(维护)，对运维硬件替换具有极大用途
- 方便的设备命名: 可以使用用户自己定义的设备命名
- 条带化: 通过条带化在多个磁盘(PV)上构建条带化分布数据的逻辑卷，可以显著提高吞吐量
- 镜像: 通过数据镜像提供硬件故障防范
- 快照: 设备快照可以用于数据备份以及测试更改对系统的影响
- 精简卷(Thin volumes): LVM的精简模式配置，可以创建大于实际硬件容量的逻辑卷
- 缓存卷(Cache volumes) :ref:`lvmcache` : 缓存逻辑卷使用更快的块设备(如SSD)组成小型逻辑卷，通过将热点数据存储在快速的缓存卷来提高较慢的大容量存储(如机械硬盘)的性能 

参考
=======

- `Logical Volume Manager (Linux) <http://en.wikipedia.org/wiki/Logical_Volume_Manager_(Linux)>`_
- `A Beginner's Guide To LVM <http://www.howtoforge.com/linux_lvm>`_
- `Red Hat Enterprise Linux 8.0 > 配置和管理逻辑卷 <https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/8/html/configuring_and_managing_logical_volumes>`_
