.. _lfs_vm:

=====================
LFS虚拟机
=====================

我的学习实践是在虚拟机中完成，虚拟机构建采用了如下步骤:

- :ref:`gentoo_virtualization`

  - :ref:`gentoo_zfs_xcloud` 底层存储采用了 :ref:`zfs` 方便运行大量虚拟机
  - :ref:`libvirt_zfs_pool` ZFS存储引入 :ref:`libvirt` 中作为存储后端驱动
  
- 虚拟机使用了 :ref:`fedora` 当前最新(Fedora 40) Sway spin发行版

.. literalinclude:: ../../kvm/startup/create_vm/create_lfs_vm_zfs
   :caption: 创建ZFS存储卷上的Fedora 40虚拟机
