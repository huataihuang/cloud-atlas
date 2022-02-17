.. _pi_router_startup:

==================
树莓派路由器起步
==================

`seeedstudio <https://www.seeedstudio.com/>`_ 围绕嵌入式IoT和AI推出了很多相关技术以及硬件。其中，采用树莓派制作路由器，给我启发，我准备调研并实践采用树莓派构建路由器和交换机，实现复杂的网络架构。

路由器功能
=============

作为小型局域网的网关路由器，通常具备以下功能:

- 提供广域网(WAN)路由访问

  - 透明代理翻墙 :ref:`squid` / :ref:`privoxy`
  - 反向代理 :ref:`squid` / :ref:`nginx`
  - 安全控制: 审计、日志、限制、广告过滤
  - 网络QoS
  - VPN

- 本地局域网服务

  - DHCP
  - :ref:`dns`
  - :ref:`ntp`
  - 下载服务: BT下载
  - NAS: 本地数据备份归档
  - 私有云盘服务
  - 打印服务
  - 视频服务 :ref:`kodi`

采用树莓派来实现网络设备:

- 低功耗
- 通用设备可运行不同Linux版本进行定制

硬件设备
==========

:ref:`pi_4` 是通用SBC设备，但是由于只具备1个千兆网口，定制性较弱。 `seeedstudio <https://www.seeedstudio.com/>`_ 提供基于 :ref:`pi_cm4` 的主板(双网口)。

硬件设想
----------

实际上树莓派作为最流行的SBC，配套硬件以及社区软件非常丰富，这是树莓派最大的优势。不过，对于专用路由和交换设备，树莓派也有比较大的局限:

- 缺乏多网口规格硬件: 在淘宝上能够找到 4~8 网口的基于Intel低端CPU的x86主板或一体机，价格非常低廉，可以用来构建开源交换机或路由器
- 只有 :ref:`pi_cm4` 可以通过扩展主板支持 PCIe 存储，但是加上扩展主板成本相对较高，接近于Intel多网口一体机
- ``NanoPi R4S`` 作为针对路由功能定制的双网口ARM主机，非常小巧且功能完备，比叠加主板的 :ref:`pi_cm4` 更为经济

.. figure:: ../../../../_static/arm/raspberry_pi/network/router/nanopi_r4s.png
   :scale: 60

.. note::

   不过，由于我已经购买了大量树莓派设备，所以我的基础架构依然会围绕树莓派来实现。

对于上述树莓派的不足，我准备从以下几个方面来弥补:

- 通过USB接口以太网卡来扩展树莓派的网络接口: 至少可以增加2个网口，加上 :ref:`pi_4` 自带网口，可以实现一个非常小型的交换网络
- 采购 :ref:`pi_cm4` 加上扩展主板来构建交换设备，并且可以增加PCIe存储

参考
=======

- `How to Build a Raspberry Pi Router – Step by Step Tutorial <https://www.seeedstudio.com/blog/2021/06/11/how-to-build-a-raspberry-pi-router-step-by-step-tutorial/>`_
