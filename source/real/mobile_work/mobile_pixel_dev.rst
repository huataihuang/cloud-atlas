.. _mobile_pixel_dev:

========================================
移动开发:Pixel手机(Android)开发环境构建
========================================

:ref:`mobile_work_think` 中，我最想实践的是采用 :ref:`pixel_3` 来实现精简的 :ref:`android` 系统，实现一个移动的 :ref:`linux` 工作环境

root Android
=============

为了能够更好使用我的 :ref:`pixel_3` ，采用以下步骤:

- :ref:`unlock_bootloader` 以便刷入第三方OS
- :ref:`root_pixel` 以便释放所有的能力
- :ref:`lineageos_19.1_pixel_3`

  - :strike:`编译LineageOS系统` (目前无精力)
  - :strike:`刷入自己编译的LineageOS系统` (目前无精力)

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
