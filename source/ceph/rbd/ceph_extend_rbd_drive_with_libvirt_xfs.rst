.. _ceph_extend_rbd_drive_with_libvirt_xfs:

=====================================
使用libvirt和XFS在线扩展Ceph RBD设备
=====================================

我在 :ref:`kubeadm_upgrade_k8s_1.25` 升级虚拟机操作系统，但是由于最初虚拟机创建的磁盘较小，所以需要扩展磁盘后才能升级系统。

- 检查 :ref:`ceph_rbd_libvirt` 存储池RBD块设备::

   rbd -p libvirt-pool ls -l

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


参考
======

- `Extend rbd drive with libvirt and XFS <https://ceph.io/en/news/blog/2013/ceph-rbd-online-resize/>`_
- `Ceph Block Device: Basic Commands <https://docs.ceph.com/en/quincy/rbd/rados-rbd-cmds/>`_
