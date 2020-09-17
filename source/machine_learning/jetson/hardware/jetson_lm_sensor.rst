.. _jetson_lm_sensor:

=======================
Jetson Nano lm_sensor
=======================

NVIDIA Jetson Nano是综合了GPU和CPU的复合系统，对于运行稳定性需要时刻监控系统问题，所以，需要安装 :ref:`lm_sensor` 来监控传感器。

- 安装 ``lm_sensor`` ::

   sudo apt install lm_sensor

- 执行检测配置::

   sensors-detect

在Jetson上执行遇到以下无法检测到传感器错误信息::

   Sorry, no sensors were detected.
   Either your system has no sensors, or they are not supported, or
   they are connected to an I2C or SMBus adapter that is not
   supported. If you find out what chips are on your board, check
   http://www.lm-sensors.org/wiki/Devices for driver status.
