.. _freebsd_zfs_stripe:

====================================
ZFS Stripe条带化 (FreeBSD环境实践)
====================================

.. warning::

   这里我将 ``Stripe`` 模式定义为 ``RAIDZ-0`` 不是ZFS的准确定义，ZFS RAIDZ 只有:

   - ``raidz1`` / ``raidz`` :  相当于 ``RAID5`` ，允许一块磁盘损坏而数据不丢失
   - ``raidz2`` : 相当于 ``RAID6`` , 使用2个校验raidz组，允许2块磁盘损坏而数据不丢失
   - ``raidz3`` : 使用3个校验raidz组，则允许3块磁盘损坏而数据不丢失

   如果没有指定 ``raidz`` 或者 ``mirror`` ( ``RAID1`` )，那么默认就是Stripe条带化，数据会均匀分布到所有磁盘，获得最大的性能和容量，但是没有任何数据安全。我把这个模式称为 ``RAIDZ-0`` 是借用了传统的 ``RAID0`` 概念，实际上并不准确。

   意思就是这样，暂时就不修订了，先这样...

准备工作
==========

实践环境是在我自己组装的一台 :ref:`nasse_c246` 配备了 ``4块`` :ref:`kioxia_exceria_g2` :ref:`nvme` 存储。已经在 :ref:`gpart` 实践中完成磁盘分区准备，完整分区通过 ``gpart show`` 可以看到如下:

.. literalinclude:: ../../../../freebsd/storage/gpart/show_all
   :caption: 显示完成后的所有分区
   :emphasize-lines: 24,30,36,42

现在将使用上述 ``4块`` :ref:`nvme` 存储的 ``分区2`` 组建一个 ``RAIDZ0`` 模式条带化存储，以实现存储容量最大化和最高IO性能，但不保证存储数据安全。这是因为我将存储作为实验环境，没有数据安全要求，如果你是生产环境， **不可使用** 这种模式，必须使用 ``RAIDZ5`` 或 ``RAIDZ1`` 这样的数据冗余安全模式。

.. warning::

   再次警告⚠️

   我这里构建的是 ``RAID-0`` 模式，是为了追求实验环境容量最大化， ``生产环境不可使用!!!``

   生产环境请使用 ``RAIDZ-5``

.. note::

   对于使用 ``stripe`` 模式的ZFS zpool，依然可以设置文件副本数量，例如 ``zfs set copies=3 zdata/home`` 单独设置该存储池中卷集，但是有以下限制:

   - 不能保证副本被完全分配到独立的磁盘
   - 只能防范分区失效导致的异常，如果磁盘级别故障会导致某个 ``top-level vdevs`` 丢失，则即使数据存在ZFS也会拒绝导入

Stripe (RAID-0)
=================

当 ``zpool create`` 时没有指定 ``zpool`` 的类型时，对于多个磁盘会自动采用 ``Stripe`` 条带化模式，也就是将数据分片存放到多个磁盘上，但是不提供任何数据冗余存储，相当于 ``RAID-0``

.. literalinclude:: freebsd_zfs_stripe/zpool_create_zdata
   :caption: 创建条带化(Stripe)类型的Zpool

说明:

- ``-f`` 参数是因为 :ref:`gpart` 划分分区时设置了磁盘分区类型为 ``freebsd-zfs`` ，看起来会自动添加默认已经存在的 ``zroot`` zpool，所以要使用 ``-f`` 参数覆盖强制

.. literalinclude:: freebsd_zfs_stripe/zpool_create_zdata_error
   :caption: 创建zpool报错

- ``-o ashift=12`` 的 ``ashift`` 属性设置为 **12** ，以对应 ``4KiB`` (4096字节)块大小。通常对于HDD和SSD，能够获得较好的性能和兼容性。底层是 ``512字节`` 一个扇区，所以 ``2^12=4096`` 就能够对齐和整块读写磁盘。如果没有指定这个 ``ashift`` 参数，ZFS会自动检测 ``ashift`` ，如果检测失败就会默认使用 ``ashift=9`` ，这会导致性能损失。这个 ``ashift`` 参数一旦设置，不能修改

- 这里使用了 ``diskid`` 来标记磁盘，以避免搞错磁盘

检查
=======

- 检查 ``zpool`` :

.. literalinclude:: freebsd_zfs_stripe/zpool_list
   :caption: 检查zpool磁盘情况

可以看到 ``zdata`` zpool由 ``4个`` 磁盘分区组成

.. literalinclude:: freebsd_zfs_stripe/zpool_list_output
   :caption: 检查zpool磁盘情况
   :emphasize-lines: 3-6

.. _freebsd_zfs_stripe_single_disk:

FreeBSD ZFS单块磁盘stripe
============================

在 :ref:`gpart_linux_zfs_partition` 构建FreeBSD和Linux共存的分区，使用了单块磁盘，其中分区5用于构建单块磁盘(分区)的 ``zdata`` zpool，以下是 ``gpart show nda0`` 输出:

.. literalinclude:: ../../../../freebsd/storage/gpart_linux_zfs_partition/gpart_show_output_all
   :caption: 使用 ``gpart`` 检查，其中第5个分区用于构建 ``zdata`` zpool
   :emphasize-lines: 7

- 创建 ``zdata`` zpool (单块磁盘构建的ZFS zpool实际上就是 ``stripe`` 模式，和上文相同):

.. literalinclude:: freebsd_zfs_stripe/zpool_zdata
   :caption: 创建 ``zdata`` zpool

- 检查 ``zpool list -v`` 输出:

.. literalinclude:: freebsd_zfs_stripe/zpool_list_zdata_output
   :caption: ``zpool list -v`` 输出显示 ``zdata`` zpool 详情
   :emphasize-lines: 2,3

参考
======

- `OpenZFS Basic Concepts RAIDZ <https://openzfs.github.io/openzfs-docs/Basic%20Concepts/RAIDZ.html>`_
- `RAID-Z Storage Pool Configuration <https://docs.oracle.com/en/operating-systems/solaris/oracle-solaris/11.4/manage-zfs/raid-z-storage-pool-configuration.html>`_ Oracle Solaris 11.4手册，提供了ZFS相关参考

  - `Creating a RAID-Z Storage Pool <https://docs.oracle.com/en/operating-systems/solaris/oracle-solaris/11.4/manage-zfs/creating-a-raid-z-storage-pool.html>`_
  - `When to (and Not to) Use RAID-Z <https://blogs.oracle.com/solaris/post/when-to-and-not-to-use-raid-z>`_
  - `Oracle Solaris 11.4 Tunable Parameters Reference Manual <https://docs.oracle.com/en/operating-systems/solaris/oracle-solaris/11.4/tuning/oracle-solaris-11.4-tunable-parameters-reference-manual.pdf>`_ 有关于ZFS RAIDZ调优

- `RAIDZ types reference <https://www.raidz-calculator.com/raidz-types-reference.aspx>`_
- `Choosing the Right ZFS Pool Layout <https://klarasystems.com/articles/choosing-the-right-zfs-pool-layout/>`_
- `proxmox: ZFS on Linux <https://pve.proxmox.com/wiki/ZFS_on_Linux>`_
