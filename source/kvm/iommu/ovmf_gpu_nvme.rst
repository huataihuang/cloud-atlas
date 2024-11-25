.. _ovmf_gpu_nvme:

=====================================
采用OVMF实现passthrough GPU和NVMe存储
=====================================

.. note::

   本文实践在原先 :ref:`ovmf` 基础上完成，将去芜存菁完善操作步骤，详细整理如何将 :ref:`tesla_p10` passthrough给虚拟机（包括对参考文档的再次翻译整理），然后在虚拟机内部运行NVIDIA Container Runtime，以构建 :ref:`kubernetes` 的GPU节点。

   记录KVM虚拟化passthrough部分，其他容器相关技术实践另外撰文

Open Virtual Machine Firmware(OMVF)是在虚拟机内部激活UEFI支持的开源项目，从Linux 3.9和最新QEMU开始，可以将图形卡直通给虚拟机，提供VM原生图形性能，对图形性能敏感对任务非常有用。通过将物理主机独立的GPU直接passthrough给虚拟机，可以使得虚拟机图形性能接近于原生物理主机。在YouTube上，你可以找到很多GPU
passthrough方式在Linux上运行Windows虚拟机中的游戏，获得非常好的体验的介绍视频。

准备工作
===========

显示直通(VGA passthrough)依赖很多比较少见的技术，并且有可能需要你的硬件支持才能实现。要完成直通，需要以下条件：

- CPU支持硬件虚拟化(kvm)和IOMMU(用于passthrough自身，即把cpu完整透传给虚拟机)

  - 兼容 `Intel VT-d技术的CPU列表 <https://ark.intel.com/content/www/us/en/ark/search/featurefilter.html?productType=873&0_VTD=True>`_
  - 所有从Bulldozer代开始的AMD处理器(包括zen)都兼容

- 主板支持IOMMU

  - 需要主板芯片和BIOS都支持IOMMU: 可以参考 `Wikipedia:List of IOMMU-supporting hardware <https://en.wikipedia.org/wiki/List_of_IOMMU-supporting_hardware>`_

- Guest虚拟机GPU ROM必须支持 ``UEFI`` (也就是本文 ``OVMF`` 虚拟机)

  - 可以从 `techpowerup Video BIOS Collection <https://www.techpowerup.com/vgabios/>`_ 查询特定GPU是否支持UEFI。不过，从2012年开始所有GPU应该都支持UEFI，因为微软将UEFI作为兼容Windows 8的必要条件。

.. note::

   你需要有其他通道来观察系统，例如其他显卡或者带外管理，因为passthrough GPU会导致该GPU在物理主机上不可使用:

   - 需要一个备用显示器或支持连接到多个GPU的多输入端口的显示器:  **如果没有连接屏幕，GPU passthrough不会显示任何内容，并且使用VNC或Spice对于性能没有任何帮助**

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

重启主机，然后检查 ``dmesg`` 确保IOMMU正确设置:

.. literalinclude:: ovmf_gpu_nvme/check_iommu_dmesg
   :language: bash
   :caption: 通过dmesg检查IOMMU是否激活

输出类似:

.. literalinclude:: ovmf_gpu_nvme/dmesg_dmar_iommu.txt
   :language: bash
   :caption: 激活IOMMU之后系统启动信息 "DMAR: IOMMU enabled" 表明IOMMU已经激活
   :emphasize-lines: 5

检查groups是否正确
----------------------

以下脚本 ``check_iommu.sh`` 脚本可以查看系统中不同的PCI设备被映射到IOMMU组，如果没有返回任何信息，则表明系统没有激活IOMMU支持或者硬件不支持IOMMU

.. literalinclude:: ovmf_gpu_nvme/check_iommu.sh
   :language: bash
   :caption: 检查PCI设备映射到IOMMU组

执行输出:

.. literalinclude:: ovmf_gpu_nvme/check_iommu_output
   :language: bash
   :caption: 检查PCI设备映射到IOMMU组的输出信息,可以看到GPU信息
   :emphasize-lines: 31-32

上述输出中有不同的 ``IOMMU Group`` ，这个意义是:

