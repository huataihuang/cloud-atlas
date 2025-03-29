.. _intro_waydroid:

===================
Waydroid简介
===================

Waydroid是类似 :ref:`anbox` 的开源基于容器技术的完整Android系统，运行在Linux系统上，提供Android应用运行能力。

和 :ref:`anbox` 不同的是，Waydroid采用了 :ref:`wayland` 显示服务(更为先进)。Waydroid通过使用Linux namespaces(user, pid, uts, net, mount, ipc)来在容器中运行一个完整Android系统，这样就为任何Linux系统带来了Andorid应用程序运行能力。在容器的中Android可以直接访问所需硬件。Android运行环境是一个最小化的Android系统景象，基于LineageOS，当前基于Android 10。

.. note::

   Waydroid 目前应该已经超越了 :ref:`anbox` ，很多开源Linux for smartphone都采用Wayroid来构建Android虚拟层提供运行Android应用的能力。例如Sailfish和Postmarket OS，以及Mobian等，并且Fedora,Ubuntu和Arch都有Waydroid的发行包。

   :ref:`arch_linux` 移植到 :ref:`pine64` 硬件的发行版 `Arch Linux ARM on Mobile <https://github.com/dreemurrs-embedded/Pine64-Arch>`_ 的 `Android compatibility layer文档  <https://github.com/dreemurrs-embedded/Pine64-Arch/wiki/Android-compatibility-layer>`_ 说明了运行Waydroid的方法。

Waydroid甚至还开发了集成化的Linux发行版 ``Waydroid-Linux`` ，基于Ubuntu 21.10提供很多附加工具和脚本，力求做到开箱即用。

需要注意的是，Waydroid-Linux目前只支持X86的CPU以及Intel和AMD的GPU，所以在选择硬件上需要小心谨慎。

.. note::

   我准备在自己的旧笔记本上安装 :ref:`arch_linux`  (甚至使用 :ref:`lfs` ) 来运行Waydroid，尝试构建适合移动办公的Linux系统。



参考
========

- `waydroi.id官网 <https://waydro.id/>`_
- `arch linux wiki: Waydroid <https://wiki.archlinux.org/title/Waydroid>`_
