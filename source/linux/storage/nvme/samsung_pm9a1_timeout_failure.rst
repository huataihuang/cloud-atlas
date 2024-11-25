.. _samsung_pm9a1_timeout_failure:

=======================================
三星PM9A1 NVMe存储初始化timeout无法识别
=======================================

问题
=======

我在准备 :ref:`update_samsung_pm9a1_firmware` 时遇到一个非常奇怪的问题:

- 由于2020年购买的 :ref:`samsung_pm9a1` firmware版本过低，无法用于U盘和 :ref:`mbp15_late_2013_update_nvme` ，所以我还是把需要升级firmware的 :ref:`samsung_pm9a1` 安装回 :ref:`hpe_dl360_gen9` ，以便在服务器上能够执行 :ref:`update_samsung_pm9a1_firmware`
- 由于我原先在 :ref:`hpe_dl360_gen9` 部署了 :ref:`ovmf_gpu_nvme` ，也就是 :ref:`samsung_pm9a1` 被直接passthrough给虚拟机来部署 :ref:`ceph` ，所以为了升级SSD firmware，我需要暂时回滚掉内核 ``vfio``

我首先修订内核配置，将 :ref:`ovmf_gpu_nvme` 配置的内核参数 ``/etc/defualt/grub`` 配置:

.. literalinclude:: ../../../kvm/iommu/ovmf_gpu_nvme/grub_vfio-pci.ids
   :language: bash
   :caption: 配置/etc/default/grub加载vfio-pci.ids来隔离PCI直通设备

去除掉 ``vfio-pci.ids`` 配置，即修改成如下:

.. literalinclude:: samsung_pm9a1_timeout_failure/grub_disable_vfio-pci.ids
   :language: bash
   :caption: 去除掉 ``vfio-pci.ids`` 配置 以便能够在物理主机上使用NVMe设备
   :emphasize-lines: 2

然后更新grub: ``sudo update-grub`` ，并重启服务器

奇怪的是，重启后在物理服务器上看不到任何 NVMe 设备:

我发现自动启动的 :ref:`ovmf_gpu_nvme` 依然在使用 :ref:`samsung_pm9a1` ，那我就停止虚拟机并设置虚拟机不自动启动，然后重启物理服务器操作系统。然而没有解决问题

我仔细检查了物理服务器对NVMe设备的识别，部分参考了 :ref:`ovmf_gpu_nvme` 步骤以确保回滚内核 ``vfio`` 成功:

- 检查设备ID和 ``vfio-pci`` 绑定ID:

.. literalinclude:: ../../../kvm/iommu/ovmf_gpu_nvme/lspci_nn
   :caption: ``lspci -nn`` 命令检查设备ID和 ``vfio-pci`` 绑定ID

输出信息可以看到物理主机确实已经安插好了 :ref:`samsung_pm9a1` :

.. literalinclude:: samsung_pm9a1_timeout_failure/lspci_nn_output
   :caption: ``lspci -nn`` 命令可以看到系统已经安插好一块 :ref:`samsung_pm9a1`

- 检查 :ref:`samsung_pm9a1` 的详细信息以及内核驱动加载:

.. literalinclude:: ../../../kvm/iommu/ovmf_gpu_nvme/lspci_nvme
   :language: bash
   :caption: lspci检查nvme设备驱动

这里就 **看出问题** 了，输出显示操作系统没有加载驱动:

.. literalinclude:: samsung_pm9a1_timeout_failure/lspci_nvme_output
   :caption: lspci检查nvme设备使用驱动是空白行

而翻看之前 :ref:`ovmf_gpu_nvme` 可以看到这里应该有一行 ``Kernel driver in use: nvme`` :

.. literalinclude:: ../../../kvm/iommu/ovmf_gpu_nvme/lspci_nvme_without_isolate
   :language: bash
   :caption: 原先在 :ref:`ovmf_gpu_nvme` lspci检查尚未隔离的nvme设备显示使用了nvme设备驱动
   :emphasize-lines: 3

- 为什么有这个差异呢？检查 ``dmesg -T | grep -i nvme`` 可以看到如下输出:

.. literalinclude:: samsung_pm9a1_timeout_failure/dmesg_nvme
   :caption: ``dmesg`` 显示NVMe设备初始化超时
   :emphasize-lines: 2,4

解决过程(进行中)
===================

`archlinux wiki: NVMe#Troubleshooting <https://wiki.archlinux.org/title/Solid_state_drive/NVMe#Troubleshooting>`_ 说明:

- 部分NVMe设备存在节能(APST)异常缺陷，已经发现报告过 **使用S5Z42105 firmware的Kingston A2000** 和 **早期Samsung NVMe驱动** 以及一些WesternDigital/Sandisk 设备

- 解决方法是内核关闭APST以及添加相关关闭pcie电源管理参数:

  - ``nvme_core.default_ps_max_latency_us=0``
  - ``pcie_aspm=off pcie_port_pm=off``

考虑到之前我是将 :ref:`samsung_pm9a1` passthrough 给虚拟机使用，所以物理服务器内核没有触发这个问题，所以我首先尝试关闭 ``APST`` ，然后又加上了关闭pcie电源管理参数，最终配置如下:

.. literalinclude:: samsung_pm9a1_timeout_failure/grub
   :language: bash

但是都没有效果

我尝试对操作系统进行升级，但是意外发现系统宕机，终端显示出 NMI 错误。联想到最近出现的 :ref:`dl360_gen9_pci_bus_error` 以及反复和处理器processor 1相关的SATA磁盘报错，所以我怀疑处理器processor 1的PCIe通道可能确实是硬件故障了。

由于processor 1和PCIe插槽1、2关联，所以我将PCIe插槽1、2上的NVMe转接卡拔下，仅查一个NVMe到PCIe插槽3上，这样启动就没有报硬件错误。不过，很不幸，启动以后 :ref:`samsung_pm9a1` 还是没有使用nvme驱动，导致没有显示出来。

最后，我甚至尝试了使用 :ref:`arch_linux` 安装U盘启动服务器，但是检查启动日志 ``dmesg -T | grep -i nvme`` 依然看到相同的报错:

.. literalinclude:: samsung_pm9a1_timeout_failure/dmesg_nvme_again
   :caption: 使用安装U盘启动也无法识别nvme设备，报错依旧

``我目前推测是服务器主板的PCIe通道硬件故障了`` ，因为轮换了多块nvme依然没有能够识别出

**崩溃，我暂时找不到解决的方法，暂时放弃...**

参考
======

- `archlinux bbs: [SOLVED] NVME disk dropping off <https://bbs.archlinux.org/viewtopic.php?id=286274>`_ 提出了内核参数对部分存在问题NVMe的影响，提供了参考链接
- `archlinux wiki: NVMe#Troubleshooting <https://wiki.archlinux.org/title/Solid_state_drive/NVMe#Troubleshooting>`_