- ``IOMMU Group`` 是直通给虚拟机的最小物理设备集合。举例，上述 ``IOMMU Group 32`` 这组设备只能完整分配给一个虚拟机，这个虚拟机将同时获得 ``ISA bridge [0601]`` ``SATA controller [0106]`` 和 ``SMBus [0c05]`` ；同理， ``IOMMU Group 34`` 包含了4个Broadcom 以太网接口(实际上就是主板集成4网口)也只能同时分配给一个虚拟机；而独立添加的Intel 4网口千兆网卡则是完全独立的4个 ``IOMMU Group`` ，意味着可以独立分配个4个虚拟机
- 我在 :ref:`hpe_dl360_gen9` 上通过 :ref:`pcie_bifurcation` 将PCIe 3.0 Slot 1(x16)划分成2个独立的x8通道，安装了2块 :ref:`samsung_pm9a1` ，加上在 Slot 2(x8) 上安装的第3块 :ref:`samsung_pm9a1` ，所以服务器上一共有3块 NVMe 存储。在这里可以看到有3个 ``IOMMU Group`` 分别是 ``39-40`` 对应了3个NVMe控制器，可以分别分配给3个虚拟机
- ``IOMMU Group 79`` 是安装在PCIe 3.0 Slot 3(x16)上的 :ref:`tesla_p10` ，可以直接透传给一个虚拟机。 :strike:`最终我希望采用 vgpu 划分为更多GPU设备分配给虚拟化集群，来模拟大规模云计算` (由于 :ref:`vgpu` 需要license，放弃)

.. warning::

   并非所有PCI-E插槽都相同。大多数主板都有CPU和PCH提供的PCIe插槽。但是，基于CPU的PCIe插槽可能无法正确支持隔离，此时PCI插槽似乎与连接到它的设备组合在一起，类似::

      OMMU Group 1:
      	 00:01.0 PCI bridge: Intel Corporation Xeon E3-1200 v2/3rd Gen Core processor PCI Express Root Port (rev 09)
      	 01:00.0 VGA compatible controller: NVIDIA Corporation GM107 [GeForce GTX 750] (rev a2)
      	 01:00.1 Audio device: NVIDIA Corporation Device 0fbc (rev a1) 

   此时会强迫直通多个设备给相同的虚拟机

   解决的方法是尝试将GPU插入其他PCIe插槽，看看是否提供与其他插槽的隔离。或者安装SCS覆盖补丁(有缺点)

隔离GPU
=============

要实现将一个设备指定给虚拟机，这个设备以及所有在相同IOMMU组的设备必须将它们的驱动替换成 ``stub`` 驱动 或者 ``VFIO`` 驱动，这样才能避免物理主机访问设备。对于大多数设备，可以在虚拟机启动前动态配置。

但是，GPU驱动往往不倾向于支持动态绑定(过于复杂)，所以可能难以实现一些用于物理主机的GPU透明直通给虚拟机，因为这样的两种驱动相互冲突。通常建议手工绑定这些驱动，然后再启动虚拟机。也就是说，应该在host物理主机引导过程中，尽早绑定这些占位符驱动程序，此时设备处于非活动状态，直到虚拟机声明设备或者设备驱动程序切回。这种首选方法比系统完全联机后切换驱动程序要好，可以避免问题。

.. warning::

   当配置了IOMMU并且隔离了GPU之后，这个被隔离的GPU将不能被物理主机使用。一定要确保物理主机有其他GPU可以使用，否则一旦隔离唯一的GPU会导致物理主机无显示输出。

   通常采用的方式是只隔离插在PCIe插槽上的独立GPU卡，而保留服务器主板内置的板载显卡给物理主机使用。

从Linux内核4.1开始，内核包含了 ``vfio-pci`` ，这个VFIO驱动可以完全替代 ``pci-stub`` 而且提供了控制设备的扩展，例如在不使用设备时将设备切换到 ``D3`` 状态。

.. _vfio-pci.ids:

通过设备ID来绑定 ``vfio-pci``
================================

``vfio-pci`` 通常使用ID来找寻PCI设备，也就是只需要指定passthrough的设备ID。举例，前面显示的我的服务器上设备::

   IOMMU Group 39:
           05:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   IOMMU Group 79:
           82:00.0 3D controller [0302]: NVIDIA Corporation Device [10de:1b39] (rev a1)

只需要使用 ``144d:a80a`` 和 ``10de:1b39`` 这两个设备ID来绑定 ``vfio-pci`` ，这样就能够将 :ref:`nvme` 设备和 :ref:`tesla_p10` 设备passthrough给不同的虚拟机来构建高性能存储和GPU:

