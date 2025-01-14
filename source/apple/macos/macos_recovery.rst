.. _macos_recovery:

======================
macOS 恢复安装
======================

.. note::

   我发现总是会有重装macOS的需求，虽然已经安装过很多次，并且我也已经撰写过 :ref:`create_boot_usb_from_iso_in_mac` 通过安装U盘来安装系统。不过，很多时候，最方便的重装方法是采用苹果提供的 ``internet recovery`` 方式，也就是通过网络重装恢复。这样，就不需要自己制作安装光盘或安装U盘。

苹果提供的 ``internet recovery`` 是最方便快捷的安装方法，关键点是在启动时选择快捷键组合，所选的快捷键决定了你恢复安装的操作系统版本:

- 最新的Apple silicon芯片的电脑启动时 **不需要按组合键** ，而是 ``长按电源键`` ，此时启动页面会显示 ``Options`` 弦线，点按这个 ``Options`` 选项就能够选择Recovery install
- 早期的Intel 处理器Mac电脑启动时 **通过组合键** 选择不同的安装恢复模式:

  - ``Command-R`` 恢复安装最近安装的macOS版本
  - ``Option-Command-R`` 恢复安装和硬件兼容的最新(最高)macOS版本
  - ``Shift-Option-Command-R`` 恢复安装购买Mac电脑时随主机提供的macOS版本(通常比较旧)，但是有可能苹果官网已经下线安装镜像而无法安装

.. note::

   命令行进入Recovery Mode的方法是:

   .. literalinclude:: macos_recovery/recovery_mode
      :caption: 命令行进入recovery模式

   在Recovery Mode中完成维护工作，则执行以下命令删除firmware变量，这样下次重启就进入常规启动模式:

   .. literalinclude:: macos_recovery/normal_mode
      :caption: 命令行恢复常规启动模式

其他修复相关启动组合键
========================

Intel芯片的Mac电脑还提供了一些启动组合键:

- ``Option/Alt`` 启动时选择不同的启动盘或启动卷
- ``Option-Command-P-R`` Reset NVRAM 或 PRAM
- ``Shift (⇧)`` 进入安全模式启动
- ``D`` 启动进入Apple诊断工具，如果使用 ``Option-D`` 启动组合键，则从Internet启动诊断工具
- ``N`` 从NetBoot服务器启动( `Create a NetBoot, NetInstall, or NetRestore volume <https://support.apple.com/en-us/101676>`_ )
- ``Command-V`` 启动进入verbose模式
- ``Eject (⏏) or F12 or mouse button or trackpad button`` 弹出移动介质，例如光驱中的光盘

``2003F`` 报错
===============

由于internet recovery非常依赖internet连接，所以我发现现在(2024年)非常容易在恢复过程中出现异常中断(现象是网络流量停止)，而且即使使用了VPN也不能解决问题。此时安装洁面会出现 ``apple.com/support - 2003F``

这个 ``2003f`` 报错和网络连接稳定性有关( `Understanding Mac Error 2003f and How to Resolve It <https://www.macobserver.com/tips/how-to/mac-error-2003f-resolve-it/>`_ )，我最终实在没有办法，是预约了苹果Genius到Apple维修中心连接维修中心的网络才顺利完成Internet recovery。总之，现在非常折腾。

参考
=========

- `How to reinstall macOS <https://support.apple.com/en-us/HT204904>`_
- `Mac startup key combinations <https://support.apple.com/en-us/102603>`_
