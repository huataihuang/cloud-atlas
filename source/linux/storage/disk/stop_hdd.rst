.. _stop_hdd:

=====================
停止HDD硬盘
=====================

我计划在 :ref:`dell_t5820` 上通过软件方式来挂起机械硬盘，实现静音和节能目标

.. note::

   本文待实践并准备自动化脚本方式实现，待续

命令行
======

注意，停止设备前必须卸载文件系统

.. literalinclude:: stop_hdd/umount
   :caption: 卸载文件系统

SATA硬盘
----------

- :ref:`hdparm` 可以对SATA硬盘电源状态进行操作，通过命令手动停止硬盘转动:

.. literalinclude:: stop_hdd/hdparm_sleep
   :caption: 进入深度sleep模式(电机停转，磁头归位)

- 可以设置自动休眠超时，例如硬盘无操作10分钟后自动关机

.. literalinclude:: stop_hdd/hdparm_auto_sleep
   :caption: 设置硬盘无操作10分钟停止

SAS硬盘
---------

SAS硬盘需要使用 ``sdparm`` 工具

.. literalinclude:: stop_hdd/sdparm_stop
   :caption: ``sdparm`` 操作SAS硬盘休眠

内核命令
---------

最彻底的软件切断是直接操作内核的 ``sysfs`` 接口，高速内核这个设备现在不需要供电:

.. literalinclude:: stop_hdd/sysfs_delete
   :caption: 通过想内核发出"移除"信号来关闭硬盘逻辑链路

.. note::

   需要确保磁盘不被自动唤醒:

   - 关闭smartd对硬盘的定期检测 ``/etc/smartd.conf``

   关闭文件系统索引工具，如 ``mlocate`` 对磁盘扫描建立索引的操作

   需要关闭的硬盘不能存放swap或日志

自动脚本
=========

待续
