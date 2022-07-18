.. _intro_cilium:

===============
cilium技术简介
===============

.. figure:: ../../../_static/kubernetes/network/cilium/cilium.png

Cilium是提供透明、安全网络链接和应用层(容器或进程)负载均衡的开源软件。Cilium工作在3/4层，提供了传统网络和诸如7层安全服务，以及对现代应用协议如HTTP, gRPC 和 :ref:`kafka` 提供安全防护。Cilium被集成到现代调度框架，如Kubernetes中。

Cilium的底层基础是现代化Linux内核提供的 :ref:`ebpf` ，支持动态插入eBPF字节码到Linux内核来实现集成: 网络IO, 应用sockets, 跟踪安全实现, 网络以及可视化逻辑。

.. figure:: ../../../_static/kubernetes/network/cilium/cilium_func.png
   :scale: 70

.. note::

   cilium 英文含义是 ``纤毛`` : 细胞表面上伸出的微小毛状突起，其有节律的运动可产生其周围的液体移动，或帮助单细胞生物的移动 ( `剑桥词典cilium <https://dictionary.cambridge.org/zhs/词典/英语-汉语-简体/cilium>`_ )

   可以看出cilium开源项目就和细胞上的 ``纤毛`` 一样，细微而重要的循环基础。

参考
=====

- `GitHub cilium <https://github.com/cilium/cilium>`_
