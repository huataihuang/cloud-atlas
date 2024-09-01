.. _dl360_gen9_pci_bus_error:

=====================================
HPE DL360 Gen9服务器PCI Bus Error
=====================================

.. warning::

   服务器适合长时间加电运行，不适合反复开关:

   我感觉二手服务器尤其脆弱，不适合长时间关机。

我的 HPE DL360 Gen9服务器 是2021年9月购买，算起来持续使用了2年半。不过，最近半年因为失业( :ref:`whats_past_is_prologue` )外出旅行，所以关机了半年。这应该是这台受到伤害的最大原因，受到上海潮湿闷热天气的折磨之后，终于在今天开机出现了严重的错误告警:

从 ``Integrated Management Log`` (CSV格式)可以看到:

.. csv-table:: HPE DL360 gen9服务器PCI总线错误日志
   :file: dl360_gen9_pci_bus_error/integrated_management_log.csv
   :widths: 10, 10, 20, 10, 10, 10, 30
   :header-rows: 1

太不幸了，两个月前还正常启动的服务器罢工了...
