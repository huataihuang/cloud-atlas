.. _qemu_monitor:

=======================
QEMU Monitor管理虚拟机
=======================

当QEMU运行时，提供了一个监控控制台可以和虚拟机进行交互。在这个监控控制台，使用其提供的命令，就可以和运行操作系统进行检测(inspect)，修改可移除介质，截取屏幕或者捕获音频并且控制虚拟机的其他部分。

可以通过 ``qemu-system-ARCH`` 命令来直接启动虚拟机，此时就可以访问监控控制台，并且可以从一个原生QEMU窗口看到图形输出。

如果使用 :ref:`libvirt` 来启动虚拟机(例如使用 ``virt-manager`` )并通过VNC或Spice会话来观察输出，就不能直接访问监控控制台。此时需要通过 ``virsh`` 来发送 monitor 命令::

   virsh qemu-monitor-command COMMAND

.. note::

   QEMU monitor console支持很多控制台系统底层命令，有些命令在实践中非常有用。

QEMU Monitor Command功能列表
=============================

- 获取Guest系统信息
- 修改VNC密码
- 管理设备
- 控制键盘和鼠标
- 修改可用内存
- dump虚拟机内存
- 管理虚拟机快找
- 暂停和恢复虚拟机执行
- 热迁移

获取Guest系统信息
====================

.. note::

   以下案例虚拟机名字是 ``sles12-sp3`` ，你在使用时需要替换成对应的实际虚拟机名字

- 检查QEMU版本::

   virsh qemu-monitor-command sles12-sp3 --hmp "info version"

输出案例::

   5.2.0

- 检查网络状态::

   virsh qemu-monitor-command sles12-sp3 --hmp "info network"

输出案例::

   net0: index=0,type=nic,model=virtio-net-pci,macaddr=52:54:00:00:91:62
    \ hostnet0: index=0,type=tap,fd=32

- 检查字符设备::

   virsh qemu-monitor-command sles12-sp3 --hmp "info chardev"

输出案例::

   charchannel0: filename=disconnected:unix:/var/lib/libvirt/qemu/channel/target/domain-1-sles12-sp3/org.qemu.guest_agent.0,server
   charserial0: filename=pty:/dev/pts/1
   charmonitor: filename=unix:/var/lib/libvirt/qemu/domain-1-sles12-sp3/monitor.sock,server

- 检查块设备，例如硬盘，软盘或者CD-ROMs::

   virsh qemu-monitor-command sles12-sp3 --hmp "info block"

输出案例::

   libvirt-2-format: /var/lib/libvirt/images/sles12-sp3.qcow2 (qcow2)
       Attached to:      /machine/peripheral/virtio-disk0/virtio-backend
       Cache mode:       writeback, direct
   
   sata0-0-0: [not inserted]
       Attached to:      sata0-0-0
       Removable device: not locked, tray closed
   
   libvirt-3-format: /var/lib/libvirt/images/sles12_data.qcow2 (qcow2)
       Attached to:      /machine/peripheral/virtio-disk1/virtio-backend
       Cache mode:       writeback


- 显示CPU寄存器::

   virsh qemu-monitor-command sles12-sp3 --hmp "info registers"

- 显示可用的CPU信息::

   virsh qemu-monitor-command sles12-sp3 --hmp "info cpus"

输出案例::

   * CPU #0: thread_id=1220

- 显示中断状态::

   virsh qemu-monitor-command sles12-sp3 --hmp "info irq"

输出案例::

   IRQ statistics for kvm-i8259:
    1: 11
    4: 2
   12: 15
   IRQ statistics for kvm-ioapic:
    1: 11
    4: 2
   12: 15
   22: 177119

- 显示虚拟到物理内存映射::

   virsh qemu-monitor-command sles12-sp3 --hmp "info tlb"

- 显示numa::

   virsh qemu-monitor-command sles12-sp3 --hmp "info numa"

输出案例::

   0 nodes

获取Guest信息案例
-------------------

在 :ref:`kvm_vdisk_live` 我们需要向虚拟机插入磁盘。动态向虚拟机插入磁盘需要首先获知虚拟机当前存储设备情况，以便确定插入虚拟磁盘映射成哪个空闲的磁盘符号，例如 ``/dev/vdb`` 。

QMP - QEMU Machine Protocol
============================



参考
=====

- `31 Virtual Machine Administration Using QEMU Monitor <https://doc.opensuse.org/documentation/leap/virtualization/html/book-virt/cha-qemu-monitor.html>`_
