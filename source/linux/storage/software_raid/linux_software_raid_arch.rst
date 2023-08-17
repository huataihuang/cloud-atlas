.. _linux_software_raid_arch:

=======================
Linux软RAID架构
=======================

RAID概述
==========

RAID技术可以将多个存储设备(HDD, SDD 或 :ref:`nvme` )组合成一个阵列来提供性能提升和冗余增加，对于操作系统，这个RAID设备是一个单一存储单元(驱动器)。RAID技术为计算机提供了冗余(RAID1,4,5,6)以及较低延迟、增大带宽以及最大程度从硬盘崩溃中恢复的能力。

RAID配置:

- RAID0: 条代化
- RAID1: 镜像
- RAID4,5,6: 带有奇偶校验的磁盘条代化

RAID类型
-------------

- 固件RAID: 也称为ATARAID，是一种软件RAID，使用基于固件的菜单配置RAID，此类RAID使用的固件会挂载到BIOS，允许从RAID集启动。(这种RAID我没有接触过，可以参考 `Set Up a System with Intel® Matrix RAID Technology <https://www.intel.com/content/www/us/en/support/articles/000005789/technologies.html>`_ )
- 硬件RAID: 基于硬件的RAID是独立于主机管理的RAID子系统

  - 内部设备通常是专用控制器卡，处理对操作系统透明的RAID任务
  - 外部设备通常通过SCSI, 光纤, iSCSI, InfiniBand其他高速网络连接的系统，并显示卷(逻辑单元)给系统

- 软件RAID: 在内核块设备代码中实现的RAID级别，不需要昂贵的磁盘控制器，可以采用任何Linux内核支持的块设备组建软件RAID，例如SATA, SCSI 或 :ref:`nvme` 存储设备。随着CPU性能越来越快，除了高端存储设备，软件RAID通常优于硬件RAID。

Linux 软件 RAID 堆栈的主要功能:

- 多线程设计
- 在不同的 Linux 机器间移动磁盘阵列不需要重新构建数据
- 使用空闲系统资源进行后台阵列重构
- 支持热插拔驱动器
- 自动 CPU 检测以利用某些 CPU 功能，如流传输单一指令多个数据 (Single Instruction Multiple Data, SIMD) 支持
- 自动更正阵列磁盘中的错误扇区
- 定期检查 RAID 数据，以确保阵列的健康状态
- 主动监控阵列，在发生重要事件时将电子邮件报警发送到指定的电子邮件地址
- ``Write-intent bitmaps`` 允许内核准确了解磁盘的哪些部分需要重新同步，而不必在系统崩溃后重新同步整个阵列，可以大大提高了重新同步事件的速度
- 重新同步检查点: 重新同步期间重新启动计算机，则在启动时重新同步会从其停止的地方开始，而不是从头开始
- 安装后更改阵列参数的功能，称为重塑（reshaping）: 举例，当有新设备需要添加时，可以将 4 磁盘 RAID5 阵列增加成 5 磁盘 RAID5 阵列。这种增加操作是实时的，不需要重新安装
- 重塑支持更改设备数量、RAID 算法或 RAID 阵列类型的大小，如 RAID4、RAID5、RAID6 或 RAID10
- 接管支持 RAID 级别转换，比如 RAID0 到 RAID6
- 集群 MD(Cluster MD) 是集群的存储解决方案，可为集群提供 RAID1 镜像的冗余(怎么实践？)

RAID级别和线性支持
-------------------

- RAID0: 条带化的数据映射技术，即写入阵列的数据被分成条块，分散到成员磁盘写入。这样可以低成本提高存储I/O性能， **但是没有冗余(数据安全)** 。注意，RAID0只能实现成员设备中最小设备(容量)的条带分布，也就是说如果组成RAID0的各个磁盘容量不一致，则以最小容量的磁盘来构成RAID0(磁盘空间较大的部分会被忽略)。这种组建磁盘容量大小不一的情况，建议使用磁盘分区组建RAID0

- RAID1: 镜像（mirroring）技术，通过将相同数据写入阵列的每个磁盘来提供冗余。这是一种简单且数据高度可用的RAID技术，被广泛使用。提供了很好的数据可靠性，并且提高了读取性能，但成本较高(利用率低)

- RAID4: 使用单一磁盘驱动器中的奇偶校验来保护数据: 需要注意RAID4使用了专用奇偶校验磁盘，所以该磁盘可能是RAID阵列的瓶颈(在没有回写缓存技术时很少采用RAID4); RAID4的读性能好于写性能(写时需要计算校验且写校验盘，而读时候只访问数据盘)

