.. _nasse_c246:

=======================
纳斯NASSE C246 ITX主板
=======================

.. _gpu_bios:

GPU相关BIOS设置
==================

主板BIOS是American Megatrends, Inc的AMI 

我的主要目标:

- :ref:`iommu` 虚拟化实现 PCIe Passthrough以及 :ref:`sr-iov`
- 启用 :ref:`above_4g_decoding` 来支持大容量 :ref:`nvidia_gpu` 的硬件初始化和加速

重点设置 ``Advanced -> PCI Subsystem Settings`` :

.. csv-table:: PCI子系统设置
   :file: nasse_c246/pci.csv
   :widths: 20,40,40
   :header-rows: 1
   
异常排查
-----------

我最初只启用了 ``Above 4G Decoding`` ，没有启用 ``Re-Size BAR`` 和 ``SR-IOV`` ，虽然不是最优设置，但是使用 :ref:`tesla_a2` 能够正常实现 :ref:`ollama_nvidia_a2_gpu_docker` 。这证明基础设置 ``Above 4G Decoding`` 已经能够支持大型GPU使用。

不过，当我参考gemini建议，再增加激活 ``Re-Size BAR`` 和 ``SR-IOV`` ，启动后系统报错:

.. literalinclude:: nasse_c246/re-size_bar_sr-iov_error
   :caption: 同时启用 ``Re-Size BAR`` 和 ``SR-IOV`` 系统报错

这表明PCI资源分配冲突，BIOS无法在当前MMIO地址空间为开启了 :ref:`sr-iov` 的GPU分配必要的基址寄存器(BAR):

- ``Above 4G Decoding`` : 使用4GB 以上的高位地址空间
- ``Re-Size BAR`` : 要求将显卡的显存（16GB）整体映射到连续的 MMIO 空间
- ``SR-IOV`` : 开启 SR-IOV 后，物理显卡（PF）会尝试预留大量的虚拟功能（VF）所需的地址空间

在某些 BIOS 实现中， ``Re-Size BAR`` 和 ``SR-IOV`` 是互斥的。开启 ``Re-Size BAR`` 会尝试占用一个巨大的连续地址块，而 ``SR-IOV`` 的 ``PF/VF`` 映射逻辑可能会因为地址对齐要求（Alignment）与之发生冲突，导致 BIOS 最终给显卡分配了一个 0 地址（0x0），驱动程序（NVRM）因此报错。

解决方法可能有如下:

- 方案一: 侧重 :ref:`kind` 模拟大规模集群环境，关闭 ``Re-Size BAR`` ，保持 ``SR-IOV`` 和 ``Above 4G Decoding``

  - 侧重实验: A2 即使没有 Re-Size BAR，推理性能损失通常在 5-10% 以内，但没有 SR-IOV 将无法进行底层硬件切分实验
  - 在 :ref:`kvm` 环境中，通过 :ref:`install_vgpu_manager` (企业级授权，NVIDIA vGPU License)，将A2切分成多个Virtual Functions(VFs)提供给虚拟机使用

- 方案二: 侧重单卡推理速度，关闭 ``SR-IOV`` ，保持 ``Re-Size BAR`` 和 ``Above 4G Decoding``

  - NVIDIA官方的 :ref:`nvidia_device_plugin_for_k8s` 支持 :ref:`kubernetes` 虚拟化方案: :ref:`share_gpu_with_cuda_time-slicing` ，能够在多个Pod共享同一个GPU，由驱动层进行快速的时间片轮转切换。在 :ref:`kind` 集群的 ``nvidia-device-plugin`` 配合设置 ``sharing.timeSlicing.renameByDefault: true`` 和 ``replicas: 10`` ，就可以让Kind看到10个(或更多) "虚拟GPU"，每个Pod都能申请一个，对于模拟分布式拓扑(如多节点推理)非常完美
  - NVIDIA官方的 :ref:`nvidia_device_plugin_for_k8s` 还支持在 :ref:`kubernetes` 中使用 :ref:`share_gpu_with_cuda_mps` 允许多个进程同时向GPU提交任务，并行利用A2的CUDA Cores，比 ``Time-Slicing`` 性能更好、显存利用率更高。对于 :ref:`llama` 3.3这种大模型，如果一个实例没有充分利用A2的算力，MPS可以让另一个实例无缝插针。

共存解决方案
-------------

gemini提示: BIOS必须关闭 ``CSM (Compatibility Support Module)`` ，如果开启了CSM，则 ``Re-Size BAR`` 绝对无法正常工作!!!

我检查了BIOS，确实发现在 ``Advanced > CSM Configuration`` 设置页面中，默认就是 ``CSM Support: Enabled`` 。不过，这个参数关闭的前提条件是 ``Video policy`` 设置为 ``UEFI`` ，然后重启才能关闭 ``CSM Support`` :

在 ``Advanced > CSM Configuration`` 设置页面，我将以下配置全部设置为 ``UEFI`` :

- Network
- Storage
- Video
- Other PCI devices

然后保存重启，再次进入BIOS，将 ``CSM Support`` 设置为 ``Disabled`` (不过，实际上当我在 ``Advanced > CSM Configuration`` 中设置了 ``Video: UEFI`` 之后，上述 ``Re-Size BAR`` 激活设置就不再导致报错了。)，此时，该页面 ``Advanced > CSM Configuration`` 下所有选项都会消失，表示彻底关闭CSM。
.. _think_server_hardware:

警告: 不推荐组装服务器
===========================

我在2025年时候，突发奇想要搞一个小巧的台式机来实现软交换功能，连接我的一堆 :ref:`raspberry_pi` 。当时我 **考虑不周** ，想法仅仅停留在实现一个具备流量分析监控的软件定义网络(交换路由)上，所以入手了 :ref:`nasse_c246` ，一款小巧的ITX主板，带4个2.5GB以太网口。售价不高，仅需539元!

然而，我没有想到，组装电脑的成本实际上非常高:

- 每个配件都是一笔不小的投入，特别是小型机箱的空间受限，会需要非常小众的组件，价格无形中上升了不少

  - 各种三方组件价格贵且质量稳定性不佳
  - 正真组装完成能用，基本功能的累计费用甚至超过一台M4处理器的 :ref:`mac_mini_2024` ，更何况质量和稳定性无法和Mac精密的装配媲美。

- 小型主板最大的缺点是扩展性极差:

  - 内存插槽只有2根，64GB成了硬性天花板，极大缩减了主机的并发运行程序( :ref:`kvm` )能力
  - 只有1根PCIeX16插槽，等我想要安装多块GPU实践 :ref:`machine_learning` 时，即使通过 :ref:`pcie_bifurcation` 也只能得到可怜的 ``x4x4x8`` 三个接口，而且需要购买性价比极低的raiser板卡(花费了215元)。这么简陋的一块转接板居然花费了主板一半的价格，吐血
  - 小尺寸主板和机箱还有一个变态的缺陷，需要特殊的 :ref:`pcie` 连接电缆，这种小众配件如果要质量较好(软硬合适且制作精良)，花费不菲。我当时头脑一热，居然订购了2根售价279元的PCIe4.0X16显卡延长线，总成本558元，甚至比主板价格更高
  - 等到安装GPU计算卡问题就更多了: 空间狭小，只能安放下一块双槽显卡；电源功率不足，即使通过显卡延长线能够外挂GPU计算卡，但是750W桌面电脑的金牌电源依然难以稳定支撑两块 :ref:`amd_mi50` 性能怪兽，更何况通过第三方连接电缆和PCIe延长线稳定性堪忧


