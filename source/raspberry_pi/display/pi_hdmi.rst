.. _pi_hdmi:

================
树莓派HDMI配置
================

大多数情况下，只要简单把树莓派的HDMI接口插上HDMI连线连接到显示器，就能实现较为完美的适配。不过，需要注意， :ref:`pi_4` 虽然能够支持双显示器，但是只能在60Hz刷新率下实现1080p。如果使用4K显示器，并且连接2隔显示器，则最高只能达到30Hz刷新率。要实现真正的4k分辨率60Hz刷新率，需要:

- 显示器连接 ``HDMI 0`` 极恶口
- ``config.txt`` 中配置 ``hdmi_enable_4kp60=1``
- 使用支持HDMI 2.1的线缆以及4K显示器(废话)

如果运行3D图形驱动(也称为 ``FKMS`` 驱动)，则在 ``Perferences`` 菜单能够找到一个图形应用来设置标准显示器以及多显示器设置。

.. note::

   屏幕配置工具 ``arandr`` 是一个选择显示模式和设置的哦显示器的图形工具，可以以从桌面 ``Perforences`` 彩带找到，但是只有使用3D图形驱动时才能提供更多设置功能。

HDMI Groups和Mode
==================

HDMI有两个常见组织: CEA(消费电子协会，也就是电视机使用的标准)和DMT(Display Monitor Timings(Timings怎么翻译？)，也就是显示器所使用的标准)。每个组织都有自己建议的模式，也就是分辨率，刷新率，时钟频率以及输出的特定比例。

设备支持模式
-------------

对于使用 ``fkms`` 显示驱动的树莓派，可以使用 ``tvservcie`` 应用程序来检测设备:

- ``tvservice -s`` 显示当前HDNI状态，包括mode和分辨率
- ``tvservice -m CEA`` 显示支持的所有CEA模式
- ``tvservice -m DMT`` 显示所有支持的DMT模式

我在使用 Raspberry Pi OS时配置了 ``vc4-kms-v3d`` 驱动，按照提示 ``tvservice -s`` 不支持，需要使用 ``tvservice -m DMT`` 软件包提供的类似工具 ``modetest`` ::

   apt install libdrm-tests -y

然后按照 ``modetest --help`` 提示的方法，执行以下命令检查显示器支持模式::

   modetest -c

可以俺看到我的显示器 ``AOC`` 4K 支持::

   ...
   41      40      connected       HDMI-A-2        620x340         37      40
     modes:
           index name refresh (Hz) hdisp hss hse htot vdisp vss vse vtot
     #0 3840x2160 30.00 3840 4016 4104 4400 2160 2168 2178 2250 297000 flags: phsync, pvsync; type: driver
     #1 3840x2160 29.97 3840 4016 4104 4400 2160 2168 2178 2250 296703 flags: phsync, pvsync; type: driver
     #2 3840x2160 29.98 3840 3888 3920 4000 2160 2163 2168 2191 262750 flags: phsync, nvsync; type: driver
     #3 3840x2160 25.00 3840 4896 4984 5280 2160 2168 2178 2250 297000 flags: phsync, pvsync; type: driver
     #4 3840x2160 24.00 3840 5116 5204 5500 2160 2168 2178 2250 297000 flags: phsync, pvsync; type: driver
     #5 3840x2160 23.98 3840 5116 5204 5500 2160 2168 2178 2250 296703 flags: phsync, pvsync; type: driver
   ...

设置特定HDNI Mode
~~~~~~~~~~~~~~~~~~~

通过 ``config.txt`` 配置的 ``hdmi_group`` 和 ``hdmi_mode`` 可以制定特定模式

- ``hdmi_group``

.. csv-table:: hdmi_group 设置
   :file: pi_hdmi/hdmi_group.csv
   :widths: 40, 60
   :header-rows: 1

- ``hdmi_mode``

.. note::

   树莓派官方文档提供了 ``hdmi_mode`` 针对 ``CEA`` 和 ``DMT`` 组织的不同 ``hdmi_mode`` ，但是，实际上购买的显示器分辨率可能没有覆盖。例如我的AOC显示器 ``AOC U28P2U/BS 28英寸4K`` 显示器，分辨率是 ``3840*2160`` ，刷新率60Hz，Aspect Ratio: 16:9

没有在预定义的 ``hdmi_mode`` 列表，所以需要使用 ``Custom Mode`` 也就是 ``hdmi_cvt``

- 自定义分辨率(请根据自己的显示器参数设置，以下是我的 ``AOC U28P2U/BS 28英寸4K`` ::

    hdmi_cvt=3840 2160 60 3 0 0 0

.. csv-table:: hdmi_cvt=<width> <height> <framerate> <aspect> <margins> <interlace>
   :file: pi_hdmi/hdmi_cvt.csv
   :widths: 20, 20, 60
   :header-rows: 1

- 更为细节的设置是 ``hdmi_timings`` ，需要根据显示器的具体参数进行调

参考
========

- `树莓派官方config.txt#HDMI Configuration <https://www.raspberrypi.com/documentation/computers/configuration.html#hdmi-configuration>`_
