.. _intro_turing_pi:

=============================
Turing Pi (树莓派集群) 简介
=============================

Turing Pi v2 是 `Turing Pi <https://turingpi.com/>`_ 即将发布的第二款Turing Pi产品(树莓派计算模块mini集群主板)，同时支持 :ref:`pi_cm4` 和 :ref:`jetson_nano` ，是一款功能全面的边缘计算集群主板。

.. figure:: ../../../../_static/arm/raspberry_pi/hardware/turing_pi/tpiv2-preview.png
   :scale: 60

从上图可以看出，Turing Pi v2在mini ITX主板上，支持4个计算模块，并且提供了完善的主机计算外设连接:

- 支持 ``4`` 个不同规格 :ref:`pi_cm4` 和/或 :ref:`jetson_nano` 
- 两层可管理交换机: 针对每个计算模块提供一个内部(不可见)交换机网口(共4个) 以及外部 2个 以太网接口(可外联交换机)，支持VLAN
- 12 Gbps 背板带宽
- 2个 mini :ref:`pcie` gen2 接口: 可安装无线网卡以及4G/5G modem
- 2个 SATA3 6 Gbps接口 : 可外接2个SATA SSD存储设备 构建 :ref:`gluster` 存储
- 主板提供管理控制器: 可实现远程管理装机等服务器管控功能，类似 :ref:`hp_ilo`
- 提供 1个 HDMI 输出

主板细节
===========

.. figure:: ../../../../_static/arm/raspberry_pi/hardware/turing_pi/tpiv2-top-1-1916x2048-1.jpg
   :scale: 30

- 模块示意:

.. figure:: ../../../../_static/arm/raspberry_pi/hardware/turing_pi/tpiv2-scheme.png
   :scale: 60

- 计算模块+散热器:

.. figure:: ../../../../_static/arm/raspberry_pi/hardware/turing_pi/cm4_turing.png
   :scale: 60

计算模块
-----------

Turing Pi v2 支持2种计算模块:

- :ref:`pi_cm4` 安装板

.. figure:: ../../../../_static/arm/raspberry_pi/hardware/turing_pi/tpiv2-cm4-adapter-1.png
   :scale: 60

- :ref:`jetson_nano`

.. figure:: ../../../../_static/arm/raspberry_pi/hardware/turing_pi/nvidia-jetson-1.png
   :scale: 60

上述两种计算模块也是目前最为流行的ARM SoC计算模块么，能够集成到一个Cluster主板，非常方便作为边缘计算集群设备。

主板管理控制器(BMC)
---------------------

Truing Pi v2集成了一个BMC用于主板诊断，watchdog和告警，电源管理，远程集群管理，OS flashing等功能。真是非常期待这个远程管理功能。

Firmware
------------

Turing Pi V2 包含了firmware来控制集群操作，提供 over-the-air 更新 (OTA)，远程集群管理，包括 serial console over LAN 和 远程刷OS功能。这样就可以实现裸金属启动集群以及 ``kubeconfig`` 并且远程故障恢复。

可管理交换机
---------------

Turing Pi V2 主板包含一个7端口交换机:

- 4x 1-gigabit 端口分配个4个计算模块
- 2x external 1-gigabit 端口以及1个100 M 集群管理端口
- 支持最多 4096 VLAN IDs 的 IEEE802.1Q VLAN

电源管理Power supply unit (PSU)
----------------------------------

使用ATX 24-pin标准电源连接，在安装了4个计算模块(4x4 cpu cores) 32GB内存的 :ref:`pi_cluster` 消耗电能不超过 80W 。采用广泛使用的 6-24V DC 电源，可以用于汽车、太阳能以及电池供电。

即将发布
==========

`Turing Pi v2 将于2022年Q1发布 <https://turingpi.com/turing-pi-v2-is-here/>`_ ，这将是我2022年初最期待的设备，构建:

- :ref:`k3s` 边缘计算集群
- 结合 :ref:`jetson_nano` 实践 :ref:`machine_learning`

对标竞品
===============

`ClusBerry CM4 <https://clusberry.techbase.eu>`_ 是一个完成度更高的商业产品:

.. figure:: ../../../../_static/arm/raspberry_pi/hardware/turing_pi/clusberry2.jpg
   :scale: 30

从功能拆解来看，Turing Pi v2通过技术Hack，可以达到商业产品的能力:

.. figure:: ../../../../_static/arm/raspberry_pi/hardware/turing_pi/clusberry_cluster_modules.png
   :scale: 60

可见的发展方向:

- 结合Google的 `Coral.ai <https://coral.ai/>`_ 设备实现边缘计算AI

参考
========

- `4 Pis on a mini ITX board! The Turing Pi 2 <https://www.youtube.com/watch?v=IUPYpZBfsMU>`_
- `Why would you build a Raspberry Pi Cluster? <https://www.youtube.com/watch?v=8zXG4ySy1m8>`_
