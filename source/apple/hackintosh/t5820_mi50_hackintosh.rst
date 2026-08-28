.. _t5820_mi50_hackintosh:

========================================
Dell T5820+AMD MI50 GPU运行Hackintosh
========================================

:ref:`amd_mi50` 作为数据中心计算卡，原本是不能用于桌面系统，也无法用于 Hackintosh 的。但是，AMD的这块数据中心卡，实际上和 Redaon Pro V420 是相同的核心，并且在产品设计和制造上，复用了很多相同设计:

- 保留了一个mini display接口，并且内部显示电路完全具备，能够通过这个显示接口输出
- 和 Redaon Pro V420 32GB的VBIOS通用，所以通过 :ref:`amd_mi50_flash_vbios` 能够切换成Pro V420，功耗TDP从300W下降到178W

在我的一次 :ref:`amd_rx580` 矿卡翻车之后，我决定用这块数据中心计算卡转换成图形卡，一方面解决我的 :ref:`mbp15_late_2013` :ref:`oclp_macos` 存在的软驱动性能问题，另一方面也是为了能够玩 :ref:`x-plane` 和 :ref:`blender` 这类对显卡要求极高的应用。

准备工作
==========

首先当然是通过 :ref:`amd_mi50_flash_vbios` 将没有显示输出的计算卡转换成真正的高性能显卡，并且我也验证了 :ref:`dell_t5820_gpu` 支持了转换后的MI50。

其次，:ref:`amd_mi50` 是机架服务器使用的计算卡，没有主动散热风扇，所以需要 :ref:`amd_mi50_shroud` 才能安装到台式主机或工作站。

macOS的补丁改造
=================

当前我的 :ref:`mbp15_late_2013` 已经安装了 ``OCLP (OpenCore Legacy Patcher)`` ，并针对我的MacBook Pro老款硬件做了补丁的引导，这和我将要迁移到的Dell T5820(Xeon W / C422 平台)的黑苹果引导存在冲突。要实现无缝平滑迁移，需要执行改造。

在 MacBook Pro 上还原系统补丁(关键)
-----------------------------------------

MacBook Pro Late 2013 由于 CPU 和核显（Haswell / Kepler）太老，OCLP 在系统里注入了针对老旧显卡的 Root Patch（根目录图形补丁）。这些旧驱动会干扰 :ref:`amd_mi50` 在新平台上的原生 Metal 加速。

- 打开 ``OpenCore Legacy Patcher`` 软件
- 点击 ``Post-Install Root Patch`` -> 选择 ``Revert Root Patches`` （撤销根目录补丁）
- 撤销完成后关机，此时 macOS 系统卷恢复到了最纯净的官方原生状态。

制作/准备适用于 Dell T5820 的黑苹果 EFI
-------------------------------------------

**不能使用 MBP 上的 EFI** 需要在 USB 闪存盘或 NVMe 的 EFI 分区中，放置一套针对 T5820 架构 **定制的 OpenCore EFI**

- **机型模版（SMBIOS）** : 推荐设置为 ``MacPro7,1`` （Mac Pro 2019）。因为 2019 款 Mac Pro 本身使用的就是 Intel Xeon W 系列处理器 + AMD Radeon 独显，与 T5820 的硬件架构 99% 契合。
- 核心 Kexts 驱动:

  - Lilu.kext + VirtualSMC.kext（基础框架）
  - 显卡驱动(待定)
  - CpuTscSync.kext (HEDT/Xeon 平台必带，用于同步多核 CPU 线程，否则会卡死死机)
  - IntelMausi.kext (驱动 T5820 板载 Intel i219-LM 千兆网卡)
  - AppleALC.kext (板载声卡驱动)
  - NVMeFix.kext (优化非苹果原装 NVMe 功耗与性能)

- 必备 ACPI 补丁 (SSDTs)

  - SSDT-PLUG（Xeon 核心电源管理）
  - SSDT-EC-USBX（嵌入式控制器与 USB 供电）
  - SSDT-RTC0（解决 C422 主板 RTC 时钟冲突）
  - SSDT-UNC（禁用 HEDT 未使用的 Uncore 区域，防止卡 panic）

待续...



