.. _cilium_1.12:

==========================
Cilium 1.12 - 架构和改进
==========================

2022年7月20日，Isovalent公司重磅发布了 Cilium 1.12 ，提供了重大架构提升和改进。在官方relase blog，为该产品梳理了脉络以及集中了相关方案资讯。从relase blog可以看出Cilium开源的架构以及集成不同开源产品的思路，值得借鉴学习。

先上一个功能架构图:

.. figure:: ../../../_static/kubernetes/network/cilium/1.12_cover.png
   :scale: 45

从Cilium 1.12发布的功能架构图可以看到Cilium将网络架构分为3个层次，同时结合了 :ref:`container_runtimes` 安全加固:

- 底层: 

我们来对比一下阿里云 `阿里云 ACK 容器服务生产级可观测体系建设实践 <https://mp.weixin.qq.com/s/s8rNywGbGReTBFXp2PWMeA>`_ ACK可观测体系全景图金字塔，从上至下分为四层:

.. figure:: ../../../_static/kubernetes/network/cilium/aliyun_ack_observability.png
   :scale: 70

可以看到阿里云采用的开源工具软件堆栈和 Cilium 选型是相近的，除了日志采集系统从 :ref:`fluentd` 替换成阿里云自研的 iLogtail 。

参考
=======

- `Cilium 1.12 – Ingress, Multi-Cluster, Service Mesh, External Workloads, and much more <https://isovalent.com/blog/post/cilium-release-112/>`_
