.. _hp_ilo_startup:

====================
HP iLO快速起步
====================

Integrated Lights-Out，简称 iLo，是由HP(Hewlett-Packard)公司推出的专有嵌入式服务器管理技术，提供了带外管理功能。HP iLO结合了服务器主板的iLO ASIC(集成电路)以及增强ASIC的firmware。iLO是服务器强大操作的关键，也是启动时方便设置，系统健康监控以及电源和温度控制的平台。

iLO的版本
==========

目前HP已经开发了5代iLO，并且每代有不同板本:

.. csv-table:: HPE iLO
   :file: hp_ilo_startup/ilo_gen.csv
   :widths: 25, 75
   :header-rows: 1

参考
=======

- `What’s HPE iLO? <https://www.itperfection.com/computer-network-concepts/whats-hpe-ilo-hp-servers-gen7-gen8-gen9-gen10-proliant-networking-standard-features/>`_
- `服务器集成 iLO 端口的配置 <https://support.hp.com/cn-zh/document/c01195081>`_ 这篇是HP官方提供的iLO配置(BIOS方式，即RBSU设置)的方法，步骤清晰
- `使用iLO远程管理HP系列服务器 <https://blog.51cto.com/wangchunhai/837529>`_ 网上的一篇非常早期的教程，好在比较清晰
- `HP iLO 详细介绍 <https://www.eumz.com/2012-06/466.html>`_ 早期文档，比较清晰
- `HPE Integrated Lights-Out (iLO 4) - Setting Up iLO <https://support.hpe.com/hpesc/public/docDisplay?docId=emr_na-a00020272en_us>`_ 官方文档，详细准确，但是很枯燥
- `TechExpert HP iLO tutorials <https://techexpert.tips/category/hp-ilo/>`_ 第三方教程，比较详细，但是夹杂广告太多了
