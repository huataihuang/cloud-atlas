.. _bhyve_storage:

==========================
``bhyve`` 存储
==========================

在 :ref:`vm-bhyve` 中，我使用了自定义模版来使用 ``sparse-zvol`` ，这样在ZFS vol卷块存储上构建的 :ref:`bhyve_ubuntu` 可以用来实现FreeBSD不支持的功能。

我计划使用 :ref:`linux_jail` 来作为基础OS，构建一个 :ref:`lfs` ，但是如何创建一个Linux文件系统是一个问题: FreeBSD只支持对Linux文件系统的读写，但不能创建，所以我需要先在 :ref:`bhyve_ubuntu` 中对 :ref:`gpart_linux_zfs_partition` 创建的 ``linux-data`` 分区进行文件系统构建。

``bhyve`` 支持存储类型
=======================

``bhyve`` 支持3种存储类型:

.. csv-table:: ``bhyve`` 存储类型对比
   :file: bhyve_storage/storage.csv
   :widths: 10,30,30,30
   :header-rows: 1

分区
========

在 :ref:`gpart_linux_zfs_partition` 创建的分区如下( ``gpart show nda0`` ):

.. literalinclude:: bhyve_storage/gpart_show_output_all
   :caption: 使用 ``gpart`` 检查磁盘分区可以看到添加的2个分区
   :emphasize-lines: 7

分区4 ``linux-data`` ( ``/dev/diskid/DISK-Y39B70RTK7ASp4`` )将连接到 :ref:`bhyve_ubuntu` 创建需要的Linux文件系统

``vm-bhyve`` 配置
===================

.. note::

   这里记录了我最终实践正确的配置，实际上我走了一点弯路，见下文 "异常排查"

- 修订 :ref:`bhyve_nvidia_gpu_passthru_freebsd_15` 的虚拟机配置 ``/zdata/vms/xdev/xdev.conf`` :

.. literalinclude:: bhyve_storage/xdev.conf
   :caption: 在 ``xdev.conf`` 添加第二个 ``disk1`` 配置
   :emphasize-lines: 11-13

- 启动虚拟机: ``vm start xdev``

此时在Host主机上检查 ``vm-bhyve.log`` 可以看到使用了如下参数来启动和使用设备:

.. literalinclude:: bhyve_storage/vm-bhyve.log
   :caption: 通过 ``vm-bhyve.log`` 可以观察到bhyve的参数使用情况

.. note::

   这里还有一点波折，我发现添加了第二块虚拟磁盘之后，虚拟机识别的虚拟网卡命名从 ``enp0s5`` 变成了 ``enp0s6`` ，所以还需要通过VNC登陆终端修订一下 ``/etc/netplan/50-cloud-init.yaml`` 的网卡名字

虚拟机内部使用Host透传的物理磁盘分区
======================================

需要注意，Host主机的物理磁盘分区是作为块设备透传进虚拟机的，对于虚拟机来说，视为一个完整的磁盘。这样，使用上有一些需要注意点:

- 因为我的目标是通过虚拟机对Host主机的物理磁盘分区创建文件系统(因为Host主机FreeBSD系统没有这个能力)，所以不能在虚拟机内部使用这个映射块文件创建分区表，而是将整个磁盘直接创建文件系统
- 只有VM内部使用映射的块文件作为的虚拟磁盘不创建分区表，直接创建文件系统，那么回到Host主机上，就能正常看到分区上的Linux文件系统，也就能被Host主机的FreeBSD系统读写
- 后续也能在Host主机上对这个物理磁盘分区(文件系统)构建 :ref:`lfs` 

- 登陆到bhyve虚拟机内部检查 ``fdisk -l`` 可以看到一块NVMe设备:

.. literalinclude:: bhyve_storage/vm_fdisk
   :caption: 在虚拟机内部检查 ``fdisk -l`` 可以看到透传的分区现在是一个NVMe设备

- 现在可以在虚拟机内部(我的 ``xdev`` 使用了 :ref:`ubuntu_linux` 24.04.3)虚拟磁盘上创建EXT4文件系统:

.. literalinclude:: bhyve_storage/vm_mkfs.ext4
   :caption: 在虚拟机内部对Host透传给bhyve虚拟机的物理磁盘分区映射的NVMe虚拟磁盘创建EXT4文件系统

然后就可以在Host物理主机上实践:

  - :ref:`freebsd_ext`
  - :ref:`freebsd_ext4`

