.. _dell_t5820_gpu:

=========================
Dell T5820 GPU异常排查
=========================

由于我想要能够7x24在家中使用服务器，考虑到 :ref:`hpe_dl380_gen9` 涡轮风扇的噪音，我尝试选购静音工作站来运行 :ref:`machine_learning` 硬件( :ref:`tesla_a2` 和 :ref:`amd_mi50` )。虽然最初选择 :ref:`hp_z8_g4` ，但由于二手硬件异常以及高昂的总体成本，我退而求其次选择了 Dell T5820。

然而，这个选择带来了无尽的折腾，使我意识到桌面工作站实际上比机架服务器限制更多，特别是高端GPU运算卡的兼容性不佳。以下是我的折腾记录: 

从技术规格来看，T5820似乎扩展性还行:

- 具备两条PCIe3 x16插槽，从技术参数以及手册来看，至少应该能支持2块全功能GPU卡
- 可选950W电源，满足了支持2块高功率GPU的基本条件(按 :ref:`amd_mi50` 全功率是300W，双卡TDP是600W，有一定余量且可以通过设置限制GPU功率)
- 总共有5根PCIe x16 **物理插槽** ，虽然其实部分插槽的连线是x8 甚至是残废的 x1，但好歹也能再安装两块 :ref:`tesla_a2`

当我好不容易买齐了10-pin转双8-pin电源线，5针转4针风扇电源线(Dell主机使用5pin风扇线)，甚至为了能够同时驱动多个GPU风扇，我还购买了一个SATA电源转10个4pin风扇转接器。然而，当我插入 :ref:`amd_mi50` ，开启电源，却发现主机毫无反应，只有风扇在转，电源灯白色(即无故障)，却没有任何显示输出。

同样，替换成 :ref:`tesla_a2` (能够排除外接电源的问题)，也是同样的没有任何视频输出，无法启动

.. note::

   Dell工作站有一个苛刻的要求，是必须插一块显卡才能启动，这对于我这样的远程服务器使用来说非常鸡肋，白白浪费了一个PCIe插槽。

排查
======

我购买的二手Precision 5820 Tower，淘宝卖家已经将BIOS升级到最新的2.48.0，这个版本是Dell在2025年12月发布的最新版本，也就是说为了支持 Xeon W-22xx 系列处理器，这台主机的BIOS已经升级到最新版本，也侧面说明了不可能再通过升级BIOS来尝试解决不支持 :ref:`amd_mi50` 和 :ref:`tesla_a2` 。

根据我之前安装部署 :ref:`tesla_p10` , :ref:`tesla_a2` 和 :ref:`amd_mi50` 的经验(这些GPU计算卡都已经在 :ref:`hpe_dl380_gen9` 上使用验证过)，我确认或排查了以下步骤:

- :ref:`above_4g_decoding` 确定已经开启(默认配置)，这个配置是大规格显存的GPU必须开启的支持
- 我在选购T5820时已经配备了950W电源，并且在安装 :ref:`amd_mi50` 时使用了主机原装的两根8pin电源线，所以不太可能是电源功率不足导致GPU异常
- 虽然gemini提示我可能有内存与显存的"地址冲突"，也就是大规格内存可能会占用CPU寻址的物理地址，可能压缩PCIe设备的MMIO空间

  - 我尝试拔掉一半内存，甚至只保留一根32GB内存，但是情况没有任何变化
  - 参考MI50的管官方SPEC，我发现实际上官方兼容列表中高端GPU实际上最高有48GB显存，者表明主机应该是支持大容量显存的

- BIOS 里禁用 CSM (Legacy Support)，强制使用纯 UEFI 模式: 实际上我从一开始就特意设置了纯UEFI环境(以便为后续 :ref:`iommu` 虚拟化做准备)
- 也有可能是PCIe需要满血的x16插槽: 我实际测试了slot2和slot4这两个满血slot，都没有解决
- 甚至尝试了将PCIe降级为 ``gen2`` ，实践没有解决
- ``Advanced configurations`` 有一个可疑的 ``ASPM(Active State Power Management) Level`` ，这个ASPM（主动状态电源管理）是允许 PCIe 设备在空闲时进入低功耗状态，为避免L0,L1功耗切换影响，我尝试disable这个功能，没有解决
- 关闭 ``Secure Boot`` 没有解决

推测
========

由于各种可能排除，我发现不仅 :ref:`amd_mi50` 无法工作，而且 :ref:`tesla_a2` 也同样安装以后无法启动主机。这就奇怪了 :ref:`tesla_a2` 只有 16GB 显存，已经是常见的桌面级显卡的显存规格了。

我注意到Google提到部分数据中心P100,M40都有人报告无法启动，但是我又验证我的 :ref:`tesla_p4` (8GB显存)可以使用。

太让人沮丧了，我的最好的GPU都无法工作？

我忽然想到，是不是T5820会拒绝所有的数据中心GPU？

因为我测试的都是数据中心的无显示输出的计算卡，T5820工作站的官方SPEC列出的显卡全部是桌面级系列，我怀疑是BIOS做了什么限制。

所以我尝试:

- :ref:`amd_mi50_flash_vbios` 来绕开这种限制: **失败**

可能的原因
===========

我在 `The Dell Precision 5820 does not have NVIDIA Tesla support (See pinned post for caveat) <https://www.youtube.com/watch?v=WNv40WMOHv0>`_ 的评论中找到一个线索:

**T5820 不支持 reBAR** ，对于数据中心Tesla计算卡，需要大容量BAR(例如16GB或32GB)，以便CPU能够直接访问其全部显存。这需要主板支持 **Resialbe BAR(reBAR)** 或 :ref:`above_4g_decoding` 。

NVIDIA的数据中心计算卡通过 ``nvflash64.exe --gpumode graphics`` 可以修订成图形模式，在这种模式下就能想传统显卡那样使用256MB的"small bar"，这样几乎所有主版的BIOS都能够在4GB以下的低端内存空间分配出256MB，从而扰过BIOS的资源分配检查。

不过AMD的计算卡没有这个修改gpumode的方法，可能通过 :ref:`amd_mi50_flash_vbios` 改成Pro VII固件，然后执行 ``lspci -vvv`` 查看 Region 大小，如果是256M，则在T5820上使用的概率就很大。

如果刷入固件之后使用small bar，但依然无法在T5820上使用，则可能是T5820使用了 Class Code 或 SSID 的身份来判断

- 修订VBIOS的BAR size (Red BIOS Editor (RBE) 修改)
- 修订VBIOS的SSID，例如修改 081E (Radeon Pro VII) 

在验证我的想法之前，我先测试 :ref:`nvflash` 调整Tesla计算卡模式(没有成功， :ref:`tesla_a2` 不支持切换graphics模式)，然后尝试 :ref:`amd_mi50_change_vbios_bar_size`

参考
=======

- `Precision 5820 Tower 软件下载 <https://www.dell.com/support/product-details/zh-cn/product/precision-5820-workstation/drivers>`_
