.. _ceph_extend_rbd_drive_with_libvirt_xfs:

=====================================
使用libvirt和XFS在线扩展Ceph RBD设备
=====================================

我在 :ref:`kubeadm_upgrade_k8s_1.25` 升级虚拟机操作系统，但是由于最初虚拟机创建的磁盘较小，所以需要扩展磁盘后才能升级系统。

- 检查 :ref:`ceph_rbd_libvirt` 存储池RBD块设备:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/rbd_ls
   :language: bash
   :caption: 执行 rbd ls 命令检查存储池中rbd磁盘

可以看到::

   NAME               SIZE     PARENT  FMT  PROT  LOCK
   z-k8s-m-1          6.5 GiB            2        excl
   z-k8s-m-1.docker   9.3 GiB            2        excl
   z-k8s-m-2          6.5 GiB            2        excl
   z-k8s-m-2.docker   9.3 GiB            2        excl
   ...

- 检查详细的RBD存储块信息::

   rbd info libvirt-pool/z-k8s-m-1

输出显示::

   rbd image 'z-k8s-m-1':
           size 6.5 GiB in 1669 objects
           order 22 (4 MiB objects)
           snapshot_count: 0
           id: 31f3344490f20
           block_name_prefix: rbd_data.31f3344490f20
           format: 2
           features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
           op_features: 
           flags: 
           create_timestamp: Fri Dec 10 11:53:41 2021
           access_timestamp: Tue Nov  8 21:56:00 2022
           modify_timestamp: Tue Nov  8 22:47:19 2022

- RBD调整磁盘大小到16GB ( 1024x16=16384 )，并且 ``virsh blockresize`` 刷新虚拟机磁盘:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/rbd_resize_virsh_blockresize
   :language: bash
   :caption: rbd resize调整RBD块设备镜像大小, virsh blockresize调整虚拟机vda大小

- 登录到虚拟机内部执行growpart和xfs_growfs调整分区以及文件系统大小:

.. literalinclude:: ../deploy/install_ceph_manual/ceph_os_upgrade_ubuntu_22.04/vm_growpart_xfs_growfs
   :language: bash
   :caption: 在虚拟机内部使用growpart和xfs_growfs扩展根目录文件系统

.. _ceph_extend_rbd_drive_with_libvirt_xfs_vdb1:

在线扩展Ceph RBD磁盘vdb1
===============================

我在 :ref:`stable_diffusion_on_k8s` 也同样遇到了虚拟机 ``/dev/vdb1`` 空间不足导致无法运行容器的问题，解决方法相似

- 再次检查rbd磁盘 

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/rbd_ls
   :language: bash
   :caption: 执行 rbd ls 命令检查存储池中rbd磁盘

可以看到虚拟机 ``z-k8s-n-1`` 磁盘::

   NAME               SIZE     PARENT  FMT  PROT  LOCK
   z-k8s-n-1           16 GiB            2        excl
   z-k8s-n-1.docker   9.3 GiB            2        excl

- 检查 ``z-k8s-n-1.docker`` 磁盘详细信息::

   rbd info libvirt-pool/z-k8s-n-1.docker

显示如下::

   rbd image 'z-k8s-n-1.docker':
   	size 9.3 GiB in 2385 objects
   	order 22 (4 MiB objects)
   	snapshot_count: 0
   	id: 4f30059fb9053
   	block_name_prefix: rbd_data.4f30059fb9053
   	format: 2
   	features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
   	op_features:
   	flags:
   	create_timestamp: Wed Dec 29 08:21:52 2021
   	access_timestamp: Fri Jan 13 10:37:56 2023
   	modify_timestamp: Fri Jan 13 10:39:06 2023

- 将 ``z-k8s-n-1.docker`` 扩展到50G( 1024x50=51200 )，并且 ``virsh blockresize`` 刷新虚拟机磁盘:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/rbd_resize_virsh_blockresize_vbd
   :language: bash
   :caption: rbd resize调整RBD块设备镜像大小, virsh blockresize调整虚拟机vdb大小

- 登录到虚拟机内部执行growpart和xfs_growfs调整分区以及文件系统大小:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/vm_vbd1_growpart_xfs_growfs
   :language: bash
   :caption: 在虚拟机内部使用growpart和xfs_growfs扩展vdb1对应文件系统/var/lib/containerd

- 完成后检查空间可以看到已经在线扩展成50G::

   $ df -h | grep vdb1
   /dev/vdb1        50G  8.2G   42G  17% /var/lib/containerd

