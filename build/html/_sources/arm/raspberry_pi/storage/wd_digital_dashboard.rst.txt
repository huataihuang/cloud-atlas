.. _wd_digital_dashboard:

========================================================
西部数据SSD存储管理工具: Western Digital Dashboard
========================================================

.. note::

   我在树莓派集群上使用 :ref:`wd_passport_ssd` 作为构建 :ref:`ceph` 存储，遇到不同批次购买的设备存在不同的扇区大小(512字节和4k字节)，所以对设备进行完整检测，采用了西部数据SSD存储管理工具: Western Digital Dashboard。

西部数据提供了一个在Windows平台运行的SSD存储诊断和配置工具 Western Digital Dashboard。需要注意WD SSD Dashboard只支持西部数据的SSD产品，并且这个软件没有提供macOS和Linux版本，所以对于维护西部数据SSD存储，还是选择Windows平台为好。

Performance Monitor
=======================

Performance Monitor提供了实时监控SSD设备性能:

- Transfer Speed MB/s
- Transfer IOPS

Firmware update
====================

理论上Firmware update不会导致存储的数据丢失，但是强烈建议在更新firmware之前备份所有数据。



参考
=======

- `WD SSD Dashboard Frequently Asked Questions (FAQ) <https://support-en.wd.com/app/answers/detail/a_id/11426>`_
