.. _check_server_temp:

===============
服务器温度检测
===============

lm_sensor
============

监控服务器温度最常用的方法是安装和使用 :ref:`lm_sensor` ，安装以后，通过以下命令配置::

   sudo sensors-detect

- 配置完成后，执行以下命令可以看到处理器温度::

   sensors

输出类似

porc脚本检查
==============

虽然第三方工具，例如 ``lm_sensors`` 能够非常方便地检查处理器温度，但是，实际上即使不安装工具，通过内核的 ``/proc`` 文件系统，也可以直接读取数据，并使用脚本命令处理。

- 传感器类型和对应的数据记录位于::

   /sys/class/thermal/thermal_zone*/type
   /sys/class/thermal/thermal_zone*/temp

- 执行以下命令可以检查系统温度::

   paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'

输出类似(根据平台不同输出信息不同)::

   acpitz        43.0°C
   x86_pkg_temp  53.0°C

硬盘温度
==========

- 监控硬盘，可以安装 ``hddtemp`` 工具::

   sudo apt install hddtemp

图形界面温度监控
=================

- 安装 ``psensor`` 工具可以以图形界面方式观察温度::
   
   sudo apt install psensor

glances
========

Glances是一个使用Python编写的跨平台系统监控工具，我最早接触这个工具还是在十几年前给电信维护HP小型机时，在远程终端上使用这个超级工具glances。

- 安装::

   sudo apt -y --force-yes update
   sudo pip install --upgrade pip
   wget -O- https://bit.ly/glances | /bin/bash

- 也可以通过仓库安装::

   sudo apt-add-repository ppa:arnaud-hartmann/glances-stable
   sudo apt-get update
   sudo apt-get install glances

hardinfo
===========

hardinfo是一个系统分析和性能评测工具，可以获得硬件和基本软件信息，并且使用GUI组织这些信息。

大多数硬件可以通过hardinfo自动检测，也有部分硬件需要手工设置：

- lm-sensors: 需要如上使用 ``sensors-detect`` 先检测需要加载哪些内核模块
- hddtemp:  需要以daemon模式运行hddtemp并且使用默认端口，这样hardinfo就可以使用hddtemp
- 模块 ``eeprom`` 必须加载用于显示当前安装的内存信息，所以需要先使用 ``modprobe eeprom`` 加载并刷新

参考
=====

- `How To View CPU Temperature On Linux <https://ostechnix.com/view-cpu-temperature-linux/>`_
- `itsfoss:How To Check CPU Temperature in Ubuntu Linux <https://itsfoss.com/check-laptop-cpu-temperature-ubuntu/>`_
- `sourcedigit:How To Check CPU Temperature In Ubuntu Linux <https://sourcedigit.com/25105-check-cpu-temperature-ubuntu-linux/>`_
- `How to check CPU temperature on Linux <https://www.addictivetips.com/ubuntu-linux-tips/check-cpu-temperature-on-linux/>`_
- `How do I get the CPU temperature? <https://askubuntu.com/questions/15832/how-do-i-get-the-cpu-temperature>`_
