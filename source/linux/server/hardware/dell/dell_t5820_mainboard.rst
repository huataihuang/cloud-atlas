.. _dell_t5820_mainboard:

===========================
Dell T5820 主板
===========================

我在排查 :ref:`dell_t5820_gpu` 的兼容 :ref:`tesla_a2` 和 :ref:`amd_mi50` 问题时候，非常困扰。虽然我反复折腾 :ref:`dell_t5820_rebaruefi` 以及 :ref:`amd_mi50_flash_vbios` / :ref:`amd_mi50_change_vbios_bar_size` ，但实际上都折戟沉沙。

峰回路转的是，在我尝试挑战 :ref:`hackintosh` ，使用 :ref:`amd_rx580` 矿卡不慎烧掉了主板，我这才发现淘宝上售卖的 Dell T5820 实际上分为两类:

- Dell备件编号 ``X8DXD`` / ``02KVM`` : 支持 ``W-21xx`` 到 ``W-2225`` :ref:`xeon_w`
- Dell备件编号 ``X30MX`` / ``6JWJY`` : 最高支持大功率160W的CPU，也就是支持 ``W-2235`` 到 ``W-2295``

这个售卖信息一下子解决了我之前购买 :ref:`dell_t5820` 遇到的一个困惑，当时我购买了 :ref:`xeon_w-2235` 是当时找到最便宜且核心数较多的CPU，可惜无法点亮主机。不得不按照主机卖家的提示，更换为价格更贵但核心数降低(功率也降低)的 :ref:`xeon_w-2225` 。

辨析
======

我忽然想到了我之前反复折腾 :ref:`dell_t5820_gpu` 事情，gemini提示我各种BIOS配置调整，特别是 :ref:`above_4g_decoding` 甚至尝试 :ref:`dell_t5820_rebaruefi` 也不成功。会不会就是因为T5820的主板实际有代际区别导致的呢？

再次咨询gemini "在T5820上成功使用Tesla A2以及AMD MI50是不是指特定型号的T5820主板，例如支持大功率CPU的主板"，终于触发了gemini回复了解决之道:

- Dell T5820主板有两代产品，在 **VRM供电相数、供电芯片以及PCIe 12V供电轨分配** 上硬件版本迭代改进

  - 早期版本（第一代）：``X8DXD`` / ``02KVM`` / ``88RV6`` / ``PWDJV`` 针对 Skylake-W（Xeon W-2100 系列）设计: VRM供电相数与滤波设计较低，无法承受Cascade Lake-W高功耗CPU的瞬间电流拉扯，硬件层面限制了 W-2235 及以上CPU的启动
  - 第二代首批版本（中期升级版）： ``X30MX`` 为全面适配 14nm++ 的 Cascade Lake-W（Xeon W-2200 系列）而重新设计的二代主板，强化了 CPU VRM 供电模组和 PCIe 电源供电分配
  - 第二代后期版本（最新/最终修正版）： ``6JWJY`` 在 T5820 生命周期后半程（大约 2021 年之后）生产线及售后备件（FRU）中使用的最新修订版主板，在 ``X30MX`` 的基础上做了一些微小的电路保护和元件优化

.. note::

   上述有关 ``X30MX`` 和 ``6JWJY`` 描述不一定准确，我只是从gemini摘录，但是我发现gemini前后回答是有细微差异和矛盾的，所以只能参考不能全信

- 对于 :ref:`tesla_p4` 和 :ref:`tesla_t4` 在硬件层面上默认使用 **256MB的小BAR窗口** ，所以不需要主板下发16GB的大块连续MMIO地址空间，只需要开启基础的 :ref:`above_4g_decoding` 就可以，所以绝大部分版本的T5820主板(包括早期 ``X8DXD`` )都能直接识别并正常运行，不需要任何ReBAR补丁
- :ref:`tesla_a2` 和 :ref:`amd_mi50` **对主板与电源极度挑剔**

  - 兼容原理: 这两款卡强制要求 16GB/32GB 的 **Large BAR (大容量MMIO映射)** ，并且 :ref:`amd_mi50` TDP功耗高达 ``300W`` ， :ref:`tesla_a2` 虽然功耗仅 40-60W 但对PCIe槽位分配极度敏感
  - 目前跑通A2或MI50的案例，几乎全部基于后期修订版主板(如 ``X30MX`` 或 ``6JWJy`` )，因为这些主板的BIOS在资源分配算法上改进了针对PCIe 64-bit MMIO空间连续大块内存的预留，避免设备管理器抛出 ``Code 12`` (资源不足)
  - 电源规格: T5820必须配置 **950W功率的电源** 才能支持MI50等大功耗卡，否则主板会拒绝给PCIe输出大电流或无法开机

