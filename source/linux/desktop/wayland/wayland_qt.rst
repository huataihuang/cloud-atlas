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

我在 :ref:`archlinux_on_mba` 上部署 :ref:`archlinux_sway` ，运行 ``keepassxc`` 程序，再次遇到类似报错:

.. literalinclude:: wayland_qt/qt_platform_plugin_wayland_error
   :caption: 在 Wayland 环境运行Qt程序报错，显示无法找到Qt平台插件"wayland"
   :emphasize-lines: 1-3

此时，在 ``$HOME/.bashrc`` 中添加如下 ``QT_QPA_PLATFORM`` 环境变量:

.. literalinclude:: wayland_qt/bashrc
   :caption: 添加 ``QT_QPA_PLATFORM`` 环境变量

报错信息有所减少，但是依然显示没有platform plugin:

.. literalinclude:: wayland_qt/qt_platform_plugin_wayland_error_1
   :caption: 设置 ``QT_QPA_PLATFORM`` 环境变量后依然报没有找到Qt平台插件"wayland" 
   :emphasize-lines: 1

不过，可以看到 xcb 连接错误消失了，情况有改善，但是还是说明应用程序以来的 ``QT`` wayland 没有安装。那么是哪个软件包呢?

检查当前系统已经安装的QT相关软件包:

.. literalinclude:: wayland_qt/query_packages_qt
   :caption: 检查系统已经安装了那些QT包

输出如下:

.. literalinclude:: wayland_qt/query_packages_qt_output
   :caption: 检查系统已经安装的QT包，可以看到只有 ``qt6-wayland`` 但是没有 ``qt5-wayland``
   :emphasize-lines: 9

- 则尝试安装 ``qt5-wayland`` :

.. literalinclude:: wayland_qt/install_qt5-wayland
   :caption: 安装 ``qt5-wayland``

果然，安装了 ``qt5-wayland`` 补齐了 ``KeePassXC`` 运行依赖，就能够正常运行

参考
======

- `running virtualbox under Wayland and sway <https://bbs.archlinux.org/viewtopic.php?id=270531>`_
- `Could not find the Qt platform plugin "wayland" <https://unix.stackexchange.com/questions/598099/could-not-find-the-qt-platform-plugin-wayland>`_
