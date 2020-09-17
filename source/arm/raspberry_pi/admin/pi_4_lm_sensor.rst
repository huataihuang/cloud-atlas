.. _pi_4_lm_sensor:

=======================
树莓派4的lm_sensor
=======================

树莓派4的处理器性能相较前代有很大提高，但是也带来了运行功耗和散热问题。我在淘宝上购买了铝合金散热铠甲，没有风扇的静音，但是比较担心散热问题，所以部署温度监控并进行实时检测。

温控问题
=========

:ref:`check_server_temp` 介绍了一种命令行检查处理器问题方法::

   paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'

显示输出::

   cpu-thermal  52.5°C

通过 ``top`` 命令可以看到ubuntu默认启动的 :ref:`snap` 服务 ``snapd`` 持续消耗CPU资源::

   top - 03:23:12 up  2:03,  1 user,  load average: 0.92, 0.79, 0.80
   Tasks: 130 total,   1 running, 129 sleeping,   0 stopped,   0 zombie
   %Cpu(s):  6.3 us,  1.8 sy,  0.0 ni, 89.0 id,  2.9 wa,  0.0 hi,  0.0 si,  0.0 st
   MiB Mem :   1848.2 total,   1118.2 free,    193.4 used,    536.5 buff/cache
   MiB Swap:      0.0 total,      0.0 free,      0.0 used.   1618.3 avail Mem
   
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
      1648 root      20   0 1219044  34104  14000 S  31.0   1.8  38:08.39 snapd
      2589 ubuntu    20   0   10680   3224   2660 R   0.7   0.2   0:00.07 top
         9 root      20   0       0      0      0 S   0.3   0.0   0:20.04 ksoftirqd/0
       189 root       0 -20       0      0      0 I   0.3   0.0   0:12.94 kworker/3:1H-kblockd
       200 root       0 -20       0      0      0 I   0.3   0.0   0:25.15 kworker/0:2H-mmc_complete
       813 root       0 -20       0      0      0 I   0.3   0.0   0:12.76 kworker/2:1H-kblockd
       815 root      20   0       0      0      0 S   0.3   0.0   0:30.88 jbd2/mmcblk0p2-
      1644 root      20   0   80920   1572   1364 S   0.3   0.1   0:01.11 irqbalance
      2500 root      20   0       0      0      0 I   0.3   0.0   0:02.96 kworker/1:2-events
      2561 root      20   0       0      0      0 I   0.3   0.0   0:00.37 kworker/0:3-events
         1 root      20   0  167688  10884   7292 S   0.0   0.6   0:03.30 systemd   

lm_sensor安装配置
===================

- 安装 ``lm_sensor`` ::

   sudo apt install lm_sensor

- 执行检测配置::

   sensors-detect

在树莓派上执行遇到以下无法检测到传感器错误信息::

   Sorry, no sensors were detected.
   Either your system has no sensors, or they are not supported, or
   they are connected to an I2C or SMBus adapter that is not
   supported. If you find out what chips are on your board, check
   https://hwmon.wiki.kernel.org/device_support_status for driver status
