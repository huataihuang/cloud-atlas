.. _airpods_firmware_update:

=========================
AirPods firmware更新
=========================

AirPods Pro 2代更新条件
=========================

- iOS需要16.x版本?(我的 :ref:`iphone_se1` 最高只能iOS 15.x，无法找到更新AirPods Pro 2代的入口)
- macOS需要macOS Ventura(目前尚未正式发布，我计划在正式发布后更新再来实践本文)
- AirPods在充电并且位于 iPhone (iOS 16?)，iPadOS 16.1的iPad或则macOS Ventura的Mac的蓝牙通信范围内， **固件会定期自动更新，所以苹果没有提供手工更新AirPods的方法**

检查AirPods固件版本:

- 安装最新版本的 iOS 16, iPadOS 16.1 以及 macOS Ventura的系统中，可以检查:

  - iOS/iPadOS: “设置”>“蓝牙”>“AirPods”。轻点“更多信息”按钮 ，然后向下滚动到“关于”部分以查找固件版本
  - macOS: 按住 Option 键点按 Apple 标志，然后选取“系统信息”。点按“蓝牙”，然后在“AirPods”下方查找固件版本。

.. note::

   已经验证，在我把 :ref:`apple_silicon_m1_pro` 的MacBook Pro操作系统升级到Ventura(macOS 13.0)。然后将AirPods Pro 2代连接电源充电，大约过了半小时再去看AirPods Pro的Firmware版本，发现确实已经升级到 最新的 ``5A377`` 。最近需要再使用看看是否解决了莫名短连和突然无法听清的问题。

参考
=====

- `About firmware updates for AirPods <https://support.apple.com/en-us/HT213317>`_
- `How to Update Your AirPods Pro’s Firmware: The Complete Guide <https://www.headphonesty.com/2022/08/update-airpods-pro/>`_
