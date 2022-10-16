.. _mobile_cloud_asahi:

====================
移动云Asahi Linux
====================

如 :ref:`mobile_cloud_infra` 所规划的，我采用 :ref:`apple_silicon_m1_pro` MacBook Pro来构建底层服务器硬件。由于Apple Silicon M1 Pro处理器是ARM架构，硬件比较封闭，所以社区推出来 :ref:`asahi_linux` 针对Apple Silicon处理器优化，能够非常平滑安装和使用。

应用软件安装
===============

我选择了mini安装，也就是字符界面，所以需要再按需安装一些应用以及简单配置::

   pacman -S sudo mlocate

- 设置 sudo ::

   echo "huatai ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

安装图形界面
=================

在选择移动云计算的图形管理系统，我考虑:

- 轻量级: 占用最少的系统资源，将所有可用资源尽可能投入到虚拟化、容器构建的 :ref:`kubernetes` 和 :ref:`openshift` 系统中
- 无需复杂应用程序，只需要终端程序和浏览器程序

考虑到图形性能，首选 :ref:`wayland` 底层的窗口管理器: 虽然Gnome和KDE都已经适配了Wayland，但是过于复杂和沉重。而轻量级 :ref:`xfce` 还没有推出支持Wayland的版本。

综合先进性和轻量级，我选择再次挑战 :ref:`sway` 

不足和期待
===========

根据 `The first Asahi Linux Alpha Release is here! <https://asahilinux.org/2022/03/asahi-linux-alpha-release/>`_ 目前Asahi Linux还有一些关键硬件无法工作，也是非常期待的特性
