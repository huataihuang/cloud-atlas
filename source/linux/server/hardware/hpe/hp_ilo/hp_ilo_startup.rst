.. _hp_ilo_startup:

===============
HP iLO起步
===============

设置iLO(BIOS)
==============

在服务器启动自检时候，会提示按键进入BIOS设置方法，例如在我的 :ref:`hpe_dl360_gen9` 启动时，按下 ``F9`` 是进入BIOS设置，其中包含了配置 iLO 项目。其他可以参考 `服务器集成 iLO 端口的配置 <https://support.hp.com/cn-zh/document/c01195081>`_ 这篇是HP官方提供的iLO配置(BIOS方式， 即RBSU设置)的方法。

- 配置网络IP地址，我这里配置::

   192.168.6.254 dl360-ilo

- 配置用户账号: 举例，我添加了 ``huatai`` 账号作为系统管理员

WEB访问
==========

通过 https://192.168.6.254 可以使用账号登陆并检查系统，可以非常方便检查系统健康状况，例如，以下是服务器内部温度的监控页面:

.. figure:: ../../../../../_static/linux/server/hardware/hpe/hp_ilo/hp_ilo_web-1.png
   :scale: 50

- 为了能够使用iLO高级功能，建议安装License

Linux驱动和工具
================

在Linux中使用iLO，使用以下驱动和工具:

- ``System Health Application and Command-Line Utilities`` 包含了一系列监控风扇、电源、温度传感器以及管理事件的应用程序，包括 ``hpasmd`` ``hpasmlited`` ``hpasmpld`` 和 ``hpasmxld`` 服务
- ``hpilo`` 驱动是Linux内核模块，在Ubuntu系统中会自动加载::

   lsmod | grep hpilo

输出::

   hpilo                  24576  0



IPMI tool
=============



参考
======

- `HPE iLO 4 2.78 User Guide <https://support.hpe.com/hpesc/public/docDisplay?docLocale=en_US&docId=sd00001038en_us>`_
- `HPE iLO 4 脚本和命令行指南 <https://support.hpe.com/hpesc/public/docDisplay?docId=c03334060>`_
