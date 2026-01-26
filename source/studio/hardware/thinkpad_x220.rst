.. _thinkpad_x220:

=====================
ThinkPad X220笔记本
=====================

.. note::

   ThinkPad X220是一个具有可玩性的对Linux友好的笔记本设备，在 :ref:`archlinux_on_thinkpad_x220` 流畅无比，特别是在本文实践中加持的16GB 1866MHz内存+BIOS高级扩展。

x220.mdonnelltech.com
======================

`x220.mdonnelltech.com <http://x220.mcdonnelltech.com>`_ 是一个非常有意思面向ThinkPad X220系列笔记本的垂直技术网站，提供以下技术文档:

- `ThinkPad X220系列安装macOS指南 <http://x220.mcdonnelltech.com/>`_ : 如过你没有经费购买苹果产品，可以尝试在非常便宜的二手ThinkPad X220笔记本上安装不同的macOS操作系统，体验苹果软件和进行苹果系列的软件开发。
- `X220软硬件资料 <http://x220.mcdonnelltech.com/resources/>`_ : 修改过的BIOS 1.46提供了高级功能，例如解锁了更快的RAM频率，支持安装macOS
- `X220 Ubuntu配置指南 <http://x220.mcdonnelltech.com/ubuntu/>`_ : 提供了Unbutnu更好调优的硬件指南，例如结合 lm-sensors 和 thinkfan ，高级电源管理

硬件配置
===========

硬件配置参考 `Lenovo ThinkPad X220 specs <https://www.cnet.com/products/lenovo-thinkpad-x220/specs/>`_

- CPU: Core i5-2410M @ 2.30GHz, 3MB L3 cache
- 内存: 16G (自己配置micron 16GB 1866MHz DDR3内存)
- 硬盘: Intel SSDSCC2KW51 (512G)

MiniPCI Express slot
======================

ThinkPad X220 内部有2个 MiniPCI Express slot:

- 第一个MiniPCI Express slot 通常安装无线网卡，例如我的笔记X220安装的是 ``Centrino Advanced-N 6205``
- 第二个MiniPCI Express slot 可以 mSATA SSD **这是扩展ThinkPad存储的绝佳配置**

MiniPCI Express slot 是 :ref:`pcie` 的mini版本，但是由于这是2011年(Sandy Bridge时代)，当时主板芯片组(PCH)的针脚定义(逻辑信号)采用了SATA信号:

- MiniPCIe 插槽： 52 根针脚。在设计标准中，这 52 根针脚可以被分配走 PCIe 信号，也可以被分配走 USB 2.0 信号
- mSATA ： 当时业界需要给笔记本加装微型 SSD，于是利用了 MiniPCIe 的物理规格，但把其中的数据交换针脚强行定义为 SATA 信号
- X220设计: 联想在 X220 的主板走线上，将 Slot 2（WWAN/mSATA 位）同时连接到了 Intel 芯片组的 PCIe 控制器和 SATA 控制器上

  - 如果插入 3G 网卡，它走 PCIe 协议(PCIe 2.0 x1)
  - 如果插入 SSD，它走 SATA 协议

    - :ref:`thinkpad_x220_msta_ssd`

  - 理论上该MiniPCIe接口也可以安装 eGPU ，因为该接口可以走PCIe协议，不需要BIOS识别存储。但是需要破坏X220外壳，所以不推荐

    - 仅支持 PCIe 2.0 x1 ，实际带宽只有 5Gbps（约 500MB/s），远不及 Oculink (PCIe 4.0 x4，带宽为 64Gbps)
    - 即使你通过转接卡强行接上外置显卡（eGPU），带宽也只有主流方案的 1/12 左右。这会导致高端显卡性能损耗超过 60%-80%，甚至在启动高负载应用时卡死
    - **不过对于LLM推理仅在模型加载时需要数据复制，所以有可能还是可以满足使用** :ref:`tesla_p4`
    - 供电问题：MiniPCIe 插槽只能提供约 3.3V / 1.5A 的电力，完全无法驱动外置显卡，必须依靠外置的独立电源（如长城/海盗船电源）来带动显卡

.. note::

   - NVMe 的历史： NVMe 1.0 标准虽然在 2011 年发布，但直到 2013-2014 年左右才开始有真正的产品和主板支持
   - 启动支持（UEFI）： NVMe 存储需要主板 BIOS/UEFI 拥有特殊的 NVMe 驱动模块 才能引导系统。X220 的旧式 BIOS 只有针对 SATA 设备的 AHCI 驱动，不支持NVMe协议
   - 物理瓶颈： MiniPCIe 的带宽只有 PCIe 2.0 x1 (5Gbps) -- 早期的 NVMe 至少需要 PCIe 3.0 x2 或 x4 才能体现出优势；SATA 3.0 协议（6Gbps）已经能跑满接口上限

ExpressCard
=============

ThinkPad X220提供了一个非常有意思的 **ExpressCard 54** 插槽，是实现 :ref:`expresscard_egpu` 最佳途径

BIOS微码
===========


参考
=====

- `THINKPAD X220 MODIFIED BIOS UPDATE FROM A BOOTABLE USB <http://x220.mcdonnelltech.com/bios/>`_
- `ThinkWiki: Category:X220 <https://www.thinkwiki.org/wiki/Category:X220>`_
- `Thinkwiki: MiniPCI Express slot <https://www.thinkwiki.org/wiki/MiniPCI_Express_slot>`_