- 上述 :ref:`nvme` 设备passthrough给3个虚拟机来构建 :ref:`zdata_ceph`
- 上述 :ref:`tesla_p10` 设备passthrough给虚拟机来构建基于GPU的容器实现 :ref:`machine_learning` 的 :ref:`kubernetes` 工作节点

.. note::

   要同时输出设备ID和 ``vfio-pci`` 绑定ID，可以使用 ``lspci -nn`` 命令，可以显示详细信息:

   .. literalinclude:: ovmf_gpu_nvme/lspci_nn
      :caption: ``lspci -nn`` 命令检查设备ID和 ``vfio-pci`` 绑定ID

   就可以看到详细信息:

   .. literalinclude:: ovmf_gpu_nvme/lspci_nn_output
      :caption: ``lspci -nn`` 命令看到 :ref:`samsung_pm9a1` 的 ``vfio-pci`` 绑定ID

   可以直接知道内核需要传递的 ``vfio-pci.ids`` 就是 ``144d:a80a`` ，同时也能够知道如何配置设备 ``.xml`` 文件用于 ``virsh attach-device``

有两种方式将设备 remove 或者 break :

- 使用启动内核参数(我的实践即采用此方法，见下文)::

   vfio-pci.ids=144d:a80a,10de:1b39

- 另一种方式是使用 modprobe 配置，添加一个 ``/etc/modprobe.d/vfio.conf`` ::

   options vfio-pci ids=144d:a80a,10de:1b39

提前加载 ``vfio-pci`` (模块方式,未实践)
===========================================

需要分辨 ``vfio-pci`` 是作为内核直接编译的还是作为内核模块加载的:

- 如果是直接静态编译到内核，则只需要内核启动参数中传递参数阻止host主机使用PCI设备: 如 Red Hat Enterprise Linux 和 Ubuntu 都是直接内核静态编译 ``vfio``
- 如果是内核模块加载 ``vfio-pci`` 则还需要重建 ``initramfs`` 确保提前加载模块: 如 arch linux就是模块方式加载 ``vfio-pci`` 等模块

检查方法是查看 ``/boot`` 目录下对应内核版本 ``config-xxx-xxx`` 配置，例如 Ubuntu 20.04.3 LTS 当前使用内核 使用 ``uname -r`` 查看是 ``5.4.0-90-generic`` ，则检查 ``/boot/config-5.4.0-90-generic`` 文件，可以看到各个 ``vfio`` 相关模块都是静态编译(对应值都是 ``Y`` )::

   CONFIG_VFIO_IOMMU_TYPE1=y
   CONFIG_VFIO_VIRQFD=y
   CONFIG_VFIO=y
   CONFIG_VFIO_NOIOMMU=y
   CONFIG_VFIO_PCI=y
   CONFIG_VFIO_PCI_VGA=y
   CONFIG_VFIO_PCI_MMAP=y
   CONFIG_VFIO_PCI_INTX=y
   CONFIG_VFIO_PCI_IGD=y

.. note::

   参考 Red Hat Virtualization 文档，通过内核传递参数 ``pci-stub.ids=144d:a80a,10de:1b39 rdblacklist=nouveau`` 就可以阻止host主机使用GPU设备(并拒绝加载显卡驱动) ，然后只需要重新生成引导装载程序::

      grub2-mkconfig -o /etc/grub2.cfg

   然后重启系统就可以从 ``cat /proc/cmdline`` 确认主机设备被添加到 pci-stub.ids 列表中，Nouveau 已列入黑名单

对于内核模块方式加载 ``VFIO`` 相关模块(arch linux就是如此)，则采用以下3个方法之一来定制 ``intiramfs`` 确保内核首先加载 VFIO 模块，这样才能屏蔽掉host主机使用需要分配给虚拟机的PCI设备:

.. note::

   ``dracut`` 是一个制作 提前加载需要访问根文件系统的块设备模块(例如IDE，SCSI，RAID等) 初始化镜像 ``initramfs`` 工具。 ``mkinitcpio`` 是相同功能的工具。目前，大多数发行版，如Fedora, RHEL, Gentoo, Debian都使用 ``dracut`` ，不过 :ref:`arch_linux` 默认使用 ``mkinitcpio`` 。

   由于我的实践是在Ubuntu上完成， ``VFIO`` 相关支持都是直接静态编译进内核，所以并不需要执行以下内核模块加入 ``initiramfs`` 的需求， **我并没有执行以下3个方法的任意一个** 。不过，对于arch linux需要执行。