- RAID5: 最常见的RAID类型，在阵列的所有成员磁盘中分布奇偶校验，所以消除了RAID4的校验盘写入瓶颈，但是奇偶校验计算依然是沉重的负担。不过好在现代CPU性能强劲能够很好满足计算校验，需要考虑的是大量磁盘可能造成校验计算负担加重

- RAID6: RAID6采用了复杂的奇偶校验，能够允许出现2块磁盘故障，所以带来更好的数据冗余和保护性，缺点是对CPU造成较大负担，而且写入性能下降(性能不对称性比RAID4/5更严重)

- RAID10: 结合了RAID0的性能优势和RAID1的冗余，没有RAID5/6这样奇偶校验计算的CPU消耗。空间利用率好于RAID1但不如RAID5/6

- 线性RAID: 没有条带化，数据顺序填充磁盘，只有上一个磁盘完全写满才会进入下一个磁盘写入，这种方法没哟性能优势，也不提供冗余，所以通常不建议使用

Linux RAID子系统
==================

``mdraid`` 子系统是Linux软件RAID解决方案，该子系统使用自己的元数据格式，称为原生MD元数据。此外还支持外部元数据(RHEL9支持外部元数据 ``mdraid`` 来访问 Intel Rapid Storage (ISW) 或 Intel Matrix Storage Manager (IMSM) 设置和存储网络行业关联 (SNIA) 磁盘驱动器格式 (DDF))。

RAID思考
==========

``RAID`` 是一个非常古老的存储技术: 根据 `Wikipedia: RAID <https://en.wikipedia.org/wiki/RAID>`_ 介绍，早在上个世纪1970年代(距今已经有半个世纪多)，已经发明了RAID 1；到1986年，发明了 RAID 5；到1988年，RAID的各个级别已经明确定义。

这项古老的技术对于早期需要大容量存储以及高可用、高性能的数据中心有着非凡的意义，记得我年轻的时候，提到服务器，必然会想到RAID存储。可以说RAID存储就是服务器的必然组成。

不过，虽然RAID能够提供极佳的性能和可靠性，但是随着数据中心规模发展以及数据爆炸式增长，RAID技术也存在一定的局限以及需要不断优化调整，以结合其他计算机技术来实现技术的"重新焕发青春":

- RAID的创建和重建是非常耗时的过程，特别是现代存储动辄上T容量: 在古老的计算机历史中有一段时间，SSD技术还在襁褓，而机械磁盘突破到数百GB的时候，大规模RAID重建曾经是运维的噩梦。因为RAID重建实在太慢了，甚至还没等重建完成新的磁盘又出现故障。不过， SSD技术快速迭代发展，特别是 :ref:`nvme` 横空出世带来存储技术的飞跃，这个RAID重建的速度已经不再是瓶颈。RAID技术再次获得青睐，可以为服务器存储本地提供超大规格的存储空间。
- 强健的大规模分布式存储实际上不再依赖本地磁盘的冗余，也就是说，类似 :ref:`ceph` 自身能够检测数据分布，不依赖于RAID就能够实现数据的分布式多副本，省却了本地构建RAID的技术复杂性(但是， :ref:`ceph` 实在是更复杂了)。然而，并不是所有的分布式存储都像 :ref:`ceph` 那样全面，由于设计上的轻量级和简化，类似 :ref:`gluster` 分布式存储是不感知本机多磁盘数据分布的。也就是说，对于GlusterFS，只认本地一个 ``brick``
  为好，以强制数据副本分布到不同服务器上。这就为重新引入RAID带来的契机。还有历史悠久并且依然在HPC领域广泛使用的 `Lustre_(file_system) <https://en.wikipedia.org/wiki/Lustre_(file_system)>`_ ，后端存储也是建立在RAID之上(现代已经趋向采用 :ref:`zfs` 后端)

总之，在 :ref:`nvme` 硬件技术加持下，RAID技术重获青春，可以为本地存储提供海量空间，也为分布式存储提供了稳健的后端。( :ref:`zfs` 也是类似的技术 )
 

参考
======

- `Red Hat Enterprise Linux 9 Docs > Managing storage devices > Chapter 18. Managing RAID <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/managing_storage_devices/managing-raid_managing-storage-devices>`_ 
- `Red Hat Enterprise Linux 9 Docs > 管理存储设备 > 第18章 管理RAID <https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/9/html/managing_storage_devices/managing-raid_managing-storage-devices>`_ (中文版)
- `archlinux: RAID <https://wiki.archlinux.org/title/RAID>`_ :ref:`arch_linux` 的文档总是那么完善全面，推荐阅读
