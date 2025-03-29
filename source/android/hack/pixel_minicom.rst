.. _pixel_minicom:

======================================
使用Pixel运行minicom(串口调试服务器)
======================================

和 :ref:`pixel_uart` 相反(方向)，我想使用 :ref:`pixel_4` 作为一个 :ref:`mobile_pixel_dev` ，通过 :ref:`pi_5_uart` 访问树莓派终端。这样，在旅途中，即使没有显示器，我也能够连接和使用 :ref:`pi_5` 进行 :ref:`mobile_work` 。

硬件设备
===========

- 具有控制器的USB拨号modem(也就是 ``Raspberry Pi 5代 UART串口通信模块调试器`` ，我在淘宝上买的)
- OTG转接头(我在淘宝上买了一个绿联usb转type-c otg转接头)

软件
======

- 先安装 :ref:`termux`
- 在 ``termux`` 中安装 ``socat`` 和 ``minicom``

.. literalinclude:: pixel_minicom/socat_minicom
   :caption: 在 :ref:`termux` 中安装 ``socat`` 和 ``minicom``

- 在Android系统的Play Store中安装一个名为 ``TCPUART`` 的应用程序

运行
========

- 打开 ``termux`` 程序，执行以下命令，在 ``/ataa/data/com.termux/files/home/minicom/`` 目录(目录提前创建好)下创建一个 ``ttyS0`` 设备，连接到TCP服务器(也就是Android系统中的 ``TCPUART`` 创建的TCP服务:

.. literalinclude:: pixel_minicom/socat_connect
   :caption: 使用 ``socat`` 连接串口设备文件和TCP服务器

- 再在 ``termux`` 中执行 ``minicom`` :

.. literalinclude:: pixel_minicom/minicom
   :caption: 使用 ``minicom`` 连接桥接的TTY设备

参考
=======

- `Minicom on apk <https://www.reddit.com/r/androidapps/comments/uksj8g/minicom_on_apk/>`_
