.. _intro_tailscale:

======================
Tailscale简介
======================

Tailscale是一个基于身份的零信任连接平台(Zero Trust identity-base connectivity platform)，用于替代传统的VPN，SASE和PAM，并连接远程团队、多云环境、CI/CD流水线、边缘和物联网设备以及AI工作负载。

Tailscale 底层基于 :ref:`wireguard` 协议实现加密的点对点连接，可以简化跨不同网络安全连接设备和服务的流程。

Tailscale 创建 **点对点网状网络** (peer-to-peer mesh network)，也称为 ``TailNet`` 。不过也可以像传统VPN一样使用Tailscle，只需将所有流量路由到出口节点即可。

.. figure:: ../../../../_static/linux/security/vpn/tailscale/traditional-vpn.avif

   传统VPN采用中心化流量，导致相邻用户通讯需要从vpn hub绕行导致较高延迟

.. figure:: ../../../../_static/linux/security/vpn/tailscale/tailscale.avif

   Tailscale每个设备直接连接，所以延迟降低


参考
======

- `What is Tailscale? <https://tailscale.com/docs/concepts/what-is-tailscale>`_
