.. _dl360_bios_numa:

================================
HPE DL360 Gen9设置BIOS激活NUMA
================================

在 :ref:`hpe_dl360_gen9` 提供了很多平台相关的优化，其中常用的NUMA优化也称为 ``NUMA Group Size Optimization`` 。通过调整 ``BIOS/Platform Configuration (RBSU)`` 配置可以帮助操作系统对应用程序进程进行分组并就近访问CPU最近的内存及外设。

设置 ``NUMA Group`` 大小
=========================

在服务器启动过程中按下 ``F9`` 进入 ``System Utilities`` 屏幕，然后按照以下路径访问:

``System Configuration > BIOS/Platform Configuration (RBSU) > Performance Options > Advanced Performance Tuning Options > NUMA Group Size Optimization``

.. figure:: ../../../../_static/linux/server/hardware/hpe/dl360_bios_numa.jpg

设置成 ``Clustered`` 之后保存( ``F10`` )并重启，就会激活BIOS对NUMA支持

参考
=======

- `HPE ProLiant Gen9 Servers - What is NUMA Group Size Optimization? <https://support.hpe.com/hpesc/public/docDisplay?docId=sf000046349en_us&docLocale=en_US>`_
