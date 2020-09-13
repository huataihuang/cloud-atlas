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
   

参考
=====

- `How To View CPU Temperature On Linux <https://ostechnix.com/view-cpu-temperature-linux/>`_
- `itsfoss:How To Check CPU Temperature in Ubuntu Linux <https://itsfoss.com/check-laptop-cpu-temperature-ubuntu/>`_
- `sourcedigit:How To Check CPU Temperature In Ubuntu Linux <https://sourcedigit.com/25105-check-cpu-temperature-ubuntu-linux/>`_
- `How to check CPU temperature on Linux <https://www.addictivetips.com/ubuntu-linux-tips/check-cpu-temperature-on-linux/>`_
- `How do I get the CPU temperature? <https://askubuntu.com/questions/15832/how-do-i-get-the-cpu-temperature>`_
