.. _dell_t5820_gpu:

=========================
Dell T5820 GPU异常排查
=========================

.. warning::

   本文不用往下看了，简单来说，第一代T5820主板存在无法支持W-2235以上的CPU，也存在对LargeBAR支持的缺陷。更换到 :ref:`dell_t5820_mainboard` 二代，则解决了上述问题。并且需要注意，GPU计算卡需要刷包含EFI Image (GOP)的VBIOS，例如 :ref:``

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

一些可能的尝试方向(但看起来没有希望!!!)
============================================

- `Building llama.cpp from source on a Dell Precision T5820 with an RTX 3090 Ti (after seven power cycles) <https://ianlpaterson.com/blog/llama-cpp-3090-ti-dell-t5820/>`_ 关于RTX 3090 Ti显卡的安装经验，非常详细，可惜我是Tesla数据中心卡

- `I recently tested NVIDIA Tesla compatibility in a bunch of Dell Precision Tower PCs <https://www.reddit.com/r/homelab/comments/1gz0ryn/i_recently_tested_nvidia_tesla_compatibility_in_a/>`_

  - 老款 Precision 工作站（T3610 / T5810 / T7810 / T7610 等）和 Tesla GPU 完美兼容:  **在 DDR3/DDR4 早期架构的 Dell Tx610 和 Tx810（如 T5810 / T7810）上，Tesla 卡完全可以原生正常工作** 。只要在 BIOS 中开启 :ref:`above_4g_decoding` 、确保电源功率足够（如 685W/825W/1300W），系统就能顺畅引导并驱动 Tesla 卡。
  - Precision 5820 / 7820 属于 **“不兼容”** 区（Not Compatible）：帖子作者特意针对 Tower 5820 进行测试，结论是：在标准配置下，Tesla 卡无法在 T5820 上正常工作（表现为无法通过 POST 自检、bootloop 无限重启或直接黄灯关机）。
  - 帖子中提到的“潜在解决方案（Suggested Solution）” : 帖主在列表中补充提到，有人建议将 Tesla 计算卡刷写（Flash）固件改变其工作模式（"flashing the card into GPU mode"），或者结合特定的 PCIe 显示分配方式尝试绕过，但他本人在卖掉 T5820 之前未能在该机型上验证成功。

.. note::

   Dell 在 5820 / 7820 这代新主板上改变了底层的 PCIe 训练（PCIe Training）与 EC 管理逻辑，导致像 Tesla A2、P100、M40 等服务器架构计算卡（Non-Consumer GPU）会在 POST 自检阶段与主板固件发生死锁，即使屏蔽 SMBus (B5/B6) (我尝试了 :ref:`dell_t5820_smbbus_tape_mod_rebar` 确实失败) 也无法越过底层硬件校验。

- `The Dell Precision 5820 does not have NVIDIA Tesla support (See pinned post for caveat) <https://www.youtube.com/watch?v=WNv40WMOHv0>`_

  - Precision 5820 与 Tesla 架构卡存在原生兼容性限制: 测试了多种 Tesla 卡、更换了不同的 PCIe 插槽、更新到了最新的 BIOS，甚至使用专门制作的供电线，系统在检测到插入 Tesla 卡后，都会陷入无限重启（Boot Loop）或开机后瞬间断电保护，无法通过 POST 自检亮屏。
  - 屏蔽 SMBus (B5/B6) 依然无效(和我的 :ref:`dell_t5820_smbbus_tape_mod_rebar` 实验相印证)：尝试了屏蔽 SMBus 引脚（Tape the SMBus pins），但同样无法让 Precision 5820 识别开机。 **这说明 5820 的固件/EC 层对 Tesla 系列服务器架构卡（Non-Consumer GPU）有更底层的硬性阻断机制（例如特定的 PCIe Vendor/Device ID 判定、或者对 PCIe 带外 Option ROM 固件加载机制的拦截），并非单纯的 SMBus 信号拉低。**

参考
=======

- `Precision 5820 Tower 软件下载 <https://www.dell.com/support/product-details/zh-cn/product/precision-5820-workstation/drivers>`_
