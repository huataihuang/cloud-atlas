.. _gpart:

==========
gpart
==========

我在2025年初组装了一台 :ref:`nasse_c246` ，内置了2个 :ref:`nvme` M.2接口。由于主板支持 :ref:`pcie_bifurcation` ，可以将主板上的PCIe 3.0 X16拆分成 ``X8X8`` 或 ``X4X4X8`` ，所以我最终购买了一个 :ref:`pcie_bifurcation_x4x4x8_card` 为主机构建了 ``4块`` :ref:`kioxia_exceria_g2` :ref:`nvme` 存储:

- 第一块nvme存储已经安装了最小化 :ref:`freebsd` ，我特意仅划分了较小的分区用于 ``zroot`` ZFS pool，这样磁盘后半部分空白分区可以后后续其他nvme磁盘的分区共同组件 ``RAIDZ`` ( ``zdata`` pool)
- 第 ``2-4`` 块nvme磁盘，每个磁盘划分为2个分区，第一个分区较小，和第一块nvme的系统分区大小相当，用于后续构建物理磁盘上的 :ref:`gluster` 冗余安全存储数据；后一个分区则为剩余磁盘空间，用于构建 ``RAIDZ`` ( ``zdata`` pool)
- 一共有 ``4`` 个较大的分区分布在 ``4`` 块nvme上，为了能够最大化使用空间，采用了 ``RAIDZ0`` 模式，这样能够获得最大空间和最高性能(生产环境不可采用这种无安全保障的RAIDZ，生产环境请使用 ``RAIDZ5`` )

.. note::

   由于我后续在 :ref:`nasse_c246` 组装机上将所有拆分PCIe 3.0 X16的3个PCIe接口都用于GPU设备，所以最终我修改方案，采用单块 :ref:`kioxia_exceria_g2` :ref:`nvme` 存储来构建FreeBSD存储: :ref:`gpart_linux_zfs_partition`

磁盘
======

- 列出主机上安装的磁盘，使用 ``geom`` (universal control utility for GEOM classes):

.. literalinclude:: freebsd_disk_startup/geom_disk
   :caption: 使用 ``geom`` 列出磁盘

.. literalinclude:: gpart/geom_disk_output
   :caption: 使用 ``geom`` 列出磁盘可以看到4块nvme设备 ``ndaX``
   :emphasize-lines: 1,9,14,22,27,35,40,48

请注意，这里的磁盘命名是 ``ndaX`` ，根据 `FreeBSD handbook: 3.6. Disk Organization <https://docs.freebsd.org/en/books/handbook/basics/#disk-organization>`_ ，磁盘类型 ``NVMe storage`` 的设备命名是 ``nvd`` 或 ``nda`` ，所以这里 ``nda0`` 表示第一块 :ref:`nvme` 存储，而 ``nda3`` 表示第4块NVMe存储。

磁盘分区
===========

分区工具 ``gpart`` 可以显示和划分磁盘分区，这个工具的命令 ``show`` 可以显示磁盘分区:

.. literalinclude:: gpart/show_nda
   :caption: 使用 ``gpart show ndaX`` 命令分别检查磁盘的分区
   :emphasize-lines: 14

这里遇到一个非常奇怪的问题，虽然 ``geom disk list`` 显示有 ``nda3`` ，但是当使用 ``gpart show nda3`` 时候是报错的，显示并不存在这个设备

直接使用 ``gpart show`` 命令，不带任何参数，可以看到如下输出:

.. literalinclude:: gpart/show_output
   :caption: 直接使用 ``gpart show`` 输出
   :emphasize-lines: 19-24

不过，另一个工具 ``diskinfo`` 可以查看所有的 ``ndaX`` 设备，例如 ``nda3`` :

.. literalinclude:: gpart/diskinfo
   :caption: 使用 ``diskinfo`` 检查磁盘

输出信息显示 ``nda3`` 正常:

