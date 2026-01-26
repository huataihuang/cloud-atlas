.. _expresscard_egpu:

============================
ExpressCard eGPU
============================

.. note::

   待实践

我的古老的 :ref:`thinkpad_x220` 具备一个非常有意思的接口 **ExpressCard 54** :

- ExpressCard 走的也是 PCIe 2.0 x1，性能与内部 MiniPCIe 相同: ``5Gbps``
- 业界有非常成熟的 **EXP GDC** (ExpressCard 版) 转接座，在淘宝上购买 ``EXP GDC笔记本外置外接PCI-E独立显卡BEAST系列Expresscard接口`` 只需要不到 RMB 250

  - 外接 :ref:`tesla_p4` (75W 功耗，8GB GDDR5 显存，单槽半高)物理接口是 PCIe 3.0 x16，而 X220 的 ExpressCard 仅提供 PCIe 2.0 x1: 带宽从理论上的 15.75 GB/s 缩减到了约 500 MB/s
  - ExpressCard 接口本身不供电。你必须通过转接座外接一个 12V DC 电源（如戴尔 DA-2 8PIN 电源或普通 PC 电源）

WDDM 与 TCC 模式
==================

.. note::

   本段尚未实践，后续计划在 :ref:`freebsd_on_thinkpad_x220` 实践通过 ExpressCard 连接 :ref:`tesla_p4` ，目前仅整理记录一些可能的操作步骤

Tesla 系列卡与 GeForce 系列最大的区别在于它没有显示输出接口:

- 模式问题：P4 默认通常工作在 TCC 模式（计算模式），用于 CUDA 计算
- FreeBSD 现状：在 FreeBSD 下，NVIDIA 驱动对 TCC 模式支持较好: 适合 跑 AI 模型（如 :ref:`ollama` / ref:`lama.cpp` ） 或进行视频转码（ :ref:`ffmpeg` ）
- :ref:`sway` 桌面加速: 因为 P4 没有输出接口，它必须通过 DMA-BUF 将渲染好的帧传回 Intel 核显进行显示（类似 Optimus 技术）。在 FreeBSD 的 Wayland 环境下，这种跨显卡渲染的配置极其复杂

- 内核模块加载： 确保 ``/boot/loader.conf`` 加载了必要的模块

.. literalinclude:: expresscard_egpu/loader.conf
   :caption: 内核模块

- PCIe 资源分配： X220 年代久远，BIOS 的 PCI Bus 资源池 很小。外接 8GB 显存的卡可能会触发 "Error 12"（资源分配不足），可能需要调整 ``hw.pci.honor_msi_blacklist`` 或相关内核参数，甚至需要刷 “高级版 BIOS” 来开启 "4GB Decoding"（不确定 X220 官方 BIOS 是否支持）

- 驱动安装: :ref:`freebsd_nvidia-driver`

- 机器学习环境需要探索 :ref:`bhyve_nvidia_gpu_passthru_freebsd_15` 和 :ref:`linux_jail_nvidia_cuda` / :ref:`linux_jail_nvidia_cuda_rocky`

可行性分析
==============

AI 推理:

- 模型加载阶段（一次性）： 8GB 的模型通过 PCIe 2.0 x1 传输。

  - PCIe 2.0 x1 实际有效带宽约为 400-500 MB/s。
  - 传输一个 6GB 的模型（量化版）大约需要 12-15 秒。这在开发环境下完全可以接受。

 推理阶段（计算密集型）：  一旦模型驻留在 :ref:`tesla_p4` 的 8GB 显存中，计算过程主要发生在 GPU 核心与显存之间。

  - P4 显存带宽高达 192 GB/s，这才是决定生成速度的关键。
  - 只有少量的 Token（文本）数据通过 PCIe 总线传回给 CPU。

设备
======

- EXP GDC Beast (ExpressCard 版本)：这是目前最稳定的 X220 转接方案

  - 淘宝上能够找到 ``ExpressCard 34`` 和 :ref:`thinkpad_x220` 的 ``ExpressCard 54`` 连接金手指部分（Connector）宽度是完全一样的（都是 34mm 宽），不过需要在插卡后配套使用一个 34mm 转 54mm 的塑料稳定支架(其实就是一个卡在 34mm 卡侧边的塑料片，填补那 20mm 的空隙)
  - 插拔注意：X220 的插槽是弹出式的（按一下弹出来）。插入 34mm 卡时，对准插槽右侧的导轨插入（通常靠右对齐），确保金手指完全吃进接口
- 外置电源：Tesla P4 峰值功耗约 75W，使用一个 120W 以上的 DC 电源适配器

软件
======

FreeBSD 下的 NVIDIA 驱动支持 CUDA:

- 安装驱动：pkg install nvidia-driver-535 (或当前最新版本)
- 安装 CUDA：pkg install linux-nvidia-libs (FreeBSD 通常需要 Linux 兼容层来运行官方 NVIDIA 库)
- 如果提示“No devices were found”，通常是 ExpressCard 通信或 BIOS 资源分配（Error 12）的问题
- 模型运行：推荐使用 Llama.cpp，因为它支持纯 CUDA 后端，且对显存管理非常透明
