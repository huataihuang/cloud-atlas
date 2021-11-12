.. _ovmf:

=====================================
Open Virtual Machine Firmware(OMVF)
=====================================

Open Virtual Machine Firmware(OMVF)是在虚拟机内部激活UEFI支持的开源项目，从Linux 3.9和最新QEMU开始，可以将图形卡直通给虚拟机，提供VM原生图形性能，对图形性能敏感对任务非常有用。

准备工作
===========

显示直通(VGA passthrough)依赖很多比较少见的技术，并且有可能需要你的硬件支持才能实现。要完成直通，需要以下条件：

- CPU支持硬件虚拟化(kvm)和IOMMU(用于passthrough自身，即把cpu完整透传给虚拟机)

  - 兼容 `Intel VT-d技术的CPU列表 <https://ark.intel.com/content/www/us/en/ark/search/featurefilter.html?productType=873&0_VTD=True>`_
  - 所有从Bulldozer代开始的AMD处理器(包括zen)都兼容

- 主板支持IOMMU

  - 需要主板芯片和BIOS都支持IOMMU: 可以参考 `Wikipedia:List of IOMMU-supporting hardware <https://en.wikipedia.org/wiki/List_of_IOMMU-supporting_hardware>`_

- Guest虚拟机GPU ROM必须支持 ``UEFI``

  - 可以从 `techpowerup Video BIOS Collection <https://www.techpowerup.com/vgabios/>`_ 查询特定GPU是否支持UEFI。不过，从2012年开始所有GPU应该都支持UEFI，因为微软将UEFI作为兼容Windows 8的必要条件。

.. note::

   你需要有其他通道来观察系统，例如其他显卡或者带外管理，因为passthrough GPU会导致该GPU在物理主机上不可使用。

设置IOMMU
================

.. note::

   * IOMMU是Intel VT-d 和 AMD-Vi 的通用名称
   * ``VT-d`` 是Intel Virtualization Technology for Directed I/O ，所以不要和 ``VT-x`` Intel Virtualization Technology混淆。 ``VT-x`` 允许一个硬件平台功能表现为多个虚拟化平台，而 ``VT-d`` 则是为了提高安全和系统可靠性并且提升虚拟化环境的I/O设备性能。

使用 IOMMU 可以开启新功能，例如 PCI passthrough 和 内存保护。请参考 `Wikipedia:Input-output memory management unit#Advantages <https://en.wikipedia.org/wiki/Input-output_memory_management_unit#Advantages>`_ 和 `Memory Management (computer programming): Could you explain IOMMU in plain English? <https://www.quora.com/Memory-Management-computer-programming/Could-you-explain-IOMMU-in-plain-English>`_

激活IOMMU
-----------

AMD-Vi/Intel VT-d 是CPU内置支持，只需要通过BIOS设置激活。通常在BIOS中配置CPU功能部分可找到对应 ``Virtualization technology`` 之类配置。

在BIOS激活了 "VT-d" or "AMD-Vi" 之后，需要在内核参数中，根据CPU厂商不同配置内核参数:

- Intel CPU( ``VT-d`` )配置 ``intel_iommu=on``
- AMD CPU( ``AMD-Vi`` )通常内核检测到BIOS支持  ``IOMMU HW`` 就会激活，为确定激活可配置 ``iommu=pt iommu=1``

重启主机，然后检查 ``dmesg`` 确保IOMMU正确设置::

   dmesg | grep -i -e DMAR -e IOMMU

输出类似:

.. literalinclude:: ovmf/dmesg_dmar_iommu.txt
   :language: bash
   :linenos:
   :caption:

检查groups是否正确
----------------------

以下脚本 ``check_iommu.sh`` 脚本可以查看系统中不同的PCI设备被映射到IOMMU组，如果没有返回任何信息，则表明系统没有激活IOMMU支持或者硬件不支持IOMMU

.. literalinclude:: intel_vt-d_startup/check_iommu.sh
   :language: bash
   :linenos:
   :caption:

