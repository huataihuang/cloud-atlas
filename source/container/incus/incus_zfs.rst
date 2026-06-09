.. _incus_zfs:

=====================
Incus使用ZFS作为存储
=====================

在 :ref:`incus_startup` 实践中，可以看到 ``incus admin init`` 交互过程会让你选择存储引擎，实际上这个存储引擎和 :re:`docker_storage` 是相似的，能够支持 :ref:`zfs` :ref:`linux_lvm` :ref:`btrfs` 等不同的卷管理系统，以实现快照，clone的等高级功能。当然，最简单的形式还是 ``dir`` 即目录存储。

由于我最初规划在 :ref:`nasse_c246` 组装机上采用它多块 :ref:`nvme` 存储，所以操作系统安装 :ref:`ubuntu_linux` 的时候，将操作系统Installer的默认卷管理中 ``/`` 目录的卷 ``ubuntu-lv`` 扩展到占用了整块磁盘。后来的规划有变，我采用了 3块 :ref:`tesla_a2` ( :ref:`pcie_bifurcation` ) + 1块 :ref:`tesla_p10` ( ``OCuLink`` )来构建 :ref:`think_machine` ，这就导致主机上只剩下一块操作系统使用的 :ref:`kioxia_exceria_g2` 。

那么问题来了，我该怎样将已经完全被 :ref:`linux_lvm` 占据磁盘的空间划分出一部分来提供给 :ref:`zfs` ，以实现最完美的容器本地化存储？

- 检查当前存储(pv,vg和lv使用情况)

.. literalinclude:: incus_zfs/pvs_vgs_lvs
   :caption: 检查pv,vg和lv的使用情况
   :emphasize-lines: 3,6,9

可以看到，当前PV使用了 ``/dev/nvme0n1`` 的分区3，并且VG已经将所有的PV空间都使用完了( ``VFree=0`` )，而且LV也已经将分配的VG空间分配完。

.. note::

   Incus支持使用 :ref:`incus_lvm`

这说明，当前 :ref:`linux_lvm` 实际上是完全使用了磁盘空间(分区3)，那么该如何腾出部分空构建给ZFS:

思路一: 收缩 PV
=================

.. warning::

   虽然操作分区表（如使用 fdisk 或 parted）收缩 LVM 所在的主分区在 Linux 下可以通过计算扇区（Sector）来实现，但是实践上存在极大风险:

   - 物理卷（PV）收缩的“碎片化”陷阱: **释放出来的 PE 并不一定整齐地排列在物理磁盘的末尾**

   长时间运行的系统，PE的分配可能是离散的(比如磁盘头部有数据，中部是空闲，尾部又有数据)。如果直接去截断物理分区，只要磁盘末尾还残留有一个被占用的 PE，就会导致分区表损坏、数据毁灭性丢失。

   解决的方法可以尝试: ``pvmove --alloc anywhere`` 把散落在磁盘尾部的 PE 一个个手动搬运到磁盘头部。(需要使用 ``pvdisplay -m`` 查看PE的物理分布)这个过程极其耗时且容错率极低。只有这步成功之后才能执行 ``pvresize``

   - 不推荐ZFS和LVM共享一块物理磁盘的不同分区: ZFS拥有自己的虚拟设备（vdev）调度层、极其激进的写入缓存以及对底层硬件拓扑的预判。

- 步骤概述:

.. literalinclude:: incus_zfs/pvresize
   :caption: 收缩PV的思路

我的实际实践: ZFS运行在独立逻辑卷(LV)上
=========================================

LVM是一个非常高效、极其轻量化的设备映射器(Device Mapper)抽象层。在Linux内核中，LVM的逻辑卷(LV)到物理卷(PV)的映射主要是通过扇区偏移量(Sector Offset)的查表映射来完成的。这种内核级别的地址换算，其CPU周期消耗和I/O延迟在现代硬件(尤其是NVMe SSD)上几乎完全可以忽略不计(通常小于1%)。

传统的文件系统上创建Loopback文件，然后把文件挂载给ZFS系统。这种模式虽然简单易用，但是会导致双重日志在(Double Journaling)，双重缓存(Double Caching)以及严重的数据块对齐(Alignment)消耗。所以注重性能场合不适用。

但是直接使用裸LV上构建ZFS则能够保持高性能:

- **零文件系统开销（Zero Filesystem Overhead）** : LV 没有经过 EXT4 或 XFS 的格式化，它对于宿主机内核来说，就是一个纯净的、连续的物理块设备（Block Device），地位和 ``/dev/sda`` 或 ``/dev/nvme0n1p2`` 完全对等。ZFS 可以直接接管这块设备的底层 I/O 队列。
- **单一缓存机制（Single Cache Strategy）** : ZFS 拥有自己极其强大的内存缓存机制——ARC（Adaptive Replacement Cache，自适应替换缓存）。由于底层是裸 LV，数据会直接从 ZFS 写入底层硬件，宿主机的 Page Cache（系统缓存）不会对这部分数据进行二次缓存。这避免了内存的白白浪费和双重缓存同步带来的延迟。
- **完美继承 ZFS 的高级特性** : 在 LV 之上建立 ZFS 后，Incus 在创建、克隆和快照 Debian 容器时，完全是在 ZFS 内部通过修改指针实现的写时复制（CoW）。LVM 只充当空间提供者，不会干扰 ZFS 的快照性能。

