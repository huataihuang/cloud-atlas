.. _intel_vt-d_startup:

=====================
Intel VT-d快速起步
=====================

:ref:`kvm_storage_io` 中性能最好的磁盘IO是 ``pass-through`` ，即 ``IOMMU`` 技术。这项技术在Intel中称为 ``VT-d`` ，本文就是在 :ref:`hpe_dl360_gen9` 服务器上实现 :ref:`priv_cloud_infra` ，在最底层的第一层虚拟化中，即采用虚拟机直接访问存储，以实现最好的I/O性能。

具体实现:

- HDD磁盘2块，分别 ``assign`` 给 ``z-gluster-1`` 和 ``z-gluster-2`` ，部署 :ref:`gluster`
- 使用NVMe 存储卡(4个slot)，安装4个m.2的NVMe存储，其中3个NVMe存储通过 ``pass-through`` 直接 ``assign`` 给 ``z-ceph-1`` 、 ``z-ceph-2`` 和 ``z-ceph-3``  虚拟机，部署 :ref:`ceph`

准备工作
==========

- 服务器BIOS激活 VT-d 

- :ref:`ubuntu_linux` 内核默认已经编译支持了 ``IOMMU`` ，通过以下方式检查::

   dmesg | grep -e DMAR -e IOMMU

输出显示:

.. literalinclude:: intel_vt-d_startup/dmesg_no_iommu.txt
   :language: bash
   :linenos:
   :caption:

需要注意，此时还没有看到内核激活IOMMU，必须要看到 ``DMAR: IOMMU enabled`` 才是真正激活

- 我使用Ubuntu，所以采用 :ref:`ubuntu_grub` ，即修改 ``/etc/default/grub`` 设置::

   GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on"

然后更新grub::

   sudo update-grub

并重启系统，然后检查 ``cat /proc/cmdline`` 可以看到::

   ... intel_iommu=on

- 重启完成后检查 ``dmesg | grep -e DMAR -e IOMMU`` 可以看到输出中多了几行内容:

.. literalinclude:: intel_vt-d_startup/dmesg_iommu.txt
   :language: bash
   :emphasize-lines: 3,20-23
   :linenos:
   :caption:

参考
======

- `How to assign devices with VT-d in KVM <http://www.linux-kvm.org/page/How_to_assign_devices_with_VT-d_in_KVM>`_ 
- `KVM : GPU Passthrough <https://www.server-world.info/en/note?os=Ubuntu_18.04&p=kvm&f=11>`_
