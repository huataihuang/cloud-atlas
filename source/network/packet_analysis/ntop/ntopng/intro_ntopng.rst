.. _intro_ntopng:

=======================
ntopng简介
=======================

``ntopng`` 是取代早期 ``ntop`` 的高性能低延迟网络流量监控软件，即 **ntop next generation** 。 ``ntopng`` 是一个GPLv3协议的开源软件，并且提供了跨平台的源代码，支持不同操作系统Unix, :ref:`linux` , :ref:`bsd` , :ref:`macos` 和 :ref:`windows` 。ntopng的引擎采用C++开发，可选的web界面则采用 :ref:`lua` 编写。

ntopng使用 :ref:`redis` 而不是传统数据库，采用 :ref:`ndpi` 实现协议检测，支持分布式主机并且可以实时现实连接主机的流量分析。

参考
======

- `ntopng官网 <https://www.ntop.org/products/traffic-analysis/ntopng/>`_
- `wikipedia: ntop <https://en.wikipedia.org/wiki/Ntop>`_
