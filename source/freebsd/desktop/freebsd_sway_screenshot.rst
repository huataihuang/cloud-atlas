.. _freebsd_sway_screenshot:

=================================
FreeBSD的Wayland环境(sway)截屏
=================================

之前在 :ref:`sway_screenshot` 实践中采用的是 :ref:`arch_linux` ，随着我转向 :ref:`freebsd_sway` ，再次配置和改进Wayland环境截屏方法:

软件安装
==========

- 安装截图工具组合:

.. literalinclude:: freebsd_sway_screenshot/install
   :caption: 安装截图工具

常用的截图命令有:

.. literalinclude:: freebsd_sway_screenshot/cmd
   :caption: 常用截图命令

swappy标注
============

为了方便 ``swappy`` 标注图片并保存到指定目录，配置 ``~/.config/swappy/config`` :

.. literalinclude:: freebsd_sway_screenshot/swappy_config
   :caption: ``~/.config/swappy/config`` 设置
