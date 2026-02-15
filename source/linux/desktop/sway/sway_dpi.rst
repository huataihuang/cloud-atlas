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

这里可以看到我的笔记本内置显示屏 ``'Apple Computer Inc Color LCD Unknown'`` 被命名为 ``eDP-1`` ，外接的显示器是 ``'AOC U28P2G6B PDRLBJA001352'`` 被命名为 ``DP-1``

对应配置 ``~/.config/sway/config`` 可以设置伸缩率:

.. literalinclude:: sway_dpi/sway_config
   :caption: 在 ``~/.config/sway/config`` 设置屏幕伸缩率

我在 :ref:`mba13_early_2014` (13.3-inch 分辨率1440x900)经过配置组合采用:

- sway配置 ``output scale`` 为 ``0.9`` 可以将title压缩到合适的比例
- :ref:`foot` 默认配置 ``font=monospace:size=8`` 在DPI伸缩为 ``0.9`` 最佳
- :ref:`firefox` 调整字体为 ``16`` 结合 :ref:`firefox_compact` 设置可以更好使用

上述配置在 :ref:`alpine_linux` 下实践成功，但是在 :ref:`freebsd_sway` 上的实践有些不同:

FreeBSD sway
===================

:ref:`freebsd_sway` 配置中设置 :ref:`thinkpad_x220` 屏幕(1366x768) 设置 ``scale 0.8`` 没有效果，始终和 ``scale 1.0`` 完全相同: 原因是X220的老核显(Intel HD 3000)在处理非标准DPI缩放是，硬件层面的支持有限

所以在配置 :ref:`freebsd_sway` 结合外接4k显示器时候采用了如下配置:

.. literalinclude:: sway_dpi/sway_config_freebsd
   :caption: FreeBSD Sway环境配置外接显示

上述配置对于sway桌面非常友好，例如 :ref:`foot` 显示字迹清晰完美，内置屏幕和外接4k显示器的字体显示相当，对于编程非常友好。

不过，由于内置屏幕dpi scale=1.0，对于firefox这样的UI程序看起来就比较粗笨，所以firefox需要单独调整应用的UI缩放比率，采用 :ref:`firefox_compact` 方法。只是firefox需要位于4k屏幕或本机显示屏，以便能够统一通过 ``ctrl+`` 或 ``ctrl-`` 来调整显示比例。

参考
======

- `archlinux wini: Sway <https://wiki.archlinux.org/title/Sway>`_