执行输出::

   ...
   IOMMU Group 32:
           00:1f.0 ISA bridge [0601]: Intel Corporation C610/X99 series chipset LPC Controller [8086:8d44] (rev 05)
           00:1f.2 SATA controller [0106]: Intel Corporation C610/X99 series chipset 6-Port SATA Controller [AHCI mode] [8086:8d02] (rev 05)
           00:1f.3 SMBus [0c05]: Intel Corporation C610/X99 series chipset SMBus Controller [8086:8d22] (rev 05)
   IOMMU Group 33:
           01:00.0 System peripheral [0880]: Hewlett-Packard Company Integrated Lights-Out Standard Slave Instrumentation & System Support [103c:3306] (rev 06)
           01:00.1 VGA compatible controller [0300]: Matrox Electronics Systems Ltd. MGA G200EH [102b:0533] (rev 01)
           01:00.2 System peripheral [0880]: Hewlett-Packard Company Integrated Lights-Out Standard Management Processor Support and Messaging [103c:3307] (rev 06)
           01:00.4 USB controller [0c03]: Hewlett-Packard Company Integrated Lights-Out Standard Virtual USB Controller [103c:3300] (rev 03)
   IOMMU Group 34:
           02:00.0 Ethernet controller [0200]: Broadcom Inc. and subsidiaries NetXtreme BCM5719 Gigabit Ethernet PCIe [14e4:1657] (rev 01)
           02:00.1 Ethernet controller [0200]: Broadcom Inc. and subsidiaries NetXtreme BCM5719 Gigabit Ethernet PCIe [14e4:1657] (rev 01)
           02:00.2 Ethernet controller [0200]: Broadcom Inc. and subsidiaries NetXtreme BCM5719 Gigabit Ethernet PCIe [14e4:1657] (rev 01)
           02:00.3 Ethernet controller [0200]: Broadcom Inc. and subsidiaries NetXtreme BCM5719 Gigabit Ethernet PCIe [14e4:1657] (rev 01)
   IOMMU Group 35:
           04:00.0 Ethernet controller [0200]: Intel Corporation I350 Gigabit Network Connection [8086:1521] (rev 01)
   IOMMU Group 36:
           04:00.1 Ethernet controller [0200]: Intel Corporation I350 Gigabit Network Connection [8086:1521] (rev 01)
   IOMMU Group 37:
           04:00.2 Ethernet controller [0200]: Intel Corporation I350 Gigabit Network Connection [8086:1521] (rev 01)
   IOMMU Group 38:
           04:00.3 Ethernet controller [0200]: Intel Corporation I350 Gigabit Network Connection [8086:1521] (rev 01)
   IOMMU Group 39:
           05:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   IOMMU Group 40:
           08:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   IOMMU Group 41:
           0b:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   ...
   IOMMU Group 79:
           82:00.0 3D controller [0302]: NVIDIA Corporation Device [10de:1b39] (rev a1)

上述输出中有不同的 ``IOMMU Group`` ，这个意义是:

- ``IOMMU Group`` 是直通给虚拟机的最小物理设备集合。举例，上述 ``IOMMU Group 32`` 这组设备只能完整分配给一个虚拟机，这个虚拟机将同时获得 ``ISA bridge [0601]`` ``SATA controller [0106]`` 和 ``SMBus [0c05]`` ；同理， ``IOMMU Group 34`` 包含了4个Broadcom 以太网接口(实际上就是主板集成4网口)也只能同时分配给一个虚拟机；而独立添加的Intel 4网口千兆网卡则是完全独立的4个 ``IOMMU Group`` ，意味着可以独立分配个4个虚拟机
- 我在 :ref:`hpe_dl360_gen9` 上通过 :ref:`pcie_bifurcation` 将PCIe 3.0 Slot 1(x16)划分成2个独立的x8通道，安装了2块 :ref:`samsung_pm9a1` ，加上在 Slot 2(x8) 上安装的第3块 :ref:`samsung_pm9a1` ，所以服务器上一共有3块 NVMe 存储。在这里可以看到有3个 ``IOMMU Group`` 分别是 ``39-40`` 对应了3个NVMe控制器，可以分别分配给3个虚拟机
- ``IOMMU Group 79`` 是安装在PCIe 3.0 Slot 3(x16)上的 :ref:`tesla_p10` GPU运算卡，可以直接透传给一个虚拟机。我仅做技术实践，最终我希望采用 :ref:`vgpu` 划分为更多GPU设备分配给虚拟化集群，来模拟大规模云计算

隔离GPU
=============

要实现将一个设备指定给虚拟机，这个设备以及所有在相同IOMMU组的设备必须将它们的驱动替换成 ``stub`` 驱动 或者 ``VFIO`` 驱动，这样才能避免物理主机访问设备。并且需要注意，大多数设备需要在VM启动前完成这个替换。

但是，GPU驱动往往不倾向于支持动态绑定，所以可能难以实现一些用于物理主机的GPU被透明直通给虚拟机，因为这样的两种驱动相互冲突。通常建议手工绑定这些驱动，然后再启动虚拟机。

