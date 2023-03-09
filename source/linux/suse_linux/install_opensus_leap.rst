.. _install_opensus_leap:

==============================
安装openSUSE Leap
==============================

`openSUSE Leap <https://get.opensuse.org/leap/>`_ 是openSUSE的稳定发行版本，和企业版对应，当前最新是 openSUSE Leap 15 SP4

准备工作
==========

安装测试环境采用 :ref:`kvm` 虚拟机环境 :ref:`priv_cloud_infra` ，安装3台虚拟机构建模拟的 :ref:`gluster_deploy_suse` :

- 虚拟机准备工作

  - 虚拟机底层采用 :ref:`ceph_rbd_libvirt` ，通过模拟分布式存储 :ref:`zdata_ceph` 构建的 :ref:`zdata_ceph_rbd_libvirt` 提供海量存储空间
  - 由于是模拟环境(需要模拟每个服务器12块磁盘)，我采用两种方式(之一):

    - 采用Ceph构建12块小容量 :ref:`ceph_rbd` 磁盘，这是最接近现实生产环境的部署方案
    - 采用一块大容量 :ref:`ceph_rbd` 磁盘，然后在这块磁盘中采用 :ref:`linux_lvm` 生成12个LVM逻辑卷，这样对操作系统来说就是12块磁盘(块设备)

      - 采用类似 :ref:`zfs_virtual_disks` 方案，在虚拟机内部构建12块虚拟磁盘

操作步骤
----------

- 在 :ref:`priv_cloud_infra` 环境存储池 ``images_rbd`` 创建虚拟机磁盘:

.. literalinclude:: install_opensus_leap/create_rbd_image
   :language: bash
   :caption: virsh创建 ``z-opensuse-leap-15`` RBD镜像

.. note::

   我这里遇到一个由于 :ref:`ubuntu_linux` 升级导致的 :ref:`missing_backend_for_pool_type_9_rbd` (解决方法)

参考
======

- `openSUSE Installation Quick Start <https://doc.opensuse.org/documentation/leap/startup/html/book-startup/art-opensuse-installquick.html>`_