.. literalinclude:: gpart/diskinfo_output
   :caption: 使用 ``diskinfo`` 检查磁盘


磁盘分区: ``nda0``
----------------------

- 首先创建GPT分区(这里会提示失败，因为实际上之前已经创建过GPT分区表):

.. literalinclude:: gpart/create_gpt
   :caption: 如果磁盘首次使用，需要创建GPT分区表

这里输出显示GPT分区表已经存在，原因是磁盘已经构建过GPT分区表

.. literalinclude:: gpart/create_gpt_output
   :caption: 如果已经存在GPT分区表

- 创建一个分区，分配 ``256G`` ( ``-s`` )并且设置以 ``1M`` 大小进行对齐( ``-a 1M`` ):

.. literalinclude:: gpart/add_partition
   :caption: 添加分区1

然后检查 ``gpart show nda0`` 可以看到如下:

.. literalinclude:: gpart/add_partition_output
   :caption: 添加了一个分区之后的输出情况
   :emphasize-lines: 3

这里对比已经安装了 FreeBSD 操作系统的磁盘分区 ``gpart show diskid/DISK-Y39B70RTK7AS`` :

.. literalinclude:: gpart/freebsd_partition
   :caption: 已经安装了FreeBSD的磁盘分区情况
   :emphasize-lines: 5

gpart 分区的 ``-s`` 参数表示容量大小，这里是 ``256G`` ，所以可以看到我手工划分的分区1和之前通过FreeBSD安装时划分的分区边界(大小)是一样的。

- 接下来再给 ``nda0`` 添加分区2，这里因为是完全分配剩余空间，所以不指定 ``-s`` 参数:

.. literalinclude:: gpart/add_partition_2
   :caption: 添加分区2

完成后检查 ``gpart show nda0`` 输出如下:

.. literalinclude:: gpart/show_nda0
   :caption: 完成添加分区2之后检查 ``nda0`` 的分区表
   :emphasize-lines: 3,4

磁盘分区 ``diskid/DISK-Y39B70RTK7AS``
---------------------------------------

- 对于已经安装了FreeBSD系统的磁盘 ``diskid/DISK-Y39B70RTK7AS`` ，现在添加一个分区来分配所有剩余空间，类型是 ``freebsd-zfs`` 用于后续构建 ``zdata`` zpool:

.. literalinclude:: gpart/sys_add_partition_2
   :caption: 在系统磁盘 ``diskid/DISK-Y39B70RTK7AS`` 添加分区2

- 完成后检查 ``gpart show diskid/DISK-Y39B70RTK7AS`` 显示分区如下:

.. literalinclude:: gpart/sys_show_partition
   :caption: 系统磁盘分区情况
   :emphasize-lines: 6

磁盘分区 ``nda1`` 和 ``nda2``
-------------------------------

- 参考 ``nda0`` 划分分区方法，为 ``nda1`` 和 ``nda2`` 划分同样大小的分区:

.. literalinclude:: gpart/add_partition_1_2
   :caption: 为 ``nda1`` 和 ``nda2`` 划分分区

- 现在所有划分分区工作完成，最后使用 ``gpart show`` 显示和验证所有分区如下:

.. literalinclude:: gpart/show_all
   :caption: 显示完成后的所有分区
   :emphasize-lines: 24,30,36,42

后续工作
=========

- :ref:`freebsd_zfs_stripe`

参考
======

- `Adding a Volume and Creating Partitions in FreeBSD <https://serverspace.us/support/help/adding-a-volume-and-creating-partitions-in-freebsd/>`_
- `GPART(8)  System Manager's Manual <https://man.freebsd.org/cgi/man.cgi?gpart(8)>`_
- `FreeBSD handbook: Chapter 20.Storage <https://docs.freebsd.org/en/books/handbook/disks/>`_
- `How to Use 'gpart' to Manage Partitions on FreeBSD Operating System <https://www.siberoloji.com/how-to-use-gpart-to-manage-partitions-on-freebsd/#google_vignette>`_