mkinitcpio(方法一)
---------------------

由于操作系统使用 ``vfio-pci`` 内核模块，需要确保 ``vfio-pci`` 模块提前加载，这样才能避免图形驱动绑定到这个GPU卡上。要实现这点，需要使用 ``mkinitcpio`` 帮助把 ``vfio_cpi`` 等相关内核模块加入到 ``initramfs`` 中

- 编辑 ``/etc/mkinitcpio.conf`` 配置文件::

   MODULES=(... vfio_pci vfio vfio_iommu_type1 vfio_virqfd ...)

并且确认 ``mkinitcpio.conf`` 已经包含了 ``modconf`` hook::

   HOOKS=(... modconf ...)

- 然后执行::

   mkinitcpio -P

booster(方法二)
------------------

- 编辑 ``/etc/booster.yaml`` ::

   modules_force_load: vfio_pci,vfio,vfio_iommu_type1,vfio_virqfd

- 重新生成initramfs::

   /usr/lib/booster/regenerate_images

dracut(方法三)
------------------

dracut的早期加载机制是通过内核参数。

- 要提前加载 ``vfio-pci`` ，在内核参数上添加设备ID以及 ``rd.driver.pre`` 配置::

   vfio-pci.ids=144d:a80a,10de:1b39 rd.driver.pre=vfio_pci

- 同样也需要将所有vfio驱动加入到initramfs，所以在 ``/etc/dracut.conf.d`` 目录下添加配置文件 ``10-vfio.conf`` ::

   add_drivers+=" vfio_pci vfio vfio_iommu_type1 vfio_virqfd "

- 为当前运行内核生成initramfs::

   dracut --hostonly --no-hostonly-cmdline /boot/initramfs-linux.img

我的屏蔽host pcie实践
========================

**这段是我实际操作实践**

验证是否实现提前加载 ``vfio-pci``
-----------------------------------

在没有配置 ``vfio-pci.ids`` 隔离之前，按照以下方法先检查系统

- 检查 ``vfio-pci`` 是否正确加载，并且绑定到正确设备::

   dmesg | grep -i vfio

我的实践看到输出内容是::

   [    1.434041 ] VFIO - User Level meta-driver version: 0.3

此时看不到 ``vfio`` 相关设备

- 在host主机上检查设备:

.. literalinclude:: ovmf_gpu_nvme/lspci_nvme
   :language: bash
   :caption: lspci检查nvme设备驱动

可以看到当前 :ref:`nvme` 使用的驱动是设备驱动 ``nvme`` 而不是 ``vfio-pci`` ，也就是表明设备尚未从物理host主机隔离:

.. literalinclude:: ovmf_gpu_nvme/lspci_nvme_without_isolate
   :language: bash
   :caption: lspci检查尚未隔离的nvme设备显示使用了nvme设备驱动
   :emphasize-lines: 3,7,11

检查GPU设备也是如此:

.. literalinclude:: ovmf_gpu_nvme/lspci_gpu
   :language: bash
   :caption: lspci检查NVIDIA GPU设备驱动

输出也显示NVIDIA GPU尚未隔离，即当前使用的是NVIDIA设备驱动 ``nouveau`` 而不是 ``vfio-pci`` :

.. literalinclude:: ovmf_gpu_nvme/lspci_gpu_without_isolate
   :language: bash
   :caption: lspci检查尚未隔离的NVIDIA GPU设备显示使用了NVIDIA开源设备驱动nouveau
   :emphasize-lines: 3

- 修订 ``/etc/default/grub`` 添加 ``vfio-pci.ids`` 配置将设备从物理host主机隔离(准备用于虚拟机):

.. literalinclude:: ovmf_gpu_nvme/grub_vfio-pci.ids
   :language: bash
   :caption: 配置/etc/default/grub加载vfio-pci.ids来隔离PCI直通设备

我在早期 :ref:`ovmf` 实践中尝试过 ``pci-stub.ids`` ，配置 ``/etc/default/grub`` 如下(实践证明现在已经无效了):

.. literalinclude:: ovmf_gpu_nvme/grub_vfio-stub.ids
   :language: bash
   :caption: 配置/etc/default/grub加载vfio-stub.ids来隔离PCI直通设备，该方法已废弃

