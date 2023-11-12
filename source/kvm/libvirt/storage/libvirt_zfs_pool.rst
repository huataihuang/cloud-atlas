.. _libvirt_zfs_pool:

=======================
libvirt ZFS存储池
=======================

:ref:`arch_linux` 的 ``X86_64`` 架构对 :ref:`zfs` 和 :ref:`stratis` 都有良好支持，所以我计划:

- 在MacBook Pro 2013笔记本上同时采用这两种存储技术来构建 ``libvit`` 存储后端
- 在 :ref:`priv_cloud_infra` 上利用3块旧的HDD构建ZFS扩展 ``libvit`` 存储后端 (感觉性能会比较差，所以考虑这个ZFS存储作为离线数据存储)
- 在 :ref:`priv_cloud_infra` 使用购买的二手SSD磁盘 :ref:`sandisk_cloudspeed_eco_gen_ii_sata_ssd` 构建ZFS存储池提供虚拟机集群模拟

.. note::

   libvirt ZFS存储池 非常类似 :ref:`libvirt_lvm_pool` ，基于卷来管理虚拟机的存储分配和隔离，是适合大型云计算的基础存储方案。虽然没有 :ref:`ceph_rbd_libvirt` 方案提供了分布式存储的容灾和高可用，但是非常适合构建低成本 spot vm 的存储。通过 ZFS 强大的海量存储管理能力，精简掉RAID功能，使用基础的卷管理能力来实现。

准备工作
=========

- SSD磁盘 :ref:`sandisk_cloudspeed_eco_gen_ii_sata_ssd` 已经在 :ref:`zfs_startup_zcloud` 已经构建了一个基础ZFS pool ``zpool-data`` :

.. literalinclude:: ../../../linux/storage/zfs/admin/zfs_startup_zcloud/zpool_create
   :caption: 在磁盘 ``sda`` 上创建ZFS的存储池，名字为 ``zpool-data``

检查 ``zpool list`` 输出如下:

.. literalinclude:: ../../../linux/storage/zfs/admin/zfs_startup_zcloud/zpool_list_output
   :caption: 使用 ``zpool list`` 检查现有的zpool存储池 可以看到刚创建的 ``zpool-data``

- 当前 ``zcloud`` 上构建的 :ref:`libvirt` 存储:

.. literalinclude:: libvirt_zfs_pool/virsh_pool-list_output
   :caption: ``virsh pool-list`` 查看当前系统已经具备的 libvirt 存储池
   :emphasize-lines: 4-6

其中:

  - ``images`` 是默认本地磁盘存储池 ``/var/lib/libvirt/images`` 目录
  - ``images_lvm`` 是 :ref:`libvirt_lvm_pool`
  - ``images_rbd`` 是 :ref:`ceph_rbd_libvirt`

接下来我们创建一个ZFS存储池 ``images_zfs``

- 在 :ref:`ubuntu_linux` 平台，需要安装 libvirt 的 ZFS 存储驱动软件包:

.. literalinclude:: libvirt_zfs_pool/ubuntu_install_libvirt_zfs_driver
   :caption: 在 Ubuntu 系统上安装libvirt的ZFS驱动

ZFS存储池定义
==============

- 对于已经存在的 ZFS 存储池 ``zpool-data`` 需要定义为libvirt的存储池:

.. literalinclude:: libvirt_zfs_pool/virsh_pool_define_zfs
   :caption: 定义 ``zpool-data`` 存储池作为libvirt的存储池

遇到报错显示没有zfs存储池后端:

.. literalinclude:: libvirt_zfs_pool/virsh_pool_define_zfs_err
   :caption: 定义 ``zpool-data`` 存储池作为libvirt的存储池报错，显示没有zfs后端

这是因为没有安装上文所说的 **libvirt 的 ZFS 存储驱动软件包** ``libvirt-daemon-driver-storage-zfs`` ，此外，安装了这个libvirt的ZFS驱动之后，一定要重新启动一次 ``libvirtd`` 服务，否则也会报上述错误。

如果一切正常，则会看到输出

.. literalinclude:: libvirt_zfs_pool/virsh_pool_define_zfs_output
   :caption: 定义 ``zpool-data`` 存储池作为libvirt的存储池的成功输出信息

.. note::

   我发现重启一次 ``libvirtd`` 服务，会出现 :ref:`ceph_rbd_libvirt` 的存储池 ``images_rbd`` 处于 ``inactive`` 状态，需要手工激活一次

- 设置libvirt的ZFS存储池自动启动，并激活:

.. literalinclude:: libvirt_zfs_pool/virsh_pool_zfs_start
   :caption: libvirt的ZFS存储池自动启动，并激活

完成后检查 ``virsh pool-list`` 输出如下:

.. literalinclude:: libvirt_zfs_pool/virsh_pool-list_all
   :caption: ``virsh pool-list`` 输出
   :emphasize-lines: 7

创建虚拟机
============

- 为虚拟机创建ZFS卷(方法类似 :ref:`libvirt_lvm_pool` ):

.. literalinclude:: libvirt_zfs_pool/virsh_vol_create_zfs
   :caption: 为虚拟机创建20G容量的ZFS卷

这里创建的将要用于虚拟机的ZFS卷并不会挂载到物理主机目录，不过可以通过 ``zfs list`` 命令查看:

.. literalinclude:: libvirt_zfs_pool/zfs_list
   :caption: ``zfs list`` 可以查看到为虚拟机创建的卷
   :emphasize-lines: 5

- 创建虚拟机( :ref:`create_vm` ):

.. literalinclude:: ../../startup/create_vm/create_centos7_vm_zfs
   :caption: 在 :ref:`libvirt_zfs_pool` 创建CentOS 7虚拟机

clone虚拟机
============

``virsh`` 不支持clone ZFS卷
----------------------------

- 使用 virt-clone 克隆新的虚拟机( 参考 :ref:`libvirt_lvm_pool` ) **实践失败**

.. literalinclude:: libvirt_zfs_pool/virt-clone
   :caption: 使用 ``virt-clone`` 复制虚拟机，但是 **实际上对 ZFS 卷失败**

提示错误:

.. literalinclude:: libvirt_zfs_pool/virt-clone_err
   :caption: 使用 ``virt-clone`` 复制虚拟机，但是 **实际上对 ZFS 卷失败**

这个报错实际上就是 ``virsh clone-vol`` 的报错，原因是 ``libvirt`` 不支持 ZFS 卷clone。举例:

.. literalinclude:: libvirt_zfs_pool/virsh_vol-clone
   :caption: 使用 ``virsh vol-clone`` 尝试clone出ZFS卷

.. literalinclude:: libvirt_zfs_pool/virsh_vol-clone_err
   :caption: 使用 ``virsh vol-clone`` 尝试clone出ZFS卷报错信息

手工处理


参考
=======

- `ZFS and libvirt <https://sim.ovh/libvirt/zfs/>`_
- `Lucanuscervus Notes: ZFS Using ZFS with libvirt <https://lucanuscervus-notes.readthedocs.io/en/latest/Filesystems/ZFS/ZFS%20-%20Using%20ZFS%20with%20%20libvirt/>`_
- `libvirt storage: ZFS pool <https://libvirt.org/storage.html#zfs-pool>`_
- `KVM with ZFS support <https://operationroot.com/kvm-with-zfs-support.html>`_
