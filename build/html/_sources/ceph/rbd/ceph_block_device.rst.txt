.. _ceph_block_device:

==============================
Ceph Block Device(块设备)
==============================

一个块就是一系列字节(a sequence of bytes)，通常是512字节。块设备存储接口是一种成熟和通用的存储数据到HDDs,SDDs,CDs,软盘,磁带的方法。无所不在的块设备接口是数据存储(包括Ceph)交互的完美方式。

Ceph块设备是一个精简配置(thin-provisioned)，可伸缩(resizable)以及条带化存储数据(store data striped over)到多个OSDs。Ceph块设备提供的RADOS能力包括 ``快照`` (snapshotting) ， ``多副本`` (replication) 以及 ``强一致性`` (strong consistency) 。Ceph块存储客户端直接通过内核模块或 ``librbd`` 库和Ceph集群通讯。

.. figure:: ../../_static/ceph/rbd/ceph_rbd.png

.. note::

   内核模块使用Linux页缓存(Linux page caching)，而使用 ``librbd`` 的应用程序，则Ceph支持 RBD Caching

Ceph块设备使用了内核模块提供了存储高性能，对于KVM (QEMU) 以及云计算系统如 :ref:`openstack` 和 ``CloudStack`` 则基于 :ref:`libvirt` 和QEMU集成Ceph块设备。此外，还可以同时使用 :ref:`ceph_iscsi` 和 :ref:`cephfs` 。

参考
=======

- `Ceph Block Device <https://docs.ceph.com/en/latest/rbd/>`_
