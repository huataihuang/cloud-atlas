.. _intro_freebsd_bridge:

==========================
FreeBSD网桥(bridge)简介
==========================

网桥(bridge)是一种连接连个网络成为一体的设备，也就是的我们常说的交换机(switch)。在网桥/交换机中，设备并不强制要求配置IP地址(这和路由器router是明显的区别)。网桥设备通过学习自身每个网络接口上的MAC地址来实现知道不同接口连接的网络设备，这样就能够实现网络流量转发。

FreeBSD在网络软件堆栈上有着悠久的历史以及特长，非常适合作为软件定义网络的基础设施，网桥(bridge)也是内置支持的网络设备形式。

网桥能够在以下环境中发挥作用:

- 连接网络: FreeBSD能够提供多个网段的高性能连接，同时基于内核提供防火墙和无线桥接(AP)，我觉得FreeBSD在网络层久负盛名，可以通过学习实践更为了解SDN激素
- 过滤和流量整形防火墙: 网桥可以进一步提供防火墙功能，并且无需路由或网络地址转换(NAT)。
- 网络Tap(深度解析): 网桥连接两个网段来实现深入解析所有以太网帧和转发，底层技术使用bpf和tcpdump，而且能够实现将所有数据帧转发到一个span端口(镜像)
- 二层网络VPN(Layer 2 VPN): 两个以太网络可以通过bridging网络到一个EtherIP tunnel或基于类似OpenVPN的tap实现连接(这种加密连接两个以太网络可以实现企业级的跨域连接)
- 二层网络冗余: 通过多个连接互联的网络以及使用生成树协议(Spanning Tree Protocol, STP)实现网络冗余(这个技术是交换机网络常用的冗余技术)

总之，通过使用FreeBSD作为网络底层核心，可以实现复杂的企业级交换网络，也就是通过开源技术实现类似 :ref:`cisco` 的解决方案。

实践
======

- :ref:`freebsd_bridge_startup`

参考
=======

- `FreeBSD Handbook: 34.8.Bridging <https://docs.freebsd.org/en/books/handbook/advanced-networking/#network-bridging>`_

