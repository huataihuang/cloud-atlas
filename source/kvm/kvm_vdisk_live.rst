.. _kvm_vdisk_live:

================================
KVM虚拟机动态添加、调整磁盘
================================

.. note::

   通过组合合适的VM文件系统功能（例如支持在线resize的XFS文件系统）和QEMU底层 ``virsh qemu-monitor-command`` 指令可以实现在线动态调整虚拟机磁盘容量，无需停机，对维护在线应用非常方便。不过，这里虚拟机磁盘扩容（resize）部分步骤需要在VM内部使用操作系统命令，所以适合自建自用的测试环境。
   
   生产环境reize虚拟机磁盘系统，可采用 `libguestfs <http://libguestfs.org/>`_ 来修改虚拟机磁盘镜像。 ``libguestfs`` 可以查看和编辑guest内部文件，脚本化修改VM，监控磁盘使用和空闲状态，以及创建虚拟机，P2V,V2V，以及备份，clone虚拟机，构建虚拟机，格式化磁盘，resize磁盘等等。详细请参考 :ref:`kvm_vdisk_live`

创建虚拟机磁盘
====================

.. note::

   这里案例创建的磁盘文件故意选择较小空间，例如5G，以便后续实验在线扩展。

- 创建虚拟机磁盘(qcow2类型)::

   cd /var/lib/libvirt/images
   qemu-img create -f qcow2 devstack-data.qcow2 5G
