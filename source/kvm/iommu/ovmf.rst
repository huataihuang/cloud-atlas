.. _ovmf:

=====================================
Open Virtual Machine Firmware(OMVF)
=====================================

Open Virtual Machine Firmware(OMVF)是在虚拟机内部激活UEFI支持的开源项目，从Linux 3.9和最新QEMU开始，可以将图形卡直通给虚拟机，提供VM原生图形性能，对图形性能敏感对任务非常有用。

准备工作
===========

显示直通(VGA passthrough)依赖很多比较少见的技术，并且有可能需要你的硬件支持才能实现。要完成直通，

virt-install
--------------

在 ``virt-install`` 命令添加 ``--boot uefi`` 参数::

   sudo virt-install --name f20-uefi \
   --ram 2048 --disk size=20 \
   --boot uefi \
   --location https://dl.fedoraproject.org/pub/fedora/linux/releases/22/Workstation/x86_64/os/

参考
======

- `Open Virtual Machine Firmware (OVMF) Status Report <http://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt>`_
- `arch linux: PCI passthrough via OVMF <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF>`_
- `arch linux: libvirt <https://wiki.archlinux.org/title/libvirt>`_
- `Using UEFI with QEMU <https://fedoraproject.org/wiki/Using_UEFI_with_QEMU>`_
- `ubuntu wiki: OVMF <https://wiki.ubuntu.com/UEFI/OVMF>`_ 如果要自制OVMF镜像，可以参考 `ubuntu wiki: EDK2 <https://wiki.ubuntu.com/UEFI/EDK2>`_
- `Virtualizing Windows 7 (or Linux) on a NVMe drive with VFIO <https://frdmtoplay.com/virtualizing-windows-7-or-linux-on-a-nvme-drive-with-vfio/>`_
