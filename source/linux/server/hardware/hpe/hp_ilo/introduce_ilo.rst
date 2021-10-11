.. _introduce_ilo:

====================
HP iLO简介
====================

Integrated Lights-Out，简称 iLo，是由HP(Hewlett-Packard)公司推出的专有嵌入式服务器管理技术，提供了带外管理功能。HP iLO结合了服务器主板的iLO ASIC(集成电路)以及增强ASIC的firmware。iLO是服务器强大操作的关键，也是启动时方便设置，系统健康监控以及电源和温度控制的平台。

iLO的版本
==========

目前HP已经开发了5代iLO，并且每代有不同板本:

.. csv-table:: HPE iLO
   :file: introduce_ilo/ilo_gen.csv
   :widths: 25, 75
   :header-rows: 1

iLO功能
==========

- 实时的系统健康度日志
- 无需Agent的管理(Agentless Management) - 当使用Agentless Management配置时，管理软件(SNMP)是在iLO firmware中操作，而不需要在主机OS中运行，这就能够释放主机OS的内存和CPU资源。iLO监控所有关键的内部子系统，并且发送SNMP告警给中心化的管理服务器，甚至不需要安装主机操作系统
- 部署和交付 - 使用虚拟电源和虚拟介质可以完成自动化部署和交付
- 嵌入式远程支持 - 注册一个被支持的服务器可以提供HPE远程支持
- iLO联邦管理(Federation management) - 使用iLO联邦功能可以在同一时间发现和管理多个服务器
- 集成的管理日志 - 可以查看服务器日志并且通过SNMP alerts, 远程syslogs以及email alerts观察服务器事件
- 集成远程控制终端 - 如果可以网络访问服务器，可以通过一个安全的高性能控制台访问管理服务器
- 电能消耗和电能设置 - 可以监控服务器电能消耗，配置服务器电能色纸，以及在支持的服务器上配置电能上限
- 电源管理 - 远程控制被管理服务器的电源状态(开关机)
- 服务器健康监控 - iLO监控服务器温度，并发送正确的信号给风扇以保持服务器冷却。iLO也可以监控安装的firmware以及软件版本以及风扇状态，内存，网络，处理器，电能输送，存储以及系统主板安装的驱动器
- 用户访问控制 - 使用本地或者基于用户账号的目录服务来管理iLO登录
- 虚拟介质 - 可以远程挂载虚拟介质到服务器上(提供OS安装)

iLO访问方式
==============

- web访问 - 提供了浏览器访问管理服务器方式
- ROM-based配置工具 - 根据不同的服务器型号，可以使用iLO RBSU 或 iLO 4 配置工具程序来配置网络参数，全局设置以及用户账号。在支持UEFI的服务器，例如DL580 Gen8或者Gen 9服务器，可以在UEFI系统工具中使用iLO 4配置工具。在不支持UEFI的服务器，就使用iLO RBSU
- iLO RESTful API - iLO 4 2.00 以及后续版本提供了iLO RESTful API，可以参考 `iLO RESTful API ecosystem <https://www.hpe.com/us/en/servers/restful-api.html>`_
- iLO 脚本和命令行
- iLO Amplifier Pack - 提供清单以及firmware和驱动更新解决方案的服务器，可以快速发现、详情报告，以及firmware和驱动更新，是大型网络管理的平台软件

iLO网络连接
==============

有两种iLO网络连接方式:

独立的管理网络
-----------------

在独立部署的管理网络架构中，iLO端口是使用一个分离的物理网络，带来更好的性能和安全性:

- 生产网络流量不会影响管理网络，这在大型数据中心非常重要，因为一旦出现网络故障，独立的管理网络提供了应急处理通道
- 管理网络可以采用低端交换设备，降低维护成本
- 独立的管理网路是推荐部署方式

.. figure:: ../../../../../_static/linux/server/hardware/hpe/hp_ilo/dedicated_ilo_network.png
   :scale: 70

兼用生产网络
--------------

如果条件不允许，则可以将服务器NIC和iLO端口连接到相同的生产网络，这种方式称为Shared Network Port configuration。一些HP企业级嵌入NIC以及附加网卡提供了这种能力，也就是服务器网卡可以兼作iLO网络接口，但是带来不利点有:

- 共享网络，流量可能会影响iLO性能
- 当服务器启动时，操作系统加载或卸载系统NIC驱动会导致短时间(2-8秒)不能访问iLO
- 网卡更新firmware或reset会导致iLO无法访问
- iLO共享网络连接不能用于网速大于100Mbps网络

.. figure:: ../../../../../_static/linux/server/hardware/hpe/hp_ilo/shared_ilo_network.png
   :scale: 70


参考
=======

- `What’s HPE iLO? <https://www.itperfection.com/computer-network-concepts/whats-hpe-ilo-hp-servers-gen7-gen8-gen9-gen10-proliant-networking-standard-features/>`_
- `iLO文档汇总 <http://www.hpe.com/info/ilo/docs>`_

  - `HPE iLO 4 2.78 User Guide <https://support.hpe.com/hpesc/public/docDisplay?docLocale=en_US&docId=sd00001038en_us>`_
  - `HPE iLO 4 脚本和命令行指南 <https://support.hpe.com/hpesc/public/docDisplay?docId=c03334060>`_
    
- `服务器集成 iLO 端口的配置 <https://support.hp.com/cn-zh/document/c01195081>`_ 这篇是HP官方提供的iLO配置(BIOS方式，即RBSU设置)的方法，步骤清晰
- `使用iLO远程管理HP系列服务器 <https://blog.51cto.com/wangchunhai/837529>`_ 网上的一篇非常早期的教程，好在比较清晰
- `HP iLO 详细介绍 <https://www.eumz.com/2012-06/466.html>`_ 早期文档，比较清晰
- `HPE Integrated Lights-Out (iLO 4) - Setting Up iLO <https://support.hpe.com/hpesc/public/docDisplay?docId=emr_na-a00020272en_us>`_ 官方文档，详细准确，但是很枯燥
- `TechExpert HP iLO tutorials <https://techexpert.tips/category/hp-ilo/>`_ 第三方教程，比较详细，但是夹杂广告太多了
