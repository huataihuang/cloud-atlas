.. _mobile_pixel_dev:

========================================
移动开发:Pixel手机(Android)开发环境
========================================

:ref:`mobile_work_think` 中，我最想实践的是采用 :ref:`pixel_3` 来实现精简的 :ref:`android` 系统，实现一个移动的 :ref:`linux` 工作环境

配套设备
============

作为移动开发设备， :ref:`pixel_3` 具有强大的扩展性，但是，小屏手机虽然便于携带，输入输出却不尽人如意，所以我们需要合适的扩展设备:

- :ref:`chromecast` 提供将手机屏幕投射到大屏幕显示器上的能力
- 蓝牙键盘和蓝牙鼠标: Android内置支持蓝牙键盘和鼠标，所以一旦配对之后，就非常方便进行文字输入

只需要携带非常轻巧的 :ref:`chromecast` 以及便携蓝牙键盘和鼠标，就可以非常方便移动开发。当然如果周围不容易知道显示器，例如咖啡馆，则可以购买一个廉价的15寸便携显示器(大约1k人民币)。汗，这样不是和携带笔记本没有差别了么？所以，我觉得还是直接使用手机屏幕，采用 :ref:`termux` 作为简单的Linux环境，能够远程登陆到服务器，使用 :ref:`vim`
进行开发，已经能够满足大多数工作场景。

root Android
=============

为了能够更好使用我的 :ref:`pixel_3` ，采用以下步骤:

- :ref:`unlock_bootloader` 以便刷入第三方OS
- 使用 :ref:`magisk` 解锁手机root (之前采用旧版的 :ref:`root_pixel` )
- :ref:`lineageos_20_pixel_4` (之前使用 :ref:`lineageos_19.1_pixel_3` )

  - :ref:`build_lineageos_20_pixel_4`
  - :ref:`lineageos_20_pixel_4`

- 安装 :ref:`magisk` 对设备进行root - :ref:`magisk_root_ota` (在Pixel系列现代化设备，无法使用传统的 :ref:`twrp` ，必须使用 :ref:`adb` 和 fastboot)

- :ref:`pixel_3_chinese_volte` (重要配置，激活VoLTE才能正常使用 :ref:`pixel_3` )

Magisk
------------

- 下载和安装最新版本 `Magisk app <https://github.com/topjohnwu/Magisk/releases/latest>`_

Termux
========

Termux可以将Android系统扩展成运行完整Linux系统的工作开发平台:

- :ref:`termux_install`
- :ref:`termux_dev`