实践发现现在 ``pci-stub.ids`` 不能隔离PCI设备，这个配置重启后可以看到Host主机依然能够发现设备并加载了设备驱动，而不是使用 ``vfio-pci`` 驱动(没有隔离)

.. note::

   后续我实践 :ref:`config_sr-iov_network` ，还增加一个 ``iommu=pt`` 参数，以提高 SR-IOV pass-through 性能。

   :ref:`nvidia_pci_passthrough_via_ovmf_pci_realloc` 否则虚拟机内部无法初始化设备

.. warning::

   如果要在物理主机上 :ref:`install_nvidia_linux_driver` ，则必须重新修订上述 ``vfio-pci.ids`` 参数，去除掉 ``10de:1b39`` ，也就是修改为::

      GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on vfio-pci.ids=144d:a80a"

   否则会出现非常奇怪的报错::

      NVRM: The NVIDIA probe routine was not called for 1 device(s).
      ...
      NVRM: No NVIDIA devices probed.

- 重新生成grub::

   sudo update-grub

- 重启系统，并检查 ``dmesg | grep -i vfio`` 输出，可以看到 ``vfio_pci`` 正确绑定了指定PCIe设备:

.. literalinclude:: ovmf_gpu_nvme/dmesg_vfio-pci.ids
   :language: bash
   :caption: 通过内核参数vfio-pci.ids隔离设备之后，重启系统后dmesg显示vfio_pci设备就是被隔离的PCI设备
   :emphasize-lines: 4,5

- 此时根据设备ID检查PCIe设备，可以看到已经被 ``vfio-pci`` 驱动:

.. literalinclude:: ovmf_gpu_nvme/lspci_nvme
   :language: bash
   :caption: lspci检查nvme设备驱动

显示:

.. literalinclude:: ovmf_gpu_nvme/lspci_nvme_with_isolate
   :language: bash
   :caption: lspci检查已经隔离的nvme设备，可以看到当前驱动是vfio-pci，表明NVMe设备已经正确分离
   :emphasize-lines: 3,7,11

.. note::

   请注意， ``vfio-pci.ids=144d:a80a`` 是对同一种类设备进行屏蔽，所有在这个服务器上安装的 :ref:`samsung_pm9a1` 都是相同的设备ID，也就是会同时被屏蔽掉。目前看，不能单独只屏蔽一块NVMe存储，因为都是相同的三星NVMe，会一起被 ``vfio-pci`` 接管。可以看到上面 ``lspci -nnk -d 144d:a80a`` 显示3块三星NVMe。

检查GPU:

.. literalinclude:: ovmf_gpu_nvme/lspci_gpu
   :language: bash
   :caption: lspci检查NVIDIA GPU设备驱动

同样显示NVIDIA GPU也已经正确分离，当前使用的驱动已经是 ``vfio-pci`` :

.. literalinclude:: ovmf_gpu_nvme/lspci_gpu_with_isolate
   :language: bash
   :caption: lspci检查隔离成功的NVIDIA GPU设备，可以看到当前驱动是vfio-pci
   :emphasize-lines: 3

**现在已经完成了NVMe和GPU的物理主机隔离，意味着已经可以将这些PCI设备passthrough给虚拟机使用**

设置OVMF guest VM
====================

OVMF是开源UEFI firmware，用于QEMU虚拟机。

配置libvirt
-------------

:ref:`libvirt` 是一系列虚拟化工具包装，可以大幅简化配置和部署过程。在KVM和QEMU案例中，使用libvirt可以避免我们处理QEMU权限并容易添加和移除虚拟机设备。不过，由于libvirt是包装器，所以也有部分qemu功能不能支持，需要使用定制脚本来提供QEMU的扩展参数。

.. note::

   arch linux 文档 `arch linux: PCI passthrough via OVMF <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF>`_ 只介绍了使用图形化工具 ``virt-manager`` 设置 UEFI 虚拟机。不过，可以从 Red Hat Enterprise Linux 虚拟化文档以及SUSE虚拟化文档提供了命令行方式操作。我的实践以命令行为主。

virt-install
--------------

- 在 ``virt-install`` 命令添加 ``--boot uefi`` 和 ``--cpu host-passthrough`` 参数安装操作系统。注意，虚拟机系统磁盘采用 :ref:`libvirt_lvm_pool` ，所以首先创建LVM卷，然后使用LVM卷作为存储创建ovmf虚拟机:

Fedora35虚拟机
~~~~~~~~~~~~~~~

