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

参考
======

- `Extend rbd drive with libvirt and XFS <https://ceph.io/en/news/blog/2013/ceph-rbd-online-resize/>`_
- `Ceph Block Device: Basic Commands <https://docs.ceph.com/en/quincy/rbd/rados-rbd-cmds/>`_
