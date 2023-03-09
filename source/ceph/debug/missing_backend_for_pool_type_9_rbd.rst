.. _missing_backend_for_pool_type_9_rbd:

==============================================================
libvirt的RBD存储池报错"missing backend for pool type 9 (rbd)"
==============================================================

最近在运维 :ref:`priv_cloud_infra` ，想要继续创建基于 :ref:`ceph_rbd_libvirt` 的虚拟机时候，意外发现原先创建的 ``images_rbd`` 存储池状态始终是 ``unknown`` ，既无法 ``pool-start`` ，也无法 ``pool-fresh`` 。虽然在这个 ``images_rbd`` 存储池中原先创建的虚拟机都运行完全正常(起停和运行)，但是就是无法创建新的虚拟机::

   # virsh pool-list --all
   error: Could not retrieve pool information
    Name           State     Autostart
   -------------------------------------
    boot-scratch   active    yes
    images         active    yes
    images_lvm     active    yes
    images_rbd     unknown   yes
    nvram          active    yes

尝试创建虚拟机镜像报错:

.. literalinclude:: ../../linux/suse_linux/install_opensus_leap/create_rbd_image
   :language: bash
   :caption: virsh创建 ``z-opensuse-leap-15`` RBD镜像

报错信息::

   error: Failed to create vol z-opensuse-leap-15
   error: Requested operation is not valid: storage pool 'images_rbd' is not active

但是激活无效::

   # virsh pool-start images_rbd
   error: Failed to start pool images_rbd
   error: internal error: missing backend for pool type 9 (rbd)

为何会出现 ``internal error: missing backend for pool type 9 (rbd)`` 错误呢？

排查
======

- 导出 ``images_rbd`` 存储池定影xml::

   virsh pool-dumpxml images_rbd > pool_images_rbd.xml

- 我本来以为可以先 undefine ( ``pool-destroy`` ) 然后重新 define ( ``pool-define`` )，但是没想到也需要 ``rbd`` 支持::

   $ virsh pool-destroy images_rbd
   error: Failed to destroy pool images_rbd
   error: internal error: missing backend for pool type 9 (rbd)

Google了一下，原来 Debian 将一些可选的存储后端选项支持采用了独立的软件包，以便在大多数情况下不必下载太多非必要包。例如， :ref:`zfs` 作为 :ref:`libvirt` 存储后端就采用 ``libvirt-daemon-driver-storage-zfs`` 。

我检查了::

   apt list | grep libvirt-daemon-driver-storage

果然， :ref:`gluster` , ``iSCSI`` , RBD ( :ref:`ceph_rbd` ) , :ref:`zfs` 都采用了独立软件包且尚未安装::

   libvirt-daemon-driver-storage-gluster/jammy-updates 8.0.0-1ubuntu7.4 amd64
   libvirt-daemon-driver-storage-iscsi-direct/jammy-updates 8.0.0-1ubuntu7.4 amd64
   libvirt-daemon-driver-storage-rbd/jammy-updates 8.0.0-1ubuntu7.4 amd64
   libvirt-daemon-driver-storage-zfs/jammy-updates 8.0.0-1ubuntu7.4 amd64

这说明之前 :ref:`ceph_rbd_libvirt` 实践时，Ubuntu尚未独立发布 ``libvirt-daemon-driver-storage-rbd`` 所以libvirt内建支持RBD。但是随着操作系统升级，需要独立安装:

.. literalinclude:: missing_backend_for_pool_type_9_rbd/ubuntu_install_libvirt_rbd
   :language: bash
   :caption: Ubuntu 安装 ``libvirt-daemon-driver-storage-rbd``

然后重启 ``libvirtd`` 再次执行 ``virtsh pool-list --all`` 就能观察到 :ref:`ceph_rbd` 存储池状态:

.. literalinclude:: missing_backend_for_pool_type_9_rbd/pool-list_rbd
   :language: bash
   :caption: 安装 ``libvirt-daemon-driver-storage-rbd`` 后检查可以看到RBD存储池状态 ``inactive``
   :emphasize-lines: 7


参考
=======

- `libvirt no longer has support for zfs pools (18.04 regression) <https://bugs.launchpad.net/ubuntu/+source/libvirt/+bug/1767973>`_

