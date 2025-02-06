.. _run_debian_gpu_passthrough_in_qemu:

=======================================
在QEMU中运行GPU passthrough的Debian
=======================================

.. note::

   本文实践是在 :ref:`blfs_qemu` 基础上完成:

   - 由于是完全手搓操作系统，所以部分配置会采用比较"原始"的命令行完成，例如内核参数采用直接修订 ``/boot/grub/grub.cfg`` 而不是类似 :ref:`ubuntu_linux` 修订 ``/etc/default/grub``
   - 已经完成 :ref:`run_debian_in_qemu` 实践，本文在此基础上激活 :ref:`iommu` 通过 :ref:`ovmf` 来实现GPU passthrough，部分实践参考之前经验 :ref:`ovmf_gpu_nvme` 。

**GPU passthrough** 是在虚拟机中允许Linux内核直接访问Host主机的PCI GPU技术。此时GPU设备就好像直接由VM驱动，而VM将PCI设备视为它自己的物理连接模式。GPU passthrough 也称为 :ref:`iommu` ，虽然并不完全正确，因为IOMMU实际上是一种硬件技术，不仅能够提供GPU passthrough，而且还能提供其他功能，例如对DMA攻击的某些保护或者使用32位地址寻址64位内存空间的能力。

``GPU passthrough`` 最常见的应用是游戏，因为GPU passthrough是的虚拟机直接访问图形卡，因而游戏能够获得像直接运行在裸金属主机运行操作系统的性能。

BIOS和UEFI firmware
=========================

在设置GPU passthrough之前，首先需要确保处理器支持Intel VT-x 或AMD-V技术，这种技术是允许多个操作系统在处理器上同时执行的(虚拟机)技术。

- 执行以下命令检查CPU的虚拟化硬件支持:

.. literalinclude:: ../../linux/gentoo_linux/gentoo_virtualization/grep_cpuinfo
   :caption: 检查硬件虚拟化支持

- 在服务器主机的BIOS设置中启用 ``VT-d`` 和 ``IOMMU`` 支持

IOMMU内核配置
==============

- :ref:`iommu_infra` <= **原理**
- IOMMU内核配置采用 :ref:`gentoo_virtualization` 建议的内核配置并做了一点调整:

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/kernel
   :caption: 内核激活IOMMU支持

.. note::

   `Deep dive into virtio-iommu <https://michael2012z.medium.com/deep-dive-into-virtio-iommu-6e03df40c3e6>`_ 介绍了 virtio-iommu 技术，有待后续学习实践

   `virtio-iommu 代码解释 <https://patchwork.kernel.org/project/kvm/patch/20180214145340.1223-2-jean-philippe.brucker@arm.com/>`_

- 编译内核并重启系统

.. literalinclude:: ../../linux/lfs/lfs_boot/kernel_make
   :caption: 编译内核

- 重启系统以后检查dmesg信息(见 :ref:`intel_vt-d_startup` )可以看到内核支持IOMMU(但还没有激活，需要下一个内核参数传递来激活):

.. literalinclude:: ../iommu/intel_vt-d_startup/dmesg
   :caption: 执行 dmesg 检查过滤IOMMU支持

可以看到系统内核具备IOMMU支持(但还没有enable):

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/dmesg_iommu
   :caption: 检查dmesg可以看到内核支持IOMMU功能

- 配置内核参数: 对于 :ref:`lfs` 直接修订 ``/boot/grub/grub.cfg`` 配置:

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/grub.cfg
   :caption: 修订内核配置激活IOMMU
   :emphasize-lines: 3

.. warning::

   上述内核参数 ``pcie_acs_override=downstream,multifunction`` 之前我的实践 :ref:`iommu_grub_config` 没有使用，这个参数 **不是必须的** ，但是是一个非常特殊的补丁:

   - 如果物理主机上有 **相同厂商的相同型号多个PCIe设备** ，那么这些相同设备 ``GPU`` / ``NVMe`` 会分配到相同的iommu group和相同id
   - 这就带来一个问题: 由于PCIe passthrough是以IOMMU group的 ``vfio-pci.ids`` 来对物理Host主机屏蔽PCIe设备的，这就导致了会将所有同厂商同型号设备全部屏蔽(见 :ref:`ovmf` 实践中主机设备中3块 ``vfio-pci.ids=144d:a80a`` 同时被屏蔽的案例)
   - ``pcie_acs_override=downstream,multifunction`` 可以将相同 ``vfio-pci.ids`` 设备尽可能分配到不同组的不同ids，以便能够控制哪些设备保留在Host，哪些设备passthrough给虚拟机使用
   - ``pcie_acs_override=downstream,multifunction`` 餐宿讨论见 `Why is pcie_acs_override=downstream,multifunction discouraged? <https://www.reddit.com/r/VFIO/comments/63hr88/why_is_pcie_acs_overridedownstreammultifunction/>`_ 
   - `archlinux wiki: PCI passthrough via OVMF: Ensuring that the groups are valid <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Ensuring_that_the_groups_are_valid>`_ 做了详细说明，并引用了 `IOMMU Groups, inside and out <https://vfio.blogspot.com/2014/08/iommu-groups-inside-and-out.html>`_

