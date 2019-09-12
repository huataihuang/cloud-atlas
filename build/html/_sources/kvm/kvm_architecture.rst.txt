.. _kvm_architecture:

======================
KVM虚拟化
======================

KVM(Kernel-based Virtual Machine)，是内建在Linux Kernel中的hypervisor。相对于另一种开源虚拟化Xen，KVM更为简单和易用，并且和原生QEMU不同，KVM通过一个呢诶和恶模块来使用CPU硬件扩展(HVM)来运行一个特殊运行模式的QEMU。

通过KVM，可以在Host物理主机上运行多种无需修改的操作系统(Linux, Windows, 甚至macOS)，每个额虚拟机都有自己私有的虚拟硬件：网卡、磁盘、显卡等等。注意，KVM和Xen不同之处是KVM是作为Linux的一部分，采用了常规的Linux调度和内存管理，所以更为小巧和易于使用。同时KVM仅支持x86 hvm(vt/svm指令集)，不需要修改Guest操作系统，所以KVM并不支持paravirtualation for CPU，但是KVM为了提高I/O性能，支持paravirtualization for device drivers(驱动半虚拟化)。

- 检查虚拟化支持情况::

   LC_ALL=C lscpu | grep Virtualization

输出显示::

   Virtualization:                  VT-x

- 检查内核是否支持KVM::

   zgrep CONFIG_KVM /proc/config.gz

然后检查内核模块是否自动加载::

   lsmod | grep kvm

- 检查内核是否支持VIRTIO(提高性能)::

   zgrep VIRTIO /proc/config.gz

然后检查是否加载了内核模块::

   lsmod | grep virtio

参考
========

- `Arch Linux文档 - KVM <https://wiki.archlinux.org/index.php/KVM>`_
- `Arch Linux文档 - QEMU <https://wiki.archlinux.org/index.php/QEMU>`_
