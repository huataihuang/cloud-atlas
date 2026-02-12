.. _sway_dpi:

===================================
Sway桌面分辨率DPI(dots per inch)
===================================

- 检查当前输出屏幕的命名:

.. literalinclude:: sway_dpi/swaymsg
   :caption: ``swaymsg`` 提供了输出屏幕信息

输出类似:

.. literalinclude:: sway_dpi/swaymsg_output
   :caption: ``swaymsg`` 输出屏幕信息
   :emphasize-lines: 1

这里可以看到我的笔记本内置显示屏 ``'Apple Computer Inc Color LCD Unknown'`` 被命名为 ``eDP-1`` ，所以对应配置 ``~/.config/sway/config`` 可以设置伸缩率:

.. literalinclude:: sway_dpi/sway_config
   :caption: 在 ``~/.config/sway/config`` 设置屏幕伸缩率

我在 :ref:`mba13_early_2014` (13.3-inch 分辨率1440x900)经过配置组合采用:

- sway配置 ``output scale`` 为 ``0.9`` 可以将title压缩到合适的比例
- :ref:`foot` 默认配置 ``font=monospace:size=8`` 在DPI伸缩为 ``0.9`` 最佳
- :ref:`firefox` 调整字体为 ``16`` 结合 :ref:`firefox_compact` 设置可以更好使用

参考
======

- `archlinux wini: Sway <https://wiki.archlinux.org/title/Sway>`_