再次重启后重新检查一次 ``dmesg`` 输出，就可以看到增加了一行 ``DMAR: IOMMU enabled`` (其他内容是一样的):

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/dmesg_iommu_enabled
   :caption: 再次检查dmesg可以看到激活了IOMMU
   :emphasize-lines: 3

IOMMU groups
================

- 执行以下命令确认IOMMU组( :ref:`ovmf_gpu_nvme` ):

.. literalinclude:: ../iommu/ovmf_gpu_nvme/check_iommu.sh
   :language: bash
   :caption: 检查PCI设备映射到IOMMU组

**IOMMU 组是可以传递给虚拟机的最小物理设备集**

从上述输出中可以过滤出 :ref:`tesla_t10` 对应信息:

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/tesla_t10_vfio-pci.ids
   :caption: 获取到的 :ref:`tesla_t10` 设备 ``vfio-pci.ids``

输出信息中 ``10de:1e37`` 就是需要隔离(passthrough)的 :ref:`tesla_t10` 的 ``vfio-pci.ids``

VFIO
=======

- 内核配置支持 VFIO

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/kernel_vfio
   :caption: 配置内核支持VFIO

- 编译内核

.. literalinclude:: ../../linux/lfs/lfs_boot/kernel_make
   :caption: 编译内核

.. note::

   内核编译是将 VFIO 编译为模块，这样下面就可以配置模块加载时候绑定设备(根据 PCI IDs)

- 再次获取 :ref:`tesla_t10` PCI IDs : 使用 ``lspci -nn`` 命令可以扫描出PCI IDs(上文的脚本也行):

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/lspci
   :caption: 获取 :ref:`tesla_t10` PCI IDs

输出信息:

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/lspci_output
   :caption: 获取 :ref:`tesla_t10` PCI IDs ，可以看到 ``10de:1e37`` 为 ``Tesla T10`` 的 PCI IDs

- 将绑定到 VFIO 的设备ID添加到模块加载参数中，如果有多个设备id，则用 ``,`` 分隔，例如 ``ids=1002:687f,1002:aaf8`` 。以下是我的配置绑定到VFIO的 :ref:`tesla_t10` :

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/vfio.conf
   :caption: 将需要passthrough的设备IDs添加到VFIO的模块配置中

这里有一个 :ref:`lfs` 自动加载模块的配置:

  - 在 ``/etc/modules`` 中添加需要启动时自动加载的模块名(每行一个模块)

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/modules
   :caption: ``/etc/modules`` 设置自动加载的模块
   :emphasize-lines: 2

**配置参考了debian系统，但是目前还是没有解决启动后自动加载** 待后续排查

- 重启系统(目前我暂时采用 ``modprobe vfio-pci`` 手工加载)，检查 ``dmesg | grep -i vfio`` 显示如下:

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/dmesg_vfio
   :caption: 重启系统检查VFIO绑定信息
   :emphasize-lines: 2

- 检查确认模块 ``vfio-pci`` 是否正常连接了 :ref:`tesla_t10` IDs ``10de:1e37``

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/lspci_vfio
   :caption: 通过 ``lspci`` 检查 :ref:`tesla_t10` IDs ``10de:1e37`` 是否正确使用了 ``vfio-pci`` 模块

正确的输出应该如下:

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/lspci_vfio_output
   :caption: 通过 ``lspci`` 检查 :ref:`tesla_t10` IDs ``10de:1e37`` 使用了 ``vfio-pci`` 作为内核驱动
   :emphasize-lines: 3

一定要注意，这里GPU设备的内核驱动必须是 ``vfio-pci`` 才表明正确，这样才能passthrough给虚拟机使用

OVMF qemu
==========

- 首先完成 :ref:`blfs_ovmf` (目前我采用从 :ref:`ubuntu_linux` 系统复制的 ``OVMF_CODE.fd`` )

- 修改 :ref:`run_debian_in_qemu` 运行参数，添加 ``-bios /usr/share/OVMF/OVMF_CODE.fd`` 参数:

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/d2l_install
   :caption: 构建UEFI虚拟机

这里尝试终端字符模式安装，但是会提示错误::

   error: no suitable video mode found.
   Booting in blind mode

- 修订改进为VNC安装:

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/d2l_install_vnc
   :caption: 构建UEFI虚拟机(使用VNC)

- 完成安装以后采用如下方式运行(添加passthrough PGU)

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/d2l_run_vnc
   :caption: 运行UEFI虚拟机(使用VNC)
   :emphasize-lines: 10

然后登陆到虚拟机内部检查 ``lspci -nnv`` 可以看到GPU在虚拟机内部已经识别并被加载了驱动:

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/lspci_in_vm
   :caption: 在虚拟机内部检查GPU
   :emphasize-lines: 1,11

下一步
=========

现在一切就绪，在虚拟机内部就好像物理主机一样可以直接使用 :ref:`tesla_t10` 了，下一步:

- :ref:`qemu_docker_tesla_t10`

参考
=======

- `gentoo linux: GPU passthrough with virt-manager, QEMU, and KVM <https://wiki.gentoo.org/wiki/GPU_passthrough_with_virt-manager,_QEMU,_and_KVM>`_
- `archlinux: PCI passthrough via OVMF <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF>`_
