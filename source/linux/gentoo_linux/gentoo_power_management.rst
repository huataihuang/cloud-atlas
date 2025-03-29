.. _gentoo_power_management:

=========================
Gentoo 电源管理
=========================

``laptop_mode`` 和 ``laptop-mode-tools``
=========================================

笔记本电脑的电源管理，也就是 ``laptop_mode`` 设置，是一个内核配置，可以优化 I/O，允许磁盘正常降速(spin down properly)，并且不会在存储队列操作后立即唤醒。

``app-laptop/laptop-mode-tools`` 软件包可以让用户优化省电功能，允许管理Linux内核中的 ``laptop_mode`` 设置，但是也具有允许调整系统其他和电源相关设置的附加功能。

Linux内核配置
================

.. note::

   这段待实践，目前还采用 :ref:`gentoo_genkernel` 简单的设置内核，没有自己仔细调整过电源相关设置，我计划在 :ref:`gentoo_mba_wifi` (采用USB外接Wifi)硬件内核编译时实践

笔记本电源管理方案
====================

笔记本电源管理方案主要有:

- :ref:`tlp` : 开箱即用，已经被多个Linux发行版集成，不过在Gentoo平台还处理测试阶段，我简单尝试了一下，暂时搁置
- ``Laptop Mode Tools`` : Gentoo平台主要的笔记本电源管理工具，我在实践中将长期使用，所以在本文会详细记录并不断完善

Laptop Mode Tools
=====================

- 安装 ``laptop-mode-tools`` :

.. literalinclude:: gentoo_power_management/install_laptop-mode-tools
   :caption: 安装 ``laptop-mode-tools``

默认的 USE flag 是 ``acpi`` ，也就是依赖 ``sys-power/acpid`` ，当系统变化事件被捕获会自动激活和关闭电源节能。只要是比较新的笔记本(2003年以后)，都应该使用 ``acpi`` 。只有非常古老的笔记本才会使用 ``apm`` 。

- 配置 ``laptop-mode-tools`` 的是 ``/etc/laptop-mode/laptop-mode.conf`` ，此外支持独立的插件(模块)配置文件(位于 ``/etc/laptop-mode/conf.d`` 目录)，以其代表队模块命名，例如 ``intel-sata-powermgmt.conf``

- 如果 ``laptop-mode-tools`` 和其他电源管理服务一起结合使用，则需要关闭 ``laptop-mode-tools`` 的 ``CPU frequency settings`` 功能(也就是 ``laptop-mode-tools`` 放弃管理CPU频率调整)。这个设置是在 ``/etc/laptop-mode/conf.d/cpufreq.conf`` 中配置，默认配置是:

.. literalinclude:: gentoo_power_management/cpufreq.conf
   :caption: 默认 ``laptop-mode-tools`` 会自动管理CPU频率调整，如果结合其他电源管理，则调整为 ``0`` 禁用

- :ref:`openrc` 启动 ``laptop_mode`` 服务:

.. literalinclude:: gentoo_power_management/openrc_laptop_mode
   :caption: 在 :ref:`openrc` 中启用 laptop_mode 服务

如果系统采用 :ref:`systemd` 则采用如下命令:

.. literalinclude:: gentoo_power_management/systemd_laptop_mode
   :caption: 在 :ref:`systemd` 中启用 laptop_mode 服务

配置调整
==========

我没有实践去调整配置，底层原理主要是:

- ``cpupower frequency`` 设置，在 ``/etc/laptop-mode/conf.d/cpufreq.conf`` 有对应不同电源管理的CPU频率调整
-  显示屏亮度: ``/etc/laptop-mode/conf.d/lcd-brightness.conf`` 配置不同的电源管理下屏幕亮度
- 其他还支持配置类似 system logger的配置文件

.. note::

   根据需要再做实践，目前采用默认配置

默认配置就非常适合终端使用，观察到:

- 合上笔记本屏幕会进入休眠，打开屏幕任意按键就可以恢复
- 一段时间不使用键盘输入，在控制台终端会自动进入黑屏节能
- 其他待继续摸索

.. note::

   需要解决 :ref:`gentoo_sway` 桌面环境下调整屏幕亮度的功能，这个比较困扰

参考
======

- `gentoo linux wiki: 电源管理/向导 <https://wiki.gentoo.org/wiki/Power_management/Guide/zh-cn>`_