.. literalinclude:: ovmf_gpu_nvme/create_ovmf_fedora35_vm_on_libvirt_lvm_pool
   :language: bash
   :caption: 在Libvirt的LVM存储上创建Fedora 35 ovmf虚拟机(iommu)

Fedora Workstation版本只能从iso安装

安装注意点:

- 安装过程启用VNC使用图形界面安装，这样可以选择文件系统分区等高级配置，方便安装
- ``vda`` 需要分配一个独立UEFI分区挂载为 ``/boot/efi`` ，这个分区不需指定文件系统类型，系统会自动选择 ``vfat`` 类型，我分配了 256MB；其余磁盘全部分配给 ``/`` ，设置为 ``xfs`` 文件系统::

   Filesystem      Size  Used Avail Use% Mounted on
   devtmpfs        964M     0  964M   0% /dev
   tmpfs           983M     0  983M   0% /dev/shm
   tmpfs           393M  952K  392M   1% /run
   /dev/vda2       5.8G  1.8G  4.0G  31% /
   tmpfs           983M  4.0K  983M   1% /tmp
   /dev/vda1       256M  6.1M  250M   3% /boot/efi
   tmpfs           197M     0  197M   0% /run/user/0

- 安装完成后，重启系统，继续可以通过控制台维护，首次启动后就可以通过 ``dnf upgrade`` 更新系统
- 按照 :ref:`priv_cloud_infra` 规划配置主机IP，然后clone出测试服务器 ( :ref:`libvirt_lvm_pool` )::

   virt-clone --original z-fedora35 --name z-iommu --auto-clone

- clone之后，对容器内部进行配置修订: Fedora Server使用 :ref:`networkmanager` 管理网络，所以通过以下命令修订静态IP地址和主机名::

   nmcli general hostname z-iommu
   nmcli connection modify "enp1s0" ipv4.method manual ipv4.address 192.168.6.242/24 ipv4.gateway 192.168.6.200 ipv4.dns "192.168.6.200,192.168.6.11"

Ubuntu 20.04虚拟机
~~~~~~~~~~~~~~~~~~~~

.. literalinclude:: ovmf_gpu_nvme/create_ovmf_ubuntu20_vm_on_libvirt_lvm_pool
   :language: bash
   :caption: 在Libvirt的LVM存储上创建Ubuntu 20.04 ovmf虚拟机(iommu)

.. note::

   这里直接使用了 :ref:`libvirt_bridged_network` 中配置的 ``br0`` ，是因为Ubuntu在安装过程中可以设置代理服务器，而我已经采用 :ref:`apt_proxy_arch` 部署了 :ref:`squid` 作为代理

.. note::

   一定要使用 ``--boot uefi --cpu host-passthrough`` 参数激活 :ref:`ovmf` ，否则虽然能够 ``pass-through`` PCIe设备给虚拟机，但是虚拟机无法使用完整的物理主机CPU特性，而是使用虚拟出来的CPU，性能会损失。

正确实现 ``--boot uefi --cpu host-passthrough`` 后，在虚拟机内部有以下2个特征:

  - CPU显示和物理服务器一致::

     cat /proc/cpuinfo

可以看到::

   ...
   model name: Intel(R) Xeon(R) CPU E5-2670 v3 @ 2.30GHz

  - ``/boot/efi`` 目录独立分区，且存储了 ``EFI`` 相关配置和数据

虚拟机添加设备
---------------------

设备xml配置文件
~~~~~~~~~~~~~~~~~

我们前面已经通过 ``check_iommu.sh`` 脚本找出了需要指派给虚拟机的PCIe设备::

   IOMMU Group 39:
           05:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   IOMMU Group 79:
           82:00.0 3D controller [0302]: NVIDIA Corporation Device [10de:1b39] (rev a1)

并通过内核启动参数 ``vfio-pci.ids=144d:a80a,10de:1b39`` 屏蔽了HOST物理主机使用这两个设备，现在我们可以将这两个设备attach到虚拟机。

- 使用 ``lspci`` 命令可以检查设备的16进制完整id:

.. literalinclude:: ovmf_gpu_nvme/lspci_get_nvme_gpu_id
   :language: bash
   :caption: lspci过滤获得三星nvme和NVIDIA GPU的设备id

获得nvme和gpu的设备显示如下:

.. literalinclude:: ovmf_gpu_nvme/lspci_get_nvme_gpu_id_output
   :language: bash
   :caption: lspci过滤获得三星nvme和NVIDIA GPU的设备id(第一列)