.. note::

   虽然 LVM 层几乎没有消耗，但是如果没有做到 **扇区对齐（Sector Alignment）** 会导致性能急剧下降，所以务必确认:

   - **确保 LVM 的 PE（Physical Extent）对齐** : LVM 在创建 VG 时，默认的 PE 大小是 4MB，并且会自动对齐到 1MB 边界。这天然就是 4KB 的倍数，所以 LVM 是完美对齐的。

   - **创建 ZFS 存储池时强行指定 ``ashift=12`` （最关键）** : ashift=12 代表 $2^{12} = 4096$ 字节（即 4KB）。这会强制 ZFS 内部所有的数据块（Block）按照 4KB 边界进行严格对齐写入。

- 首先将当前LVM中的 ``LV`` 收缩:

.. literalinclude:: incus_zfs/shrink_lv
   :caption: 收缩LV，注意使用了 ``--resizefs`` 参数能够同时收缩LV上的文件系统(ext4,xfs)

传统Linux运维中，缩减一个 ``ext4`` 分区或逻辑卷，标准流程必须是 "先使用 ``resize2fs`` 缩小文件系统，然后再用 ``lvreduce`` 缩小逻辑卷"。但是，现代Linux(例如Ubuntu 24.04)所带的 ``lvm2`` 工具链已经非常只能。当执行 ``lvreduce`` 时加上 ``--resizefs`` 参数， **LVM会在后台自动、原子化地按顺序执行完整的先收缩文件系统再收缩LV的流程** :

自动检测: LVM会自动检测 ``/dev/ubuntu-vg/ubuntu-lv`` 上承载的是什么文件系统(例如识别出 ``ext4`` )

第一步(隐藏调用 ``resize2fs`` ): LVM会在后台先自动调用 ``resize2fs`` (如果是挂载状态且内核支持，则会在线缩减；如果需要卸载，则会提示):

.. literalinclude:: incus_zfs/shrink_lv_umount
   :caption: 对于需要卸载的根目录收缩文件系统会提示
   :emphasize-lines: 3

二步（执行 ``lvreduce`` ）： 只有当后台的 ``resize2fs`` 成功完成、文件系统已经安全收缩之后，LVM 才会真正去调整逻辑卷（LV）的边界，切掉尾部的空间。

.. note::

   由于我这里是调整 ``/`` 根目录的LVM，所以需要使用Ubuntu Live CD/USB 启动盘 引导系统，或者进入 Recovery Mode（恢复模式）的 root shell。在根目录没有被挂载（Unmounted）的状态下，完成 :ref:`shrink_lv_root_in_recovery_mode`

- 现在执行 ``vgs`` 可以看到 ``ubuntu-vg`` 上有空闲的空间大约 ``1.4T`` 可以用于创建新的LV:

.. literalinclude:: incus_zfs/vfree
   :caption: 空闲空间大约1.4T
   :emphasize-lines: 2

- 创建LV命名为 ``incus-lv`` :

.. literalinclude:: incus_zfs/incus-lv
   :caption: 创建命令 ``incus-lv`` 的LV

注意，这里使用了参数 ``-l`` (小写)，该参数后面跟的是逻辑块(Extents)的数量或百分比表达式。当使用 ``-l 100%FREE`` 时，LVM会自动检查当前 ``ubuntu-vg`` 还剩多少可用的物理扩展单元(PE)，然后全部分配给这个新增的逻辑卷。

如果使用 ``-L`` (大写)参数，则后面更具体的容量单位数字（如 ``-L 60G`` , ``-L 500M`` )

现在检查 ``lvs`` 可以看到新创建的LV:

.. literalinclude:: incus_zfs/lvs
   :caption: 检查新创建的LV
   :emphasize-lines: 2

- **现在正式开始** 在LVM逻辑卷 ``/dev/ubuntu-vg/incus-lv`` 上创建ZFS的zpool:

.. literalinclude:: incus_zfs/zpool
   :caption: 创建用于incus的ZFS的存储池 ``incus-zpool``- 

注意参数要点:

- ``-o ashift=12`` : 强行将 ZFS 的物理块对齐到 4KB，消除因LVM虚拟块设备引起的扇区错位
- ``-O compression=lz4`` : 开启内建的 LZ4 压缩。LZ4 的速度极快，几乎不占用 CPU，但能节约20%~30% 的实际磁盘空间，且因为写入的数据变小了，反而能提升 SSD 的寿命和读写吞吐
- ``-O atime=off`` : 关闭文件访问时间记录。如果不关，容器里每次读取一个配置文件，ZFS 都要往盘里写入一次“访问时间”，这在大量微服务高频读取时会产生严重的 I/O 拖累

- 执行初始化操作:

.. literalinclude:: incus_zfs/incus_admin_init
   :caption: 初始化incus

注意，因为我已经创建了一个 ``incus-zpool`` 所以这里不要用默认的创建zpool，而是输入已经创建的zpool名

思路三: ZFS 支持的 Loopback 文件
==================================

另一个更为简单的方法是使用 ``dd`` 在文件系统中创建一个巨大的空文件，然后基于该文件创建ZFS池，这样这个zpool就能被Incus管理作为存储驱动:

.. literalinclude:: incus_zfs/dd_zpool
   :caption: 基于dd创建的文件来构建zpool

.. note::

   这个方法是Incus/LXD 官方文档在单机测试无多余盘时，最推荐的 ZFS 尝鲜方法