离线扩展Ceph RBD磁盘vdb1
==============================

在 :ref:`install_kubeflow_single_command` 遇到磁盘空间不足导致 :ref:`node_pressure_eviction` ，所以我将节点依次关闭:

- 扩容 ``/dev/vbd1`` 磁盘空间
- 将 ``vbd1`` 挂载目录从 ``/var/lib/docker`` 改为 ``/var/lib/containerd`` (原因是 :ref:`y-k8s` 采用 :ref:`kubespray` 部署，实际上使用的 :ref:`containerd` )

案例以 ``z-k8s-n9`` 为例

虚拟磁盘添加到维护虚拟机
-------------------------

- 由于 ``z-k8s-n9`` 是虚拟机，磁盘是 :ref:`ceph_rbd` ，首先检查虚拟磁盘的 :ref:`libvirt` 配置:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/rbd.xml
   :language: xml
   :caption: 需要维护服务器rbd配置

- 我使用 ``z-dev`` 虚拟机来加载这两个需要维护的磁盘，在 ``z-dev`` 的虚拟机上，原先的 ``vda`` 配置如下:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/z-dev_vda.xml
   :language: xml
   :caption: 用于运维的 ``z-dev`` 磁盘 ``vda``

- 将上述 ``z-k8s-n9`` 的 :ref:`ceph_rbd` 配置添加到 ``z-dev`` 虚拟机，不过需要修改2个地方:

  - 磁盘 ``target`` 命名需要从 ``vda`` 和 ``vdb`` 修改为 ``vdb`` 和 ``vdc``
  - 删除虚拟磁盘 ``<address type='pci' domain='0x0000' bus='0x07' slot='0x00' function='0x0'/>`` 类似的这行配置，让 :ref:`libvirt` 自动决定配置(否则容易冲突)

- 启动 ``z-dev`` 之后检查 ``fdisk -l`` 输入如下:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/vdb_vdc
   :caption: 挂载的 ``rbd`` 磁盘 ``vdb`` 和 ``vdc``
   :emphasize-lines: 10,21

- 上述2个磁盘为需要调整磁盘，其中 ``vdc`` 先扩展到 100G (方法同上):

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/rbd_ls
   :language: bash
   :caption: 执行 rbd ls 命令检查存储池中rbd磁盘

需要扩容的磁盘如下:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/rbd_ls_output
   :caption: 执行 rbd ls 命令检查存储池中rbd磁盘，需要扩容的磁盘

- RBD调整磁盘大小到100GB ( 1024x100=102400 )，并且 ``virsh blockresize`` 刷新虚拟机磁盘:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/rbd_resize_virsh_blockresize_100g
   :language: bash
   :caption: rbd resize调整RBD块设备镜像大小, virsh blockresize调整虚拟机磁盘大小，100g

- 完成后在虚拟机内部检查 ``fdisk -l`` 可以看到磁盘扩展到100G:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/vdc_100g
   :caption: ``rbd resize`` 和 ``virsh blockresize`` 之后在虚拟机内部可以看到扩展后的虚拟机磁盘达到100G
   :emphasize-lines: 1

- 在虚拟机内部重新创建文件系统( :ref:`parted` 重建GPT分区，并且构建 :ref:`xfs` ):

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/vdc_xfs
   :caption: 在 ``vdc`` 上构建 :ref:`xfs`

- 挂载磁盘:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/mount_vdb_vdc
   :caption: 挂载 ``vdb`` 和 ``vdc`` 的分区，准备数据迁移

现在需要迁移的数据::

   /vdb2/var/lib/containerd  => /vdc2 (这个磁盘后续将挂载为目标主机的 /var/lib/containerd)

- 数据迁移:

.. literalinclude:: ceph_extend_rbd_drive_with_libvirt_xfs/migrate_containerd
   :caption: 数据迁移

- 修改 ``/vdb2/etc/fstab`` (这个是系统磁盘上挂载磁盘配置)::

   /dev/vdb1    /var/lib/containerd    xfs   defaults,quota,gquota,prjquota 0 1

参考
======

- `Extend rbd drive with libvirt and XFS <https://ceph.io/en/news/blog/2013/ceph-rbd-online-resize/>`_
- `Ceph Block Device: Basic Commands <https://docs.ceph.com/en/quincy/rbd/rados-rbd-cmds/>`_
