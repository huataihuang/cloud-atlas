.. _sakura:

================
sakura
================

Sakura (樱花)是一个仅仅基于GTK+和VTE的轻量级终端模拟器。由于Sakura依赖极少，所以启动和运行极快，特别适合轻量级桌面使用:

- 不依赖完整的GNOME桌面: 只需要VTE和GTK+
- 配置简单: 仅通过简单的上下文菜单就能够设置基本选项(在终端上右击鼠标，就可以在层级菜单选择配置，配置会自动保存到 ``~/.config/sakura/sakura.conf`` )
- 没有任何花哨的功能，纯粹的终端模拟器

Sakura终端模拟器的上述特性，使得它可以用于任何图形桌面。并且由于其基于GTK，也解决了目前 :ref:`gentoo_sway_fcitx_native_wayland` 无法显示中文候选字的问题(因为 :ref:`fcitx` 对于X+GTK支持输入，可以绕开当前 :ref:`sway` 对中文输入候选字显示的问题)

使用
=========

- Sakura终端模拟器支持tabs功能，和Kconsole，Gnome-Terminal等终端模拟器完全一样:

  - ``Shift+ctrl+t`` 添加tab
  - ``Shift+ctrl+w`` 关闭tab
  - ``Shift+ctrl+Left`` 切换前一个tab
  - ``Shift+ctrl+Right`` 切换后一个tab

- 修改字体大小:

  - ``Shift+Ctrl+Plus`` 增加字体大小
  - ``Shift+Ctrl+Minux`` 减少字体大小

- 终端色彩: 可以通过上下文菜单来选择终端色彩配置，不过我没有尝试，默认配置我觉得够用

- 对于 :ref:`linux_chinese_view` 安装的中文字体 ``fonts-wqy-microhei`` ，非常适合选择作为Sakura终端字体，方便在 :ref:`nvim` 这样编辑器中用于代码开发(中文注释)

- Sakura终端模拟器通过上下文菜单修改的配置会自动保存到 ``~/.config/sakura/sakura.conf`` ，所以通常不需要手工编辑配置

总之，作为轻量级终端模拟器，依赖极少，对于中文友好，Sakura终端模拟器可能是目前较为均衡优势的选择。

参考
============

- `Sakura – terminal emulator based on GTK and libvte <https://www.linuxlinks.com/Sakura/>`_
- `Sakura: The Versatile Terminal Emulator <http://www.troubleshooters.com/linux/sakura.htm>`_
