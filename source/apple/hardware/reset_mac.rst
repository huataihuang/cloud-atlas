.. _reset_mac:

====================
Mac设备重置
====================

如果你的Mac系统出现一些和硬件有关的莫名问题，可以尝试进行硬件reset来排查解决。

reset NVRAM
=============

感觉已经使用了7、8年的2011年版MacBook Air 11' 似乎触摸板不太灵敏，非常容易飘动或者完全没有反应。

参考 `Macbook air更新Mojave之后触控板失灵 <https://bbs.feng.com/read-htm-tid-11940440.html>`_ 介绍的重置NVRAM方法，我验证下来对于触摸板失灵比较有效：

- Mac 关机
- 开机，并立即按下四个案件： ``Option`` ``Command`` ``P`` ``R``
- 此时笔记本会在启动后再次发出`嘟`的一声，然后再次重启。保持按住四键不放，系统会再次发出 ``嘟`` 的一声，然后再次重启。
- 如此保持三次启动声后松开这些按键。

目前感觉这个方法是有效的，如果不是硬件损坏，这个功能可能能够挽救触摸失灵的MagicPad触摸板。

reset SMC
===========

苹果官方提到 `If you can’t install macOS Big Sur on certain 13-inch MacBook Pro computers from 2013 and 2014 <https://support.apple.com/en-us/HT211242>`_ 需要执行 `reset the SMC <https://support.apple.com/kb/HT201295>`_ (以下步骤为无T2安全芯片的旧款Mac重置SMC方法，新款请看原文):

- 关闭Mac
- 在笔记本内建键盘上同时按下以下按键:

  - 键盘左方的 ``Shift``
  - 键盘左方的 ``Control``
  - 键盘左方的 ``Option(Alt)``

- 在以上3个按键同时按住情况下，按下并保持按住 ``电源按键`` : 同时保持按住4个按键 10 秒钟
- 放开所有按键，然后按下 ``电源按键`` 启动Mac

.. figure:: ../../_static/macos_ios/studio/2016-macbook-keyboard-diagram-smc.png
   :scale: 40

我准备尝试reset SMC方法来解决安装问题，如果不能解决，我准备恢复安装上一个 Catalina版本。

.. note::

   重置系统管理控制器(system management controller, SMC)可以解决很多与电源、电池、风扇等功能相关的问题。
