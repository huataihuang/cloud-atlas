.. _wayland_qt:

===================
Wayland环境QT应用
===================

在 :ref:`pi_400` 上安装 Raspberry Pi OS for ARM 64系统，为了精简系统，采用 :ref:`wayland` 图形服务上运行的 :ref:`sway` ，对应用有特定运行配置要求：

在运行QT5应用时，例如 :ref:`fcitx` 配置工具 ``fcitx5-config-qt`` 启动报错::

   qt.qpa.xcb: could not connect to display :0
   zsh: segmentation fault  fcitx5-config-qt

解决方法是需要向QT应用传递环境变量 ``QT_QPA_PLATFORM=wayland`` ，所以修改 ``/etc/environment`` ::

   QT_QPA_PLATFORM=wayland

然后再次运行QT应用就正常

参考
======

- `running virtualbox under Wayland and sway <https://bbs.archlinux.org/viewtopic.php?id=270531>`_