需要注意 :ref:`dell_t5820` PCIe 插槽拓扑与MMIO连续窗口:

- 当使用 :ref:`xeon_w-2225` 这样的W-2200系列处理器时，处理器会原生提供 **48条PCIe 3.0通道** :

  - **Slot 2（PCIe 3.0 x16，物理/电气全速）** : CPU 直连，主显卡槽，支持 300W 功耗，完美支持 Large BAR。
  - **Slot 4（PCIe 3.0 x16，物理/电气全速）** : CPU 直连，副显卡槽，与 Slot 2 完全平起平坐，同样支持 300W 功耗和 Large BAR。
  - **Slot 1（PCIe 3.0 x16 物理形态，电气 x8 速率）** : CPU 直连，虽然只有 ``x8`` 速率，但物理上完全支持大MMIO空间映射。
  - **Slot 3 / Slot 5（PCIe x1 / x4）** : ``走 C422 PCH 芯片组`` ，适合装转接卡、网卡或普通扩展卡，不适合需要 Large BAR 的大显存计算卡。

.. note::

   我有2块 :ref:`amd_mi50` ，规划使用 ``slot 2`` 和 ``slot 4``

   如果使用我的3块 :ref:`tesla_a2` ，则规划使用 ``slot 1`` , ``slot 2`` 和 ``slot 4``

电源
===========

我购买的 :ref:`dell_t5820` 采用了 **950W** 电源，所以能够支持2块 :ref:`amd_mi50` (TDP是300W，两块就是600W)，加上 :ref:`xeon_w-2225` 以及外设，整机功耗大约 800W，基本能够支持。

需要注意T5820只提供了2根8pin显卡电源线，需要购买高质量的8pin分双8pin电源线!

更换主板
=========

在淘宝上订购了一块支持W-2255的T5820主板，收到确认部件编号是 ``06JWJY`` ，大约是2021年生产的，算是"中后期/成熟期产品"。该编号印刷位于CPU旁连接机箱前置 NVMe U.2 硬盘背板的 SlimSAS/PCIe 数据接口的旁边。

.. note::

   对比了一下我原先在淘宝上购买的T5820整机的原装主板 ``088RV6`` ，果然是早期的第一代主板。难怪无法支持 :ref:`xeon_w-2235` 及以上的CPU。

更换主板的方法参考Dell官方 `如何更换 Precision 5820-7820 的主板 <https://www.dell.com/support/contents/zh-cn/videos/videoplayer/%E5%A6%82%E4%BD%95%E6%9B%B4%E6%8D%A2-precision-5820-7820-%E7%9A%84%E4%B8%BB%E6%9D%BF/6079812597001>`_ 视频，但具体操作步骤可以参考 `戴尔 Precision 5820 Tower 用户手册 <https://dl.dell.com/content/manual34500682-戴尔-precision-5820-tower-用户手册.pdf?language=zh-cn>`_

最终验证结果
==============

当花费了一番功夫之后，终于安装升级了我新购买的二手 部件编号 ``06JWJY`` 的T5820主板。我成功验证:

- :ref:`amd_mi50_flash_vbios` 由于VBIOS 已经包含 EFI Image (GOP)，能够直接安装在Slot 2上作为主显卡点亮和使用。也就是说:

  - 我可以用我的2块32GB的 :ref:`amd_mi50` 来构建我的梦幻 :ref:`hackintosh`
  - 当使用KVM运行黑苹果时，我还可以做切换，在不使用 :ref:`macos` 时采用 :ref:`rocm` 容器化运行LLM推理

- :ref:`tesla_a2` 验证没有成功，没有任何报错(电源指示灯白色表明启动正常)，但是实际卡在BIOS启动前，无任何显示输出(主显卡NVIDIA 400)

  - 但至少解决了之前即使 :ref:`dell_t5820_rebaruefi` 也无法开机的问题
  - 但是我发现T5820插了NVIDIA P400亮机卡，再插 :ref:`tesla_a2` 无法启动(电源指示灯白色显示无异常)，我怀疑是因为 T5820 只支持安装 **包含 EFI Image (GOP)的工作站显卡**
  - (gemini) :ref:`tesla_a2` 固件中包含 UEFI GOP，但它被标记为 "Disabled" ，需要使用NVIDIA 提供了一个名为 nvidia-display-switch (旧称 displaymodeselector) 的工具，专门用于将 Tesla 卡从“无头（Headless）”模式切换到“显示（Display）”模式。 (不太确定AI提示是否正确，待实践)

参考
======

- `Dell 5820 CPU Compatibility <https://www.dell.com/community/en/conversations/precision-fixed-workstations/dell-5820-cpu-compatibility/67a9013faab2c705bf151d37?page=2>`_
- gemini
