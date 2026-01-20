.. _sway_config:

======================
sway配置
======================

对于 12.5 英寸、分辨率1366x768 的小屏 :ref:`thinkpad_x220` ，每个像素的空间都弥足珍贵。既然我选择sway，就需要通过微调来实现极致的紧凑布局。

窗口标题栏
=============

首先想到的是缩减窗口标题栏字体，默认的字体在小屏上过大导致窗口标题栏非常"厚重"，Google Gemini建议调整全局字体，使用较小的等宽字体:

.. literalinclude:: sway_config/font
   :caption: 配置 ``~/.config/sway/config`` 调整全局字体

说明:

- ``titlebar_padding <horizontal> [<vertical>]`` 设置文字左右两侧和上下两侧的像素间距，当设置为1时候极致压缩标题栏(变窄)，紧贴字体大小
- ``titlebar_border_thickness 0`` 是为了处理特定布局(Stacked堆叠模式或Tabbed标签模式)标签页的边框彻底去除

上述简单调整全局字体确实有效，能够将标题栏和状态栏都缩减宽度。但是有一个不足是由于全局生效，就不能分别调整状态栏和窗口标题栏字体。实际上我希望将窗口标题栏完全去除，但是保留状态栏信息显示(因为当前桌面编号，当前时间，当前系统负载等信息需要在状态栏观察)

隐藏标题栏
===============

`How can I remove the tittle bar? #6946 <https://github.com/swaywm/sway/issues/6946>`_ 提供了一个将标题栏完全移除的方法:

.. literalinclude:: sway_config/remove_title_bar
   :caption: 移除标题栏

说明:

- 现在字体不再支持设置为 ``0`` ，所以这里使用了一个非常小的数值 ``0.001``
- 这里保留 ``border`` 一个像素宽度是为了能够在窗口聚焦激活时保留一个蓝色的边框，方便和其他没有聚焦的窗口区别。当然也可以设为0(如果都是 :ref:`foot` 终端平铺不太好区分边界)
- ``smart_borders on`` 表示如果只有一个窗口，则自动关闭边框

压缩间隙
=========

为了压缩窗口之间的间隙，可以设置 ``gaps`` :

.. literalinclude:: sway_config/remove_gaps
   :caption: 移除窗口之间的间隙

说明:

- ``smart_gaps on`` 表示如果只有一个窗体，自动关闭外间距(Gaps)

状态栏
==========

在上述窗体配置完成后，其实主要是全局字体设置为 ``0.001`` 之后，会看到状态栏上 **所有文字消失** 。实际上是因为全局字体影响，导致状态栏字体也缩小到看不见了。

解决的方法是在配置文件中，对 ``bar`` 段落单独设置字体，并且可以设置为自动隐藏，仅在按下Mod键时候显示

.. literalinclude:: sway_config/bar
   :caption: 配置 ``bar`` 独立字体并设置为自动隐藏
   :emphasize-lines: 2,7-9,21

说明:

- 单独设置bar字体可以避免全局字体设置 ``0.001`` (隐藏title) 导致状态栏文字消失
- ``mode hide`` 等3行配置设置状态栏自动隐藏，并且在按下 ``Mod4`` 键时显示
- ``strip_workspace_numbers yes`` 去除状态栏内部模块的间隙

完整配置案例
=============

综上，完整配置案例:

.. literalinclude:: sway_config/config
   :caption: 完整 ``~/.config/sway/config``

参考
======

- 本文根据Google Gemini提供的方案经过实践验证后整理，真实可复现
