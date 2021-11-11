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
