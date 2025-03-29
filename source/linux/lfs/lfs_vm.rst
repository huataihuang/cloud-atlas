.. _lfs_vm:

=====================
LFS虚拟机
=====================

最初学习实践是在虚拟机中完成，虚拟机构建采用了如下步骤:

- :ref:`gentoo_virtualization`

  - :ref:`gentoo_zfs_xcloud` 底层存储采用了 :ref:`zfs` 方便运行大量虚拟机
  - :ref:`libvirt_zfs_pool` ZFS存储引入 :ref:`libvirt` 中作为存储后端驱动
  
- 虚拟机使用了 :ref:`fedora` 当前最新(Fedora 40) Xfce spin发行版

.. literalinclude:: ../../kvm/startup/create_vm/create_fedora40_vm_zfs
   :caption: 创建ZFS存储卷上的Fedora 40虚拟机

- 通过 ``virt-manager`` 连接虚拟机spice图形界面，快速完成操作系统安装

- 通过 ``virt-manager`` 配置虚拟机硬件，将后续用于LFS的目标虚拟磁盘添加为第2块硬盘(以下为 ``fdisk -l`` 输出信息，可以看到有一个 ``30GB`` 的 ``/vdb`` 等待着我们:

.. literalinclude:: lfs_vm/fdisk_output
   :caption: ``fdisk -l`` 输出信息
   :emphasize-lines: 14
