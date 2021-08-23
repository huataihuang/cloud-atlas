.. _pi_os:

=====================
树莓派操作系统概览
=====================

树莓派作为广泛使用的单板计算机系统，有很多开源Linux操作系统已经适配并可以直接使用：

Raspbian OS: 官方树莓派操作系统
===========================================

Raspbian OS是树莓派官方提供的基于Debian定制的操作系统，包含了大量的应用，易于安装和使用。请参考 `树莓派官方Raspbian OS安装文档 <https://www.raspberrypi.org/documentation/installation/installing-images/README.md>`_

Ubuntu MATE: 通用计算
===============================

`Ubuntu MATE for Raspberry Pi <https://ubuntu-mate.org/raspberry-pi/>`_ 是定制Raspberry Pi OS的轻量级版本，甚至支持 :ref:`jetson_nano` 运行。请参考 `how to install Ubuntu MATE on Raspberry Pi <https://itsfoss.com/ubuntu-mate-raspberry-pi/>`_

Ubuntu Server: 树莓派服务器版本
===============================

`Ubuntu Server for Raspberry Pi <https://ubuntu.com/download/raspberry-pi>`_ 是目前我主要使用的 :ref:`ubuntu64bit_pi` ，用于在 :ref:`arm_k8s_deploy` 。

LibreELEC: 多媒体服务器
============================

.. note::

   `Top 9 Best Linux Media Server Software <https://itsfoss.com/best-linux-media-server/>`_  介绍了多个不同的媒体服务器，其中最为流行的开源Media Server `kodi <https://kodi.tv/>`_ （著名的 xbmc 多媒体中心由kodi开发）以及基于kodi开发的 `LibreELEC <https://openelec.tv/>`_ 则提供支持树莓派版本。

`LibreELEC <https://openelec.tv/>`_ 是一个 :ref:`raspberry_pi` 上轻量级 `kodi <https://kodi.tv/>`_ 实现。

RISC OS: 最初始的ARM OS
==========================

`RISC OS <https://www.riscosopen.org/content/>`_ 是非常古老的操作系统，致力于在现代ARM架构SBC(如树莓派）上运行。RISC OS界面非常简单，但是聚焦于性能。不过，目前只提供 :ref:`pi_3` 的发行版，尚未提供 :ref:`pi_4` 版本。

Mozilla WebThings Gateway: IoT项目
=======================================

`Mozilla WebThings Gateway <https://iot.mozilla.org/gateway/>`_ 是Mozilla的IoT开源实现，提供监控和控制IoT设备。可以在树莓派上安装。

Ubuntu Core: IoT项目
==========================

`Ubuntu Core <https://ubuntu.com/download/raspberry-pi-core>`_ 是Ubuntu推出的IoT项目

DietPi: 轻量级树莓派OS
==========================

`PietPi <https://dietpi.com/>`_ 是一个基于Debian的轻量级操作系统，比官方的 "Raspbian Lite" 更为轻量。

Kali Linux: hacker使用的系统
===============================

:ref:`kali_linux` 提供了树莓派的不同版本，我也是在 :ref:`pi_400` 上安装了Kali Linux进行学习的。

OpenMediaVault: NAS实现
============================

`OpenMediaVault <https://www.openmediavault.org/>`_ 是在小型设备上实现NAS的解决方案，提供了传统企业文件存储的解决方案。

Alpine Linux: 轻量级专注安全的Linux
=======================================

:ref:`alpine_linux` 是目前我使用的构建基于集群计算节点的Linux系统，这个发行版也是Docker官方默认使用的镜像OS，具有小型、轻量级、安全的特性。尤其是其完全在内存中运行，对于精简的集群计算节点，具有节约资源、高速和安全的优势。

Manjaro Linux: 基于Arch Linux的易用发行版
============================================

Manjaro Linux是基于 :ref:`arch_linux` 的著名易用的发行版，也提供了最新的 :ref:`pi_4` 硬件致辞，并且提供了XFCE和KDE Plasma版本。

FreeBSD 和 NetBSD
=====================

不仅是Linux，实际上BSD系统也来到了树莓派上，包括著名的 `FreeBSD <https://www.freebsd.org/>`_ 和 `NetBSD <https://www.netbsd.org/>`_ 。如果你专注于网络和安全，BSD系统提供了非常经典和稳定的解决方案。

参考
=========

- `Best Raspberry Pi Operating Systems for Various Purposes <https://itsfoss.com/raspberry-pi-os/>`_