- 也可以在虚拟机内部(我的 ``xdev`` 使用了 :ref:`ubuntu_linux` 24.04.3)虚拟磁盘上创建XFS文件系统:

.. literalinclude:: bhyve_storage/vm_mkfs.xfs
   :caption: 在虚拟机内部对Host透传给bhyve虚拟机的物理磁盘分区映射的NVMe虚拟磁盘创建XFS文件系统

然后就可以在Host物理主机上实践:

  - :ref:`freebsd_xfs`

异常排查
============

.. note::

   我最初的配置是参考了Google AI的回答( ``freebsd vm-bhyve use disk partition`` )，但是Google AI的答案实际上似是而非，特别是提供的配置案例搞错了 ``disk1_dev`` (该配置是指Host主机的设备类型，但是Google AI误配置为Host主机设备)。以下是Google AI提供的错误配置:

   .. literalinclude:: bhyve_storage/error.conf
      :caption: 错误配置

最初的错误配置
----------------

我最初在 ``xdev.conf`` 自作聪明添加了一行 ``disk1_name="disk1"`` :

.. literalinclude:: bhyve_storage/xdev.conf_disk1
   :caption: **这个配置是错误的**
   :emphasize-lines: 2

没想到这个 ``disk1_name`` 会引导 ``vm-bhyve`` 去 ``/zdata/vms/xdev/`` 目录下找名为 ``disk1`` 的设备文件，日志 ``/zdata/vms/xdev/bhyve.log`` 报错：

.. literalinclude:: bhyve_storage/bhyve.log_error
   :caption: 日志报错显示 ``disk1`` 块文件不存在
   :emphasize-lines: 1

去除掉这行错误配置， ``vm-bhyve`` 才能启动，那么现在的配置正确了么？

.. literalinclude:: bhyve_storage/xdev.conf_disk1_ng
   :caption: **这个配置是依然是错误的**
   :emphasize-lines: 2,3

虚拟机启动了，但是我登陆 ``xdev`` 虚拟机，发现并没有第2块虚拟磁盘( ``fdisk -l`` )

这是为什么？我明明已经配置了 ``disk1_dev="/dev/diskid/DISK-Y39B70RTK7ASp4"`` ，难道不是指定了虚拟机的磁盘设备对应的物理Host的设备文件么？

最终的正确配置
----------------

经过一番搜索，我发现 `bhyve HDD passthrough <https://forums.freebsd.org/threads/bhyve-hdd-passthrough.93303/>`_ 的案例虽然不是Host主机物理分区传递给VM，但是提供了物理主机完整磁盘设备透传给VM的配置案例:

.. literalinclude:: bhyve_storage/hdd_passthru.conf
   :caption: 将物理主机HDD透传给bhyve虚拟机的配置案例
   :emphasize-lines: 9-12

原来:

  - ``disk1_name`` 指的是物理主机设备名，也就是要透传给bhyve虚拟机的Host主机设备
  
    - 如果是相对名，例如 ``disk0`` 就会在虚拟机目录 ``/zdata/vms/xdev`` 下找设备文件名 ``disk0``
    - 如果是绝对名，例如 ``/dev/diskid/DISK-Y39B70RTK7ASp4`` 就会把Host主机物理磁盘分区(p4)透传给bhyve虚拟机

  - ``disk1_dev`` 不是设备名，而是设备类型，通常有如下类型:

    - ``sparse-zolv`` : 稀疏类型的ZFS volume块文件，这是我之前构建虚拟机使用的
    - ``sparse-disk`` : 稀疏类型的磁盘镜像文件(disk image file)
    - ``disk`` : 磁盘镜像文件
    - ``custom`` : 自定义实际上就是物理设备? (目前我的实践是这样理解的)

  - ``disk1_type`` 不是Host主机的设备类型，而是bhyve使用的存储驱动类型，通常有如下类型(见上文对比表)

    - ``ahci-hd`` : 模拟标准SATA控制器
    - ``nvme`` : 模拟PCIe连接的NVMe控制器
    - ``virtio-blk`` : paravirtualized块设备

所以，我最终实践验证正确的将Host主机物理磁盘分区透传给bhyve虚拟机的配置是:

.. literalinclude:: bhyve_storage/xdev.conf
   :caption: 实践成功的透传物理主机磁盘分区的bhyve配置
   :emphasize-lines: 11-13

参考
=======

- `bhyve HDD passthrough <https://forums.freebsd.org/threads/bhyve-hdd-passthrough.93303/>`_ 这个案例启发了我修订了正确的配置