- 第一列就是设备十六进制的ID，可以直接用来配置设备的 ``.xml`` 文件，3个数字字段分别对应了 ``bus= slot= function=`` 举例第三个NVMe设备 ``0b:00.0`` 对应配置 ``samsung_pm9a1_1.xml`` :

.. literalinclude:: ovmf_gpu_nvme/samsung_pm9a1_1.xml
   :language: xml
   :caption: Samsung PM9A1 #1

- 而GPU设备则对应配置 ``tesla_p10.xml`` :

.. literalinclude:: ovmf_gpu_nvme/tesla_p10.xml
   :language: xml
   :caption: NVIDIA Tesla P10

添加NVMe设备
~~~~~~~~~~~~~

- 执行以下命令将第一个NVMe Samsung PM9A1 添加到虚拟机 ``z-iommu`` 上::

   virsh attach-device z-iommu samsung_pm9a1_1.xml
   
此时在物理主机上提示信息::

   Device attached successfully

在虚拟机 ``z-iommu`` 终端控制台可以看到信息:

.. literalinclude:: ovmf/samsung_pm9a1_1.txt
   :language: xml
   :linenos:
   :caption: Samsung PM9A1 #1

此时在虚拟机 ``z-iommmu`` 中检查磁盘::

   fdisk -l

可以看到::

   Disk /dev/nvme0n1: 953.87 GiB, 1024209543168 bytes, 2000409264 sectors
   Disk model: SAMSUNG MZVL21T0HCLR-00B00              
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes

.. note::

   这种live方式添加nvme磁盘所在的pci设备可以立即使用存储，无需重启虚拟机。但是虚拟机重启后，该磁盘未自动添加。所以我后来还是采用 ``--config`` 参数运行 ``virsh attach-device`` ，然后重启虚拟机。重启以后可以保持使用NVMe设备::

      virsh attach-device z-iommu samsung_pm9a1_1.xml --config 

- 删除设备是反向操作::

   virsh detach-device z-iommu samsung_pm9a1_1.xml --config 

添加GPU设备
~~~~~~~~~~~~~

.. note::

   在 :ref:`priv_cloud_infra` 构建的 :ref:`z-k8s` ，将GPU passthrough到第一个虚拟机中，以备作为后续GPU节点运行

- 执行以下命令将NVIDIA Tesla P10 GPU运算卡 添加到虚拟机 ``z-k8s-n-1`` 上:

.. literalinclude:: ovmf_gpu_nvme/virsh_attach_gpu
   :language: bash
   :caption: virsh attach-device 添加GPU(vm停机状态)，然后启动虚拟机

如果没有使用 ``--config`` 参数可能会出现如下报错::

   error: Failed to attach device from tesla_p10.xml
   error: internal error: No more available PCI slots

这个问题在 `libvirtd: No more available PCI slots <https://unix.stackexchange.com/questions/570166/libvirtd-no-more-available-pci-slots>`_ 提到了解决方法: 添加一个 ``--config`` 参数，让libvirt来自动添加需要的 ``pcie-root-port`` 配置。注意， ``--config`` 参数需要虚拟机在关闭状态才能执行

- 重启完虚拟机，登录虚拟机中执行:

.. literalinclude:: ovmf_gpu_nvme/lspci_gpu_in_vm
   :language: bash
   :caption: 在虚拟机内部执行lspci查看nvidia gpu

可以看到GPU设备:

.. literalinclude:: ovmf_gpu_nvme/lspci_gpu_in_vm_output
   :language: bash
   :caption: 在虚拟机内部执行lspci查看nvidia gpu，可以看到Tesla P10设备已passthrough进虚拟机

.. note::

   注意，上述步骤仅完成了GPU passthrough到VM内部，实际上要完成 :ref:`install_nvidia_linux_driver_in_ovmf_vm` 才能真正在虚拟机内使用NVIDIA GPU

- :ref:`install_nvidia_linux_driver_in_ovmf_vm`
- 部署 :ref:`gpu_k8s_arch` 实现GPU加速的 :ref:`machine_learning`

Windows OVMF虚拟机安装
=========================

.. note::

   本段我尚未实践，目前暂未有 :ref:`windows` 实践机会，不过考虑到Windows的广泛使用，我在后续实践中会采用混合部署Linux+Windows，学习Windows体系。目前这段仅记录供后续参考 `Virtualizing Windows 7 (or Linux) on a NVMe drive with VFIO <https://frdmtoplay.com/virtualizing-windows-7-or-linux-on-a-nvme-drive-with-vfio/>`_

