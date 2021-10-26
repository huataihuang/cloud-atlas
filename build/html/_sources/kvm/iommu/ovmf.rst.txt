.. _ovmf:

=====================================
Open Virtual Machine Firmware(OMVF)
=====================================

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
