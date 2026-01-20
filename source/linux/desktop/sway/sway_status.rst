.. _sway_status:

==========================
Sway环境状态栏优化
==========================

在 :ref:`sway_config` 中完成对桌面空间极致利用之后，按照Gemini建议，定制一个针对 :ref:`freebsd_sway` 优化的状态栏:

- 脚本直接利用FreeBSD的系统工具( ``sysctl`` 和 ``date`` )来获取信息，无需第三方工具，响应最快
- 考虑到我使用的 :ref:`thinkpad_x220` 硬件很弱，直接通过 ``sysctl`` 获取内核信息能够降低负载，并适当延长采样周期(5秒)

状态脚本
===========

- 配置 :ref:`freebsd` 专用脚本:

.. literalinclude:: sway_status/status.sh
   :language: bash
   :caption: ``~/.config/sway/status.sh``

脚本运行环境要求
----------------------

- 状态脚本通过 ``sysctl`` 获取内核信息，需要内核支持ACPI:

  - ``acpi_ibm`` ThinkPad专用支持
  - ``acpi_dock`` 处理ThinkPad底座热插拔
  - ``acpi_video`` 调节屏幕亮度
  - ``coretemp`` 虽然不是 ACPI 模块，但它提供 sysctl 读取 CPU 每个核心的精确温度

为确保系统启动时加载上述内核模块，需要配置 ``/boot/loader.conf`` :

.. literalinclude:: sway_status/loader.conf
   :caption: 配置系统启动时加载ACPI相关模块

另外，为确保CPU能够动态调节频率(对 :ref:`thinkpad_x220` 续航至关重要)，需要确保 ``/etc/rc.conf`` 中开启了 ``powerd`` 电源管理:

.. literalinclude:: sway_status/rc.conf
   :caption: 确保 ``/etc/rc.conf`` 启用了 ``powerd``

亮度调节
==========

sway默认的 config 配置是设置使用 ``brightnessctl`` 调节屏幕亮度，这要求系统安装 ``light`` 软件包。如果没有安装该软件包，也可以改成以下方式直接使用 ``sysctl`` 调节:

.. literalinclude:: sway_status/config
   :caption: 设置通过sysctl直接调整亮度

.. note::

   我的实践发现调整 :ref:`thinkpad_x220` 的亮度键， ``hw.acpi.video.lcd0.brightness`` 值确实变化，但是实际屏幕亮度却没有改变。暂时不知道怎么解决，以后再说

   我也没有找到如何安装 brightnessctl 方法