在YouTube上，有很多技术爱好者展示了通过Windows虚拟机玩游戏的，主要的思路就是通过VFIO实现显卡和存储pass-through，既是炫技也是玩乐。我的思路是后续在 :ref:`priv_cloud_infra` 融入部署完整的Windows Active Directory Domain，构建一个企业级网络。

- Intel的UEFI实现称为 ``tianocore`` ，在qeumu支持 ``tianocore`` 的发行包就是 ``ovmf`` ，所以同样我们需要在物理主机上安装 ``ovmf`` ::

   apt install ovmf

- 构建驱动ISO

Windows安装国晨够可以选择磁盘驱动，由于我们是在虚拟机中安装Windows，所以只需要安装过程中在VM添加包含驱动的ISO文件挂载就可以。Fedora提供了 `virto 驱动镜像 <https://fedoraproject.org/wiki/Windows_Virtio_Drivers>`_ ，下载后将内容复制出来::

   # mkdir /mnt/loop
   # mount /path/to/virtio.iso -o loop /mnt/loop
   $ cp -r /mnt/loop/* /home/user/virtio

- 三星NVMe驱动:

三星官方提供了NVMe驱动(可执行文件，待后续实践，应该是压缩包可以用来提取实际驱动文件)，后续实践可以尝试将驱动文件提取出来::

   secnvme.cat
   secnvme.inf
   secnvme.sys
   secnvmeF.sys

复制到 ``/home/user/virtio/samsung``

- 在复制了需要的驱动文件到 ``virtio/`` 目录之后，可以将这个目录重建成iso文件::

   geniso -o virtio.iso virtio/

- 然后参考 :ref:`create_vm` 创建虚拟机，注意需要启用 ``uefi`` 

其他内容待后续实践

下一步
=========

现在上述两个PCIe设备已经属于虚拟机独占使用，和常规的设备使用一致，接下来就是:

- :ref:`install_cuda_ubuntu` - 对于pass-through的gpu设备，在虚拟机内部如同物理主机一样，需要安装GPU驱动以及CUDA环境
- :ref:`compare_iommu_native_nvme` - 在虚拟机内部和物理主机上，分别对NVMe测试存储性能

参考
======

- `Open Virtual Machine Firmware (OVMF) Status Report <http://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt>`_
- `arch linux: PCI passthrough via OVMF <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF>`_
- `arch linux: libvirt <https://wiki.archlinux.org/title/libvirt>`_
- `Using UEFI with QEMU <https://fedoraproject.org/wiki/Using_UEFI_with_QEMU>`_
- `ubuntu wiki: OVMF <https://wiki.ubuntu.com/UEFI/OVMF>`_ 如果要自制OVMF镜像，可以参考 `ubuntu wiki: EDK2 <https://wiki.ubuntu.com/UEFI/EDK2>`_
- `Virtualizing Windows 7 (or Linux) on a NVMe drive with VFIO <https://frdmtoplay.com/virtualizing-windows-7-or-linux-on-a-nvme-drive-with-vfio/>`_
- `SETTING UP AN NVIDIA GPU FOR A VIRTUAL MACHINE IN RED HAT VIRTUALIZATION <https://access.redhat.com/documentation/en-us/red_hat_virtualization/4.4/html/setting_up_an_nvidia_gpu_for_a_virtual_machine_in_red_hat_virtualization/index>`_ 设置GPU的直通和vgpu，本文参考前半部分
- `Enabling PCI pass-through in guest <https://developer.ibm.com/tutorials/enabling-pci-pass-through-using-libvirt/>`_ 这篇blog提供了添加pci设备的xml案例，可以直接使用virsh命令动态添加设备
- `Attaching and updating a device with virsh <https://docs.fedoraproject.org/en-US/Fedora/18/html/Virtualization_Administration_Guide/sect-Attaching_and_updating_a_device_with_virsh.html>`_ Fedora文档，提供xml案例添加CDROM设备
- `Virtualizing Windows 7 (or Linux) on a NVMe drive with VFIO <https://frdmtoplay.com/virtualizing-windows-7-or-linux-on-a-nvme-drive-with-vfio/>`_ 安装Windows VFIO可以实现接近原生的性能
