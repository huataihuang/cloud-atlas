.. _sway_macbook_key:

=========================
sway桌面配置MacBook按键
=========================

在MacBook上都有一排快捷功能键，如果能够结合到 :ref:`sway` 的 ``bindsym`` 快捷键配置中，就能帮助实现直观的控制功能:

- 音量调节
- 屏幕亮度调节
- 媒体播放控制

怎么能够找到按键的对应字符串呢？方法类似X Window的 ``xev`` 工具，使用面向 :ref:`wayland`  的 :ref:`wev` 即可。

从 ``wev`` 获得以下字符串:

.. literalinclude:: sway_macbook_key/macbook_key
   :caption: 通过 ``wev`` 工具获得的MacBook功能键对应字符串

配置屏幕亮度调节
==================

参考 `Apple Macbook Pro Retina (early 2013) <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina_(early_2013)>`_ 中调节 ``Display backlight`` 方法，准备一个简单脚本 ``bl-brightness`` (我存放到 ``~/bin`` 目录下):

.. literalinclude:: sway_macbook_key/bl-brightness
   :language: bash
   :caption: 控制屏幕背光脚本

- 配置 ``~/.config/sway/config`` 添加调节快捷键:

.. literalinclude:: sway_macbook_key/config
   :caption: ``~/.config/sway/config``



