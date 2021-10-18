.. _systemd_timer:

=============================
Systemd timer服务(替代cron)
=============================

.. note::

   在很久以前，我每次安装CentOS操作系统，都会安装 ``crontab`` 应用作为系统的定时任务管理工具。不过，由于我发现docker容器中cron没有正确执行，查阅资料发现，原来systemd系列已经提供了cron集成服务 ``timer`` ，所以完全不必再安装多余的cron服务，利用系统已经默认启用的systemd就可以管理不同的定时任务，简化系统部署。

   总之，技术与时俱进，需要不断修正自己的技术经验

参考
======

- `Use systemd timers instead of cronjobs <https://opensource.com/article/20/7/systemd-timers>`_ 这篇文章写得非常详尽，并且提供了systemd的相关参考文档引用，值得学习
