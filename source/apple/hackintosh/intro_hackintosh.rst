.. _intro_hackintosh:

========================
Hackintosh(黑苹果)简介
========================

我的想法
==========

我从2011年开始使用第一台 :ref:`mba11_late_2010` ，几乎都是将macOS作为自己的工作客户端。特别是在阿里能够选择配置苹果笔记本，从x86到Apple Silicon架构的MacBook，能用原生系统，所以一直都没有想要自己折腾Hackintosh(黑苹果)。

不过， :ref:`whats_past_is_prologue` ，失业之后再折腾新设备不太经济，我现在专注于深入挖掘自己已经投入大量资金和时间的二手设备 :ref:`hpe_dl380_gen9` 和 :ref:`dell_t5820` ，以及自己组装的台式机和 :ref:`raspberry_pi` 。

但是，我发现一个问题，现有手头最好的能够使用的苹果设备是 **十三年前** 购买的 :ref:`mbp15_late_2013` ，已经老到无法安装最新的macOS，甚至连很多主流软件都无法在旧版macOS上运行了。这带来了很多不便。

.. note::

   由于2025年和2026年出现了内存、存储芯片荒，原本春季可能上市的M5 mac mini也迟迟没有推出，看来即使mac mini推出价格也会比原本预期高很多。有可能要到2027甚至2028年才有合适价位的设备可以购买。

那么怎么让旧设备继续"发光发热"呢？

经过一番折腾，我终于 :ref:`oclp_macos` 。没错，终于能够让 **十三年前** :ref:`mbp15_late_2013` 爬起来再战三百回合。

但是， :ref:`mbp15_late_2013` 内置的 :ref:`nvidia_gpu` 驱动已经被macOS废弃，通过 ``OCLP`` 强行注入驱动带来很多奇怪的异常，特别是现代网页的复杂 :ref:`javascript` 常常触发驱动异常，导致系统假死没有响应。

考虑到我后期移动工作可能会采用更低端轻便的 :ref:`mba11_late_2010` (我是多想不开要自我折磨)，我就想如何充分利用服务器硬件来实现一个云端macOS/Windows环境，用于开发和日常使用:

- 所有的重负载计算和图形渲染都由服务器CPU/GPU承担
- 通过 :ref:`sunshine` / :ref:`moonlight` 推流实现本地轻量级显示和操作
- 任何时候都能够回到一致的工作桌面，永不停机的工作环境

这里有一个巧妙的workaround，原本在 :ref:`mbp15_late_2013` 上通过 ``OCLP`` 注入NVIDIA驱动，在组件 Hackintosh(黑苹果) 就可以选择最兼容macOS的 :ref:`amd_gpu` 来绕过驱动异常问题，按照gemini推测，即使采用入门级的 :ref:`amd_rx580` 也能带来很大的性能提升。

构想的方案
===============

:ref:`dell_t5820` 作为典型的企业级工作站，其底层硬件( :ref:`xeon_w` 我实际使用 :ref:`xeon_w-2225` )在黑苹果社区有非常成熟的模拟方案。

- 最高可模拟的 macOS 版本：macOS 15 (Sequoia)

  - 模拟身份: 可以在 ``OpenCore`` 中将其 ``SMBIOS`` 仿冒为 ``MacPro7,1`` (即 **2019款 Mac Pro** )，因为真实的MacPro7.1本身就是使用Intel Xeon W-32xx 处理器(与T5820使用的W-21xx/22xx同属Skylake-X/Cascade Lake-X架构)，所以指令集和PCIe通道映射高度一致。
  - Xcode 兼容性： macOS 15 完全能够运行 Xcode 16，能够满足 2026/2027 年绝大多数 iOS 18 / iOS 19/20 的开发与编译需求。


参考
=======

- `wikipedia: Hackintosh <https://zh.wikipedia.org/wiki/Hackintosh>`_
- gemini
