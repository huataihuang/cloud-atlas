.. _android_mobile_work_solutions:

=========================
Android移动工作解决方案
=========================

我对于 :ref:`mobile_work_think` 是采用智能手机来实现绝大多数开发运维工作，这里涉及到如何使用 :ref:`android` 或 :ref:`iphone` 。Android由于相对较为开放，能够运行完整Linux系统，可以更为方便构建工作桌面，所以我重点采用 :ref:`pixel_3` 作为移动工作平台。

有线投屏
==========

:ref:`android_displayport` 有以下要求:

- 使用第三方Android镜像(内核开启 ``Alternate Mode over USB-C`` )
- 使用 usb-c to HDMI 联线

待实践

无线投屏
===========

Android系统支持 ``chromecast`` 功能，需要找一个支持这个协议的硬件设备。

我在淘宝上购买了 :strike:`绿联无线投屏器` (已退货) ，但是实践 :ref:`airplay_ugreen` 成功，却无法在 :ref:`pixel_3` 的原生Android 12上使用: ``镜像投屏`` 功能始终找不到设备。观看绿联提供的视频 `绿联无线投屏器连接手机电视操作方法丨CM242 <https://www.lulian.cn/news/382-cn.html>`_ 似乎是以华为手机为案例，也许国产手机采用了其他魔改的投屏方式。

.. warning::

   强烈建议不要购买国产 ``正规`` 无线投屏设备(例如我购买的 ``绿联无线投屏器`` )，因为它 ``完全`` 屏蔽了在中国无法访问的视频资源，例如 Apple TV (虽然GFW没有屏蔽Apple TV)。

Termux + 电脑
================

:ref:`termux` 是Android系统上非常强大的终端模拟器，同时也是完整的Linux系统安装架构，可以通过 :ref:`apt` 安装所需的Linux工具实现 :ref:`termux_dev` 环境，可以成为一个移动的Linux工作站。
