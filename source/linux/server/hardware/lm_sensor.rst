.. _lm_sensor:

=============================
lm_sensors(Linux监控传感器)
=============================

Linux服务器运维时非常重要的一项监控就是服务器内部温度监控。当出现服务器内部温度过高，例如风扇故障，就会导致CPU因温度过高降频，甚至出现死机或者其他数据异常现象。

在Linux中，软件包 ``lm_sensors`` (即Linux-monitoring sensors)提供了基础工具和驱动来监控CPU温度，电压，湿度和风扇。同时也提供了主板入侵检测(非授权开启机箱)。通过该工具结合监控软件，可以用来发现硬件异常，及时更换受损部件。

安装lm_sensors
==================

- Arch linux安装::

   sudo pacman -S lm_sensors

- RHEL/CentOS,Fedora::

   sudo yum install lm_sensors

- Debian, Ubuntu::

   sudo apt install lm-sensors

- SUSE/openSUSE::

   sudo zypper in sensors

配置lm_sensors
==================

安装以后，运行以下命令配置 ``lm_sensors`` ::

   sudo sensors-detect

``sensors-detect`` 是一个独立程序用来检测已经安装的硬件以及加载推荐的特定模块。默认的交互回答就是安全的，所以只需要回车接受默认配置就可以。此时会生产一个 ``/etc/conf.d/lm_sensors`` 配置文件用于 ``lm_sensors.service`` 服务自动在启动时加载模块。

查看CPU温度
================

- 简单执行以下命令就可以查看Linux::

   sensors

默认输出的单位是摄氏度，要输出为华氏度，则使用参数 ``-f``

- 为了持续查看温度变化(以下案例每2秒刷新一次)，可以使用命令::

   wtach -n 2 sensors

