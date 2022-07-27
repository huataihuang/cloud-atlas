.. _intro_cilium:

===============
cilium技术简介
===============

.. figure:: ../../../_static/kubernetes/network/cilium/cilium.png

Cilium
===========

Cilium是提供透明、安全网络链接和应用层(容器或进程)负载均衡的开源软件。Cilium工作在3/4层，提供了传统网络和诸如7层安全服务，以及对现代应用协议如HTTP, gRPC 和 :ref:`kafka` 提供安全防护。Cilium被集成到现代调度框架，如Kubernetes中。

Cilium的底层基础是现代化Linux内核提供的 :ref:`ebpf` ，支持动态插入eBPF字节码到Linux内核来实现集成: 网络IO, 应用sockets, 跟踪安全实现, 网络以及可视化逻辑。由于 :ref:`ebpf` 运行在Linux内核，所以Cilium安全策略可以应用和更新而无需修改应用代码或者容器配置。

.. figure:: ../../../_static/kubernetes/network/cilium/cilium_func.png
   :scale: 70

.. note::

   cilium 英文含义是 ``纤毛`` : 细胞表面上伸出的微小毛状突起，其有节律的运动可产生其周围的液体移动，或帮助单细胞生物的移动 ( `剑桥词典cilium <https://dictionary.cambridge.org/zhs/词典/英语-汉语-简体/cilium>`_ )

   可以看出cilium开源项目就和细胞上的 ``纤毛`` 一样，细微而重要的循环基础。

Hubble
========

Hubble是一个分布式网络和安全可观测系统，基于Cilium和eBPF，能够以完全透明的方式深入了解服务的通信和行为以及网络基础设施。 通过 :ref:`ebpf` 所有可见行都是可编程的，通过动态方法最大程度减少开销，同时根据用户要求提供深入和详细的可见性:

- 服务依赖和通讯地图

  - 服务之间如何通讯、频率以及服务之间的依赖关系图
  - HTTP通讯、 :ref:`kafka` 的主题消费以及来去关系

- 网络监控和告警

  - 提供网络层4到层7的通讯分析
  - 当出现网络异常时提供告警，例如达到5分钟的DNS解析问题，TCP连接中断，TCP SYN请求无应答等异常情况

- 应用监控

  - HTTP服务的响应码分析(比例)
  - 对HTTP请求的95或99延迟分析，服务之间的响应分析

- 安全可观测性

  - 网络策略导致的阻塞
  - 那些服务访问了外部网络
  - 服务是否解析了特定DNS名字

Cilium + Hubble 的优势
========================

现代数据中心应用服务器架构已经转向面向服务的架构，也就是微服务:

- 大型程序被拆分成小型独立服务
- 服务之间通过API交互(使用HTTP等轻量级协议)
- 高度动态化: 随着负载变化扩展或收缩应用程序，以及 :ref:`kubernetes_ci_cd` 实现部署等滚动更新

由于微服务的高度动态化，IP地址在动态微服务环境会频繁变化，所以很难使用传统的Linux网络安全方法(如 :ref:`iptables`
)过滤IP地址和TCP/UDP端口。传统的网络安全需要在负载均衡表和访问控制表存储不断增长且频繁更新的数十万条规则，并且在微服务中为了安全，协议端口不再用于区分应用程序流量(端口被用于跨服务的各种消息)。在新的微服务架构中，IP变动是如此频繁，甚至生命周期只有几秒钟。再加上以往观测服务通常以IP地址作为识别标记，但是现在IP地址时刻变化且变化速度极快，已经不再能够通过IP来做安全标识了。

Cilium通过Linux :ref:`ebpf` 获得了透明插入安全可见性和强制执行能力。基于 服务/pod/容器身份 来标识代替了传统的IP地址识别方法，并且可过滤应用服务层(如HTTP)以及传统的第3层和第4层进行应用安全策略部署。这些都是通过 :ref:`ebpf` 实现，并且能够高度扩展，满足大规模环境。

参考
=====

- `GitHub cilium <https://github.com/cilium/cilium>`_
- `Introduction to Cilium & Hubble <https://docs.cilium.io/en/stable/intro/>`_
