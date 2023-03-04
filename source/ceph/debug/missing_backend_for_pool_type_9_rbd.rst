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


