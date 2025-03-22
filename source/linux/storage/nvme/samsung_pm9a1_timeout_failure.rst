.. _samsung_pm9a1_timeout_failure:

=======================================
三星PM9A1 NVMe存储初始化timeout无法识别
=======================================

.. warning::

   从我的使用经验来看，这款 :ref:`samsung_pm9a1` 存在严重的质量问题，至少早期版本很有可能存在硬件和软件隐患，在某个触发条件下会导致控制器损坏。我的3个PM9A1故障让我对三星的OEM质量非常失望，几乎是粉转黑了。

   另外在网上找到的信息:

   - `作为三星 pm9a1 固态 0e 报错/数据损坏的早期、二度受害者，谈谈科学的预判和检测方法 <https://cn.v2ex.com/t/879433>`_
   - `关于PM9A1和980Pro SLC Cache缓存异常的信息汇总 <https://www.163.com/dy/article/GKUEGPDQ0512MJDN.html>`_

问题
=======

我在准备 :ref:`update_samsung_pm9a1_firmware` 时遇到一个非常奇怪的问题:

- 由于2020年购买的 :ref:`samsung_pm9a1` firmware版本过低，无法用于U盘和 :ref:`mbp15_late_2013_update_nvme`

  - 这个问题我是偶然发现的: 我发现只有最新购买的 :ref:`samsung_pm9a1` 能用于U盘和 :ref:`mbp15_late_2013` ，而差异在于 :ref:`samsung_pm9a1` firmware版本
  - 所以我考虑升级 :ref:`samsung_pm9a1` firmware:

    - 目前低版本firmware的 :ref:`samsung_pm9a1` 只有在 :ref:`hpe_dl360_gen9` 能使用
    - 所以我尝试将 :ref:`samsung_pm9a1` 安装回服务器上来执行 :ref:`update_samsung_pm9a1_firmware`

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

奇怪的是， **重启后在物理服务器上看不到任何 NVMe 设备** :

- 我发现自动启动的 :ref:`ovmf_gpu_nvme` 依然在使用 :ref:`samsung_pm9a1` ，那我就停止虚拟机并设置虚拟机不自动启动，然后重启物理服务器操作系统。然而没有解决问题

- 我仔细检查了物理服务器对NVMe设备的识别，部分参考了 :ref:`ovmf_gpu_nvme` 步骤以确保回滚内核 ``vfio`` 成功:

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
   :emphasize-lines: 5,6

2024年11月的一些尝试(失败)
============================

`archlinux wiki: NVMe#Troubleshooting <https://wiki.archlinux.org/title/Solid_state_drive/NVMe#Troubleshooting>`_ 说明:

- 部分NVMe设备存在节能(APST)异常缺陷，已经发现报告过 **使用S5Z42105 firmware的Kingston A2000** 和 **早期Samsung NVMe驱动** 以及一些WesternDigital/Sandisk 设备

- 解决方法是内核关闭APST以及添加相关关闭pcie电源管理参数:

  - ``nvme_core.default_ps_max_latency_us=0``
  - ``pcie_aspm=off pcie_port_pm=off``

考虑到之前我是将 :ref:`samsung_pm9a1` passthrough 给虚拟机使用，所以物理服务器内核没有触发这个问题，所以我首先尝试关闭 ``APST`` ，然后又加上了关闭pcie电源管理参数，最终配置如下:

.. literalinclude:: samsung_pm9a1_timeout_failure/grub
   :language: bash

但是都没有效果: 这个设置参数是按照archlinux的文档参考 `[PATCH v2] nvme-pci: Fix the instructions for disabling power management <https://lore.kernel.org/r/all/20240711225952.5445-1-bvanassche@acm.org/T/>`_ ，其中提到的 "Samsung SSD 970 EVO PlusNVMe SSD" 环境fix似乎和我类似，但是我验证没有成功。

我尝试对操作系统进行升级，但是意外发现系统宕机，终端显示出 NMI 错误。联想到最近出现的 :ref:`dl360_gen9_pci_bus_error` 以及反复和处理器processor 1相关的SATA磁盘报错，所以我怀疑处理器processor 1的PCIe通道可能确实是硬件故障了。

由于processor 1和PCIe插槽1、2关联，所以我将PCIe插槽1、2上的NVMe转接卡拔下，仅查一个NVMe到PCIe插槽3上，这样启动就没有报硬件错误。不过，很不幸，启动以后 :ref:`samsung_pm9a1` 还是没有使用nvme驱动，导致没有显示出来。

最后，我甚至尝试了使用 :ref:`arch_linux` 安装U盘启动服务器，但是检查启动日志 ``dmesg -T | grep -i nvme`` 依然看到相同的报错:

.. literalinclude:: samsung_pm9a1_timeout_failure/dmesg_nvme_again
   :caption: 使用安装U盘启动也无法识别nvme设备，报错依旧

:strike:`我目前推测是服务器主板的PCIe通道硬件故障了，因为轮换了多块nvme依然没有能够识别出`

