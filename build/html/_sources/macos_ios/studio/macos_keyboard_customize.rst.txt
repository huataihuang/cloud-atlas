.. _macos_keyboard_customize:

=============================================
macOS 键盘定制工具Kakabiner-Elements
=============================================

在Linux桌面使61键机械键盘，有很多限制和不便，主要是常用键可能没有直接使用的方式。好在Linux平台可以通过  :ref:`xmodmap` ，在macOS上，则可以使用开源的 `Karabiner-Elements <https://karabiner-elements.pqrs.org>`_ 。

安装和使用非常方便，启动时首先要设置系统的 ``Security & Privacy`` 允许kakabiner监控键盘：

.. figure:: ../../_static/macos_ios/studio/karabiner_input_monitoring.png
   :scale: 75

然后就可以设置键盘的按键映射，而且可以针对不同键盘，例如这里Target device是我的61键机械键盘，显示为 ``USB DEVICE (SONiX)``

.. figure:: ../../_static/macos_ios/studio/karabiner_key_modify.png
   :scale: 75

通过这种方式，即使你的键盘内置定义方式比较少，你也可以通过这种方式实现Windows键盘和macOS键盘互换，方便按照习惯方式使用。
