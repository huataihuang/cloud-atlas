.. _switch_4500_overview:

=============================
Catalyst 4500系列交换机概览
=============================

我购买的二手 :ref:`ws-c4948-s` 硬件是基于 Catalyst 4500系列交换机，具有Layer 2~4 层交换公鞥，并且能够实现完整的TCP/IP路由，是目前可以购买到的比较廉价的路由交换设备。

其中比较有特色的功能(我想要实践的):

802.1Q Tunneling, VLAN Mapping, and Layer 2 Protocol Tunneling
==================================================================

- 采用VLAN隔离技术，建立tunnel对不同功能的网络进行连接和隔离

Cisco Discovery Protocol
==========================

Cisco Discovery Protocol (CDP) 是介质和协议无关的设备发现协议，在所有Cisco产品上都提供，可以用于路由器、交换机、网桥和终端服务器互相发现和交换信息。

Flexible NetFlow
===================

Flow定义了数据包的属性字段，路由属性以及进出接口信息，用于流量记录和标识不同流特性，以提供信息采集和优化。

Internet Group Management Protocol (IGMP) Snooping
====================================================

IGMP嗅探可以管理多播流量。很久以前在学习TCP/IP路由技术，对多播只了解皮毛，没有实践，需要在多层路由设备上尝试

Jumbo Frames
=================

支持 ``9216`` 字节大帧(比IEEE Ethernet MTU大)，通常用于大型数据传输

Link Aggregation Control Protocol
====================================

LACP可以聚合多个LAN接口实现网络速率增加，对于服务器有很大价值

Quality of Service
======================

Catalyst 4500系列支持一下QoS特性:

- Classification and marking
- Ingress and egress policing, including per-port per-VLAN policing
- Sharing and shaping

并且支持QoS Automation (Auto QoS)，可以通过自动化配置简化QoS功能部署。

Spanning Tree Protocol
==========================

Spanning Tree Protocol (STP) 可以创建冗余网络链路，Cisco还支持多种STP增强:

- Spanning tree PortFast
- Spanning tree UplinkFast
- Spanning tree BackboneFast
- Spanning tree root guard

VLANs
=========

VLANs提供了逻辑拓扑，将不同对LAN网段通过VLANs组合，实现网络的聚合和隔离:

- VLAN Trunking Protocol (VTP)
- Private VLANs
- Private VLAN Trunk Ports
- Private VLAN Promiscuous Trunk Ports
- Dynamic VLAN Membership

Virtual Switching Systems
=============================

Layer 3软件功能
=================

Catalyst 4500系列交换机支持大量的3层交换功能:

- Bidirectional Forwarding Detection
- Cisco Express Forwarding
- Device Sensor
- EIGRP Stub Routing
- Enhanced Object Tracking
- GLBP
- HSRP
- In Service Software Upgrade
- IP Routing Protocols
- IPv6
- Multicast Services
- NSF with SSO
- OSPF for Routed Access
- Policy-Based Routing
- Unicast Reverse Path Forwarding
- Unicast Reverse Path Forwarding
- Unidirectional Link Routing
- VRF-lite
- Virtual Router Redundancy Protocol

IP路由协议(重点)
================

Catalyst 4500系列交换机支持以下路由协议:

- BGP
- EIGRP
- IS-IS
- OSPF
- RIP

覆盖了 TCP/IP 路由的主要协议，是非常好的学习实践平台

.. note::

   Catalyst 4500系列有大多Cisco网络技术，无法一一列举，需要逐步了解学习。后续再做补充

参考
=======

- `Catalyst 4500 Series Switch Software Configuration Guide, IOS XE 3.8.xE and IOS 15.2(4)Ex Chapter: Product Overview <https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst4500/XE3-8-0E/15-24E/configuration/guide/xe-380-configuration/intro.html>`_
