.. _openwrt_k3s_arch:

===================
OpenWrt上k3s架构
===================

我计划在OpenWrt上再次构建 :ref:`k3s` ，尝试不同的 :ref:`edge_cloud` 平台上实现 :ref:`kubernetes`

.. note::

   从网上资料来看，OpenWrt内核默认没有提供cgroup等支持，需要自己编译系统。我觉得这是一个技术挑战，可以完整理解如何构建 :ref:`edge_cloud` 的嵌入式系统

   此外， :ref:`muvirt` 基于OpenWrt和Ten64硬件构建

参考
======

- `Running Kubernetes on OpenWrt <https://5pi.de/2019/05/10/k8s-on-openwrt/>`_
- `k3s on OpenWrt <https://github.com/discordianfish/k3s-openwrt>`_
