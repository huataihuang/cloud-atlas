.. _boot_win_partition_in_kvm:

========================================
在KVM中直接运行Windows分区上Windows系统
========================================

和 `Boot Your Windows Partition from Linux using KVM <https://jianmin.dev/2020/jul/19/boot-your-windows-partition-from-linux-using-kvm/>`_ 的情况类似，我有一台 :ref:`thinkpad_x220` 自带了正版的 :ref:`win7` 操作系统，我希望能够在日常工作中使用Linux，同时能够运行 Windows 虚拟机来运行一些Windows应用。如果再创建虚拟磁盘来运行Windows显然浪费了现有正版 :ref:`win7` license，此外我也想看看是否可以通过 :ref:`ovmf_gpu_nvme` 类似技术来加速虚拟机。

本文挖坑，待后续准备好硬件资源后开搞，待续...

参考
=======

- `Boot Your Windows Partition from Linux using KVM <https://jianmin.dev/2020/jul/19/boot-your-windows-partition-from-linux-using-kvm/>`_
- `Add physical partition to QEMU/KVM virtual machine in virt-manager <https://askubuntu.com/questions/927574/add-physical-partition-to-qemu-kvm-virtual-machine-in-virt-manager>`_
