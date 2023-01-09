.. _intel_vt-d_startup:

=====================
Intel VT-d快速起步
=====================

KVM中性能最好的磁盘IO是 ``pass-through`` ，即 ``IOMMU`` 技术。这项技术在Intel中称为 ``VT-d`` ，本文就是在 :ref:`hpe_dl360_gen9` 服务器上实现 :ref:`priv_cloud_infra` ，在最底层的第一层虚拟化中，即采用虚拟机直接访问存储，以实现最好的I/O性能。

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

.. note::

   如果使用AMD处理器，则内核参数可以使用以下配置::

      iommu=pt iommu=1    # AMD only

   ``iommu=pt`` 可以避免Linux使用不能pass-through的设备，详见 :ref:`iommu_grub_config`

然后更新grub::

   sudo update-grub

.. note::

   如果是CentOS/RHEL 则使用 ``grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg`` 命令

并重启系统，然后检查 ``cat /proc/cmdline`` 可以看到::

   ... intel_iommu=on

- 重启完成后检查 ``dmesg | grep -e DMAR -e IOMMU`` 可以看到输出中多了几行内容:

.. literalinclude:: intel_vt-d_startup/dmesg_iommu.txt
   :language: bash
   :emphasize-lines: 3,20-23
   :linenos:
   :caption:

确认IOMMU groups
------------------

以下脚本 ``check_iommu.sh`` 脚本可以查看系统中不同的PCI设备被映射到IOMMU组，如果没有返回任何信息，则表明系统没有激活IOMMU支持或者硬件不支持IOMMU

.. literalinclude:: ovmf_gpu_nvme/check_iommu.sh
   :language: bash
   :caption: 检查PCI设备映射到IOMMU组

Host主机unbind设备
====================

要将PCI设备直通给虚拟机，需要首先在Host物理主机上 ``unbind`` 这个PCI设备，也就是在物理主机上这个设备将 ``消失`` ，然后 ``asign`` 设备给虚拟机，这样这个设备就是虚拟机 ``独占`` 使用

.. note::

   由于我实践方案修改，所以 Intel VT-d 实践改为在 :ref:`ovmf` 完成。后续等再次实践时补充完善本文




参考
======

- `Red Hat Enterprise Linux8 > Configuring and managing virtualization: 12.1. Assigning a GPU to a virtual machine <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_virtualization/assembly_managing-gpu-devices-in-virtual-machines_configuring-and-managing-virtualization>`_
- `How to assign devices with VT-d in KVM <http://www.linux-kvm.org/page/How_to_assign_devices_with_VT-d_in_KVM>`_ 
- `KVM : GPU Passthrough <https://www.server-world.info/en/note?os=Ubuntu_18.04&p=kvm&f=11>`_
- `arch linux: PCI passthrough via OVMF <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF>`_ arch linux文档不愧是Linux发行版中最详尽的，提供了不同Host设备passthrough给虚拟机的方法和案例
- `gentoo linux: GPU passthrough with libvirt qemu kvm <https://wiki.gentoo.org/wiki/GPU_passthrough_with_libvirt_qemu_kvm>`_ 和arch linux相似，Gentoo Linux文档也非常深刻
- `QEMU Features/VT-d <https://wiki.qemu.org/Features/VT-d>`_ 
