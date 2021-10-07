.. _real_think_init:

==================
真实架构的构想
==================

服务器
==========

- 内部网络环境，采用物理服务器，构建Kubernetes+OpenStack的私有云
  - 内部实现的是开发测试环境到生产环境之间的中间阶段，也就是 :ref:`continuous_integration` 中的模拟环境(staging)

.. note::

   参考 `Cilium 1.0.0-rc4 发布：使用 Linux BPF 实现透明安全的容器间网络连接 <https://www.infoq.cn/article/2018/03/cilium-linux-bpf>`_ ，由于 Cilium结合了Envoy实现代理并且使用最新的BPF实现内核包过滤和修改，并且我希望借鉴性能大师 `Brendan Gregg <http://www.brendangregg.com>`_ 对 `Linux BPF Superpowers <http://www.brendangregg.com/blog/2016-03-05/linux-bpf-superpowers.html>`_ 的指导，系统学习他撰写的 `BPF Performance Tools (book)
   <http://www.brendangregg.com/bpf-performance-tools-book.html>`_ 来掌握最新的Linux网络性能工具。

   在 :ref:`real` 探索中，staging和production环境，我将采用 Cilium 网络实现Kubernetes plugin。

   `Cilium官方文档 <https://docs.cilium.io/en/latest/>`_ 非常详尽，值得深入学习。

- 在云计算服务商购买一定数量的KVM虚拟机，构建基于Kubernetes的公有云

- 通过VPN打通内部私有云和外部公有云，实现：

  - 持续集成、测试、部署
  - 对外提供云计算服务

硬件
----------

:ref:`real_private_cloud_think` 后，我最终在2021年10月买了一台二手 :ref:`hpe_dl360_gen9` 来替代我之前模拟部署云计算技术的 :ref:`mbp15_late_2013` ，目标是验证服务器领域相关技术，例如 :ref:`numa` 。

OS
-------------

之前 :ref:`base_os` 多次尝试，我准备采用2种难易不同的方式来实现最底层直接安装在物理服务器上的操作系统:

- :ref:`ubuntu_linux` 将首先安装在 :ref:`hpe_dl360_gen9` 上作为最底层OS

  - LTS长期得到官方支持，并且内核以及应用程序都得到社区广泛测试
  - 快速实现大规模云计算虚拟化模拟

- :ref:`lfs_linux` 则是我下一阶段的底层OS

  - 我期望构建一个自己掌控的完整操作系统，验证更为精细的内核裁剪和配置
  - 最小化底层操作系统，降低安全风险以及最大化发挥硬件性能

目前第一阶段，以 Ubuntu Linux 为基础构建，将在后续再实践 ``双操作系统启动`` 切换 :ref:`lfs_linux` 实现完全定制系统