不过，因为我2025年2月因为 :ref:`hpe_dl360_gen9` 主板损坏无法启动，重新购买了 :ref:`hpe_dl380_gen9` ，依然存在无法识别 :ref:`samsung_pm9a1` 。这也证明之前的推测是错误的，这个问题 **不是服务器PCIe通道硬件故障**

2025年2月尝试修复
===================

- 首先可以确认 :ref:`samsung_pm9a1` 控制器是可以看到的，这点通过 ``lspci`` 可以看到:

.. literalinclude:: ../../../kvm/iommu/ovmf_gpu_nvme/lspci_nvme
   :language: bash
   :caption: lspci检查nvme设备驱动

.. literalinclude:: samsung_pm9a1_timeout_failure/lspci_nvme_output_nodriver
   :caption: lspci检查nvme设备使用驱动是空白行

- 但是执行 ``nvme-cli`` 却看不到这块 :ref:`samsung_pm9a1` ，只看到系统的另外一块intel :ref:`intel_optane_m10`

.. literalinclude:: samsung_pm9a1_timeout_failure/nvme-cli_list
   :caption: 使用 ``nvme-cli`` 检查设备

我尝试采用 :ref:`update_samsung_pm9a1_firmware` 来修复，但是很不幸，如果SSD无法识别，则firmware更新程序无法刷新

解决新思路
-----------

我突然想到为何我之前在 :ref:`ovmf_gpu_nvme` 是成功的，并且能够 :ref:`install_ceph_manual` 稳定运行了两三年:

- 我甚至找到 :ref:`ceph_os_upgrade_ubuntu_22.04` 证明我最初部署的Ceph环境Ubuntu 20.04 LTS，于2022年9月 :ref:`upgrade_ubuntu_20.04_to_22.04`

  - 升级前后Ceph运行都非常稳定，侧面验证了 :ref:`samsung_pm9a1` 在Ubuntu 22.04 LTS是可以运行的
  - 但是我注意到一个问题，我之前运行的Ubuntu内核是 5.15 / 5.19 系列，我不记得使用过 6.x 系列内核

    - 根据网上资料，Ubuntu 22.04 LTS 在22年4月发布时使用的是 5.15 内核
    - Ubuntu 22.04.2 时内核升级到 5.19
    - 2023年8月，Ubuntu 22.04.3 LTS 内核跃升到 Kernel 6.2; 而当前 Ubuntu 22.04 LTS 内核采用的是 Kernel 6.5

  - 我又核对了我当前使用的 :ref:`lfs` 和 :ref:`debian` 12，分别使用了内核 ``6.10.5`` 和 ``6.1.0``

- Ubuntu 22.04 对应的是 Debian 12，所以从发行版来看，两者没有区别: 主要区别看起来就是我一直使用 Kernel 5.15/5.19 是正常使用 **旧版本firmware** :ref:`samsung_pm9a1` ，而切换到 Kernel 6.x 之后似乎就没有正常使用过 :ref:`samsung_pm9a1`

.. warning::

   在尝试了 :ref:`debian_downgrade_kernel` 将内核降级到 ``5.15`` 之后，发现没有解决 :ref:`samsung_pm9a1` 识别问题。

很不幸，看来还有什么细节差异没有找到，内核降级到 ``5.15`` 没有解决问题。

补充信息: 在线服务器的系统日志中也曾发现过类似 ``Timeout`` 报错，似乎这种NVMe报错并非罕见::

   kernel: nvme nvme0: Shutdown timeout set to 10 seconds

ubuntu 20.04
--------------

重新部署安装 :ref:`ubuntu_linux` 20.04 版本，但是我发现内核是 ``vmlinuz-5.4.0-144`` ，即使升级也是 ``vmlinuz-5.4.0-208`` ，并没有解决识别 :ref:`samsung_pm9a1` 问题。在这个内核版本，我尝试添加了内核参数:

.. literalinclude:: samsung_pm9a1_timeout_failure/grub
   :language: bash

也没有解决

但是我发现和我之前笔记不同，内核没有达到 ``5.15/5.19`` ，似乎需要做一次升级: 执行 :ref:`upgrade_ubuntu` ，检查内核版本是 ``5.15.0-134-generic`` ( Ubuntu 22.04.5 LTS )

太奔溃了，还是没有解决

我发现在主机的BIOS设置中选择对NVMe设备进行test，异常的 :ref:`samsung_pm9a1` 测试控制器始终是 ``fail`` 状态，看来挽救的可能性非常小了。

**已经寄了3个Samsung PM9A1了，大哭**

参考
======

- `archlinux bbs: [SOLVED] NVME disk dropping off <https://bbs.archlinux.org/viewtopic.php?id=286274>`_ 提出了内核参数对部分存在问题NVMe的影响，提供了参考链接
- `archlinux wiki: NVMe#Troubleshooting <https://wiki.archlinux.org/title/Solid_state_drive/NVMe#Troubleshooting>`_