从Linux内核4.1开始，内核包含了 ``vfio-pci`` ，这个VFIO驱动可以完全替代 ``pci-stub`` 而且提供了控制设备的扩展，例如在不使用设备时将设备切换到 ``D3`` 状态。

通过设备ID来绑定 ``vfio-pci``
--------------------------------

``vfio-pci`` 通常使用ID来找寻PCI设备，也就是只需要指定passthrough的设备ID。举例，前面显示的我的服务器上设备::

   IOMMU Group 39:
           05:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   IOMMU Group 79:
           82:00.0 3D controller [0302]: NVIDIA Corporation Device [10de:1b39] (rev a1)

只需要使用 ``144d:a80a`` 和 ``10de:1b39`` 这两个设备ID来绑定 ``vfio-pci``

有两种方式将设备 remove 或者 break :

- 使用启动内核参数::

   vfio-pci.ids=144d:a80a,10de:1b39

- 另一种方式是使用 modprobe 配置，添加一个 ``/etc/modprobe.d/vfio.conf`` ::

   options vfio-pci ids=144d:a80a,10de:1b39

提前加载 ``vfio-pci``
------------------------

.. note::

   我采用方法三 ``dracut`` ，另外两种方法未实践

   ``dracut`` 是一个制作 提前加载需要访问根文件系统的块设备模块(例如IDE，SCSI，RAID等) 初始化镜像 ``initramfs`` 工具。 ``mkinitcpio`` 是相同功能的工具。目前，大多数发行版，如Fedora, RHEL, Gentoo, Debian都使用 ``dracut`` ，不过 :ref:`arch_linux` 默认使用 ``mkinitcpio`` 。

.. note::

   参考 Red Hat Virtualization 文档，通过内核传递参数 ``pci-stub.ids=144d:a80a,10de:1b39 rdblacklist=nouveau`` 就可以阻止host主机使用GPU设备(并拒绝加载显卡驱动) ，然后只需要重新生成引导装载程序::

      grub2-mkconfig -o /etc/grub2.cfg

   然后重启系统就可以从 ``cat /proc/cmdline`` 确认主机设备被添加到 pci-stub.ids 列表中，Nouveau 已列入黑名单

mkinitcpio(方法一)
~~~~~~~~~~~~~~~~~~~~~

由于操作系统使用 ``vfio-pci`` 内核模块，需要确保 ``vfio-pci`` 模块提前加载，这样才能避免图形驱动绑定到这个GPU卡上。要实现这点，需要使用 ``mkinitcpio`` 帮助把 ``vfio_cpi`` 等相关内核模块加入到 ``initramfs`` 中

- 编辑 ``/etc/mkinitcpio.conf`` 配置文件::

   MODULES=(... vfio_pci vfio vfio_iommu_type1 vfio_virqfd ...)

并且确认 ``mkinitcpio.conf`` 已经包含了 ``modconf`` hook::

   HOOKS=(... modconf ...)

- 然后执行::

   mkinitcpio -P

booster(方法二)
~~~~~~~~~~~~~~~~~

- 编辑 ``/etc/booster.yaml`` ::

   modules_force_load: vfio_pci,vfio,vfio_iommu_type1,vfio_virqfd

- 重新生成initramfs::

   /usr/lib/booster/regenerate_images

dracut(方法三)
~~~~~~~~~~~~~~~~~

dracut的早期加载机制是通过内核参数。

- 要提前加载 ``vfio-pci`` ，在内核参数上添加设备ID以及 ``rd.driver.pre`` 配置::

   vfio-pci.ids=144d:a80a,10de:1b39 rd.driver.pre=vfio_pci

- 同样也需要将所有vfio驱动加入到initramfs，所以在 ``/etc/dracut.conf.d`` 目录下添加配置文件 ``10-vfio.conf`` ::

   add_drivers+=" vfio_pci vfio vfio_iommu_type1 vfio_virqfd "

- 为当前运行内核生成initramfs::

   dracut --hostonly --no-hostonly-cmdline /boot/initramfs-linux.img
   
验证是否实现提前加载 ``vfio-pci``
-----------------------------------

- 重启系统

- 检查 ``vfio-pci`` 是否正确加载，并且绑定到正确设备::

   dmesg | grep -i vfio



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
- `SETTING UP AN NVIDIA GPU FOR A VIRTUAL MACHINE IN RED HAT VIRTUALIZATION <https://access.redhat.com/documentation/en-us/red_hat_virtualization/4.4/html/setting_up_an_nvidia_gpu_for_a_virtual_machine_in_red_hat_virtualization/index>`_ 设置GPU的直通和vgpu，本文参考前半部分
