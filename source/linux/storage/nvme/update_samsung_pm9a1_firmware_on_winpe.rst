.. _update_samsung_pm9a1_firmware_on_winpe:

==============================================
在WinPE环境更新Samsung PM9A1 firmware
==============================================

我的 :ref:`mbp15_late_2013` 已经使用了12年了，期间应为原装SSD存储损坏，我更换了 :ref:`samsung_pm9a1` 第三方SSD，虽然初步测试没有遇到问题(不影响休眠)，但是我最近一次重新安装macOS Big Sur时，意外发现系统启动非常缓慢、应用程序启动慢、编译 :ref:`sphinx_doc` 缓慢，虽然多次尝试 :ref:`fix_macbook_slow` 并最终偶然恢复，但是推断下来的原因是 :ref:`samsung_pm9a1` 早期firmwarm在非原生系统下会导致严重的性能衰减:

- 卡顿原理： macOS 会在空闲时或启动时清理无效块。如果固件不兼容，主控会锁死总线进行垃圾回收，此时系统 UI 就会失去响应（彩虹球）。
- 验证方法： 在 System Information -> NVMExpress 检查 Firmware Revision，我的版本是 ``GXA7601Q`` ，gemini告知我这是一个中期过渡版本，还是存在缺陷隐患(APFS Trim 时存在显著的响应延迟，在某些负载下会出现 写入速度减半 或 读取性能大幅波动 的缺陷)需要升级

我在Linux环境下尝试 :ref:`update_samsung_pm9a1_firmware` 失败，最近为了解决 :ref:`oclp_macos` 潜在的硬件风险，我决定为 :ref:`mbp15_late_2013` 升级 :ref:`samsung_pm9a1` firmware，以彻底解决macOS环境下因为Trim缺陷卡顿的问题。这次为了绕开Linux下升级困难，我决定简化为采用 :ref:`winpe` 环境来运行Windows下的Samsung PM9A1 firmware更新程序。

