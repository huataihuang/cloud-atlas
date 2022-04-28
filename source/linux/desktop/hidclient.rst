.. _hidclient:

=====================================
Linux主机转换成蓝牙键盘鼠标hdiclient
=====================================

2022年4月，上海封城已20天...在家办公遇到非常麻烦的事情:原先屏幕损坏的MacBook Pro笔记本电脑外接显示器连线损坏。这样，我不得不放弃使用 :ref:`macos` ，改为采用 :ref:`run_sway` ( :ref:`pi_400` 硬件 )。

但是，由于工作需要，一些应用如案件没有Linux版本，需要在 :ref:`android` 或者 iOS 系统上的软件。考虑到视频会议需要，主要使用iOS系统的iPad。不过，平板的输入效率非常低，如果配备独立的蓝牙键盘，那么每次双手从 :ref:`pi_400` 上移动到iPad的蓝牙键盘再移回来，非常繁琐无聊。

解决的思路就是，使用 :ref:`pi_400` 主机的蓝牙功能，将键盘输入转换成蓝牙信号转发给通过蓝牙连接的设备，这样就好像主机是一个独立的蓝牙键盘，方便平板设备输入。

.. note::

   本文思路目前尚未实现，原因是早期的 ``hidclient`` 所使用的库 ``stropts.h`` 已经被废除支持，无法完成编译。后续我再考虑如何接解决这个问题...

转换主机作为蓝牙输入设备
==========================

``hidclient`` 是一个将主机作为其他设备的蓝牙键盘和鼠标的应用程序。本地链接的输入设备的输入事件(例如键盘按击和鼠标移动)被抓发给蓝牙连接的其他主机。被连接的移动设备无需越狱，也不需要安装任何特殊应用。

.. note::

   ``hidclient`` 已经不再开发，源代码现在可以从 github 上Fork的项目 `benizi/hidclient <https://github.com/benizi/hidclient>`_ 获取

编译hidclient
==============

- 安装编译库依赖::

   sudo apt install libbluetooth-dev

- 下载源代码::

   git clone https://github.com/benizi/hidclient.git

- 编译::

   cd hidclient
   make

编译错误处理
-------------

- 没有 ``stropts.h`` ::

   dclient.c:105:10: fatal error: stropts.h: No such file or directory
     105 | #include <stropts.h>
         |          ^~~~~~~~~~~
   compilation terminated.
   make: *** [Makefile:2: hidclient] Error 1
  
参考 `How do I install libraries for <stropts.h>? <https://stackoverflow.com/questions/61029226/how-do-i-install-libraries-for-stropts-h>`_ :

``stropts.h`` 是Posix STREAMS扩展的部分，Linux不支持这个库(从2008年开始，已经被posix标记为废弃)，虽然有一些第三方STREAMS实现，但是可能不解决问题。

我暂时没有时间精力解决这个问题，后续看需求是否能通过修正代码来解决。

参考
=======

- `How do I make Ubuntu appear as a bluetooth keyboard? <https://askubuntu.com/questions/229287/how-do-i-make-ubuntu-appear-as-a-bluetooth-keyboard>`_
- `How to share Keyboard and Mouse Via Bluetooth? (Like in windows Control) <https://askubuntu.com/questions/404149/how-to-share-keyboard-and-mouse-via-bluetooth-like-in-windows-control>`_
