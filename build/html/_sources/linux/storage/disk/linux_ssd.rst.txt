.. _linux_ssd:

=======================
Linux固态驱动器(SSD)
=======================

.. note::

   固态硬盘带来了系统磁盘性能的极大提升，但是SSD的特性也带来了很多使用性能、寿命的挑战，需要仔细学习和实践。我将在 :ref:`hpe_dl360_gen9` 的NVMe设备中详细实践相关技术
   
   在 :ref:`optimize_ceph_arm` 结合SSD优化 :ref:`ceph` 性能，涉及到SSD的写入放大问题，将在本文实践中解析 

TRIM
=======

大多数SSD都支持 ``ATA_TRIM`` 指令来长时间性能和可用水平。 `TechSport - Benchmarks: TRIM & Full Drive Performance <https://www.techspot.com/review/737-ocz-vector-150-ssd/page9.html>`_ 提供了SSD磁盘在空白和填满数据时候的benchmark性能差异(性能相差10%~22%，通过TRIM可以几乎保持原有性能)。

从Linux内核 3.8开始，在不同的文件系统中不断加入支持TRIM，现在大多数文件系统都支持周期性TRIM和持续TRIM。

- 检查是否支持TRIM，使用以下命令::

   lsblk --discard

以下是在我安装了 SSD (sda) 和 HDD (sdb,sdc,sdd) 的主机上输出，可以注意到只有SSD磁盘有这个特性::

   NAME   DISC-ALN DISC-GRAN DISC-MAX DISC-ZERO
   sda           0      512B       2G         0
   ├─sda1        0      512B       2G         0
   └─sda2        0      512B       2G         0
   sdb           0        0B       0B         0
   └─sdb1        0        0B       0B         0
   sdc           0        0B       0B         0
   ├─sdc1        0        0B       0B         0
   └─sdc2        0        0B       0B         0
   sdd           0        0B       0B         0
   ├─sdd1        0        0B       0B         0
   └─sdd2        0        0B       0B         0

上述输出中 ``DISC-GRAN`` 表示 ``discard granularity`` (丢弃颗粒度) ( `究竟什么是颗粒度--granularity <https://zhuanlan.zhihu.com/p/65220106>`_ ) 和 ``DISC-MAX`` 表示 ``discard max bytes`` (丢弃最大字节) ，而 ``Non-zero`` 值表示 TRIM 支持

- 通过 ``hdparm`` 工具可以检查TRIM支持::

   hdparm -I /dev/sda | grep TRIM

输出显示::

          *    Data Set Management TRIM supported (limit 8 blocks)
          *    Deterministic read ZEROs after TRIM  TRIM之后确定性读0

.. note::

   `Wikipedia:Trim (computing)#ATA <https://en.wikipedia.org/wiki/Trim_(computing)#ATA>`_ 说明了 ``ATA IDENTIFY DEVICE`` 指令返回的不同类型TRIM定义:

   - Non-deterministic TRIM: 在一次TRIM之后执行读逻辑块地址(logical block address,LBA)可能每次返回不同数据
   - Deterministic TRIM (DRAT): 在一次TRIM之后所有读命令会返回一些数据就或者变成确定性
   - Deterministic Read Zero after TRIM (RZAT): 在一次TRIM之后所有读逻辑块地址(LBA)都返回0

周期性TRIM(Periodic TRIM)
============================

``util-linux`` 软件包提供了 ``fstrim.service`` 和 ``fstrim.timer`` 的 :ref:`systemd` 单元文件。激活这个 timer 将每周运行服务，这个服务会在所有激活 ``discard`` 选项的挂载文件系统上执行 ``fstrim`` 。这个timer依赖 ``/var/lib/systemd/timers/stamp-fstrim.timer`` 中的时间戳，以确定自从它最后一次运行时间是否已经一周，这样就不需要担心过滤频繁调用。

详细实践请参考 :ref:`fstrim`

持续TRIM
===========

.. note::

   如果已经周期性运行 ``fstrim`` 就不需要激活持续TRIM。也就是如果需要TRIM，请选择周期性TRIM或持续性TRIM。

所谓持续性TRIM是指每次文件删除时都分发TRIM命令。

.. warning::

   在SATA 3.1之前，所有TRIM命令都是非队列模式的( ``non-queued`` )，所以持续性TRIM会导致系统经常僵死。这种情况下，采用周期性TRIM(Perriodic TRIM)是更好的选择。在 `Linux内核源代码libata-core.c <https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/ata/libata-core.c>`_ 有一个 ``ata_device_blacklist`` 列出了存在问题的设备，由于会发生一系列数据损坏所以这些设备的 queued TRIM
   执行执行被加入黑名单。这种情况下，根据不同设备，系统可能会强制发送 non-queued TRIM 指令给SSD而不使用queued TRIM。

.. note::

   在Linux社区，通常不建议使用持续TRIM。例如，Ubuntu默认激活周期性TRIM，而Debian也不建议使用持续TRIM。Red Hat建议如果可能应该使用周期性TRIM，避免使用持续性TRIM

要激活设备的持续性TRIM，在 ``/etc/fstab`` 中加上 ``discard`` 选项::

   /dev/sda1  /           ext4  defaults,discard   0  1

.. note::

   对于XFS的 ``/`` 分区，指定 ``discard`` 挂载选项是无效的，必须要在内核参数加上 ``rootflags=discard``

此外，对于 ext4 文件系统，使用 ``tune2fs`` 命令可以设置默认挂载选项使用 ``discard`` 参数::

   tune2fs -o discard /dev/sdXY

上述方法特被适合那种移动外接设备，就不需要在 ``/etc/fstab`` 中配置参数。

TRIM整个设备(警告:数据丢失)
=============================

如果你要出售你的SSD磁盘，或者初次安装，想要一次性TRIM真个SSD设备，可以使用 ``blkdiscard`` 命令，这个命令会 ``完全抹去设备的所有块数据`` 

.. warning::

   使用 ``blkdiscard`` 将会丢失设备上所有数据!!!

::

   blkdiscard /dev/sdX

LVM
=======

TRIM请求是从文件系统直接穿透逻辑卷自动传递给物理卷的，所以不需要任何附加配置。
 
默认没有 LVM 操作 (lvremove,lvreduce以及所有其他)会影响TRIM请求发送给物理卷。使用 ``vgcfgrestore`` 可以恢复之前的卷组配置，在 ``/etc/lvm/lvm.conf`` 配置中的 ``issue_discards`` 会控制当逻辑卷不在使用物理卷的空间时，是否发送 discards 给一个逻辑卷底层的物理卷。

.. note::

   请仔细阅读 ``/etc/lvm/lvm.conf`` 注释，特别在修改 ``issue_discards`` 设置。这个设置不会影响TRIM请求从文件系统传输给磁盘(例如删除文件系统的文件)，也不会影响一个thin pool中空间管理。

.. warning::

   激活 ``issue_discards`` 会阻止使用 ``vgcfgrestore`` 恢复卷组的metadata，错误使用LVM命令会导致没有恢复的可能。

Maximizing performance
=======================

待续...

参考
======

- `arch linux wiki: Solid state drive <https://wiki.archlinux.org/title/Solid_state_drive>`_
- `Extend the life of your SSD drive with fstrim <https://opensource.com/article/20/2/trim-solid-state-storage-linux>`_
