.. _kvm_sim_numa:

=====================
KVM模拟NUMA配置
=====================

在 :ref:`hpe_dl360_gen9` 硬件提供了 :ref:`numa` 支持，可以通过NUMA优化性能。我在部署 :ref:`kubernetes` 以及 :ref:`openstack` 时候，都需要模拟生产环境的NUMA结构。本文是实践 :ref:`k8s_numa` 的准备工作:

- 从 :ref:`priv_kvm` 创建的模版 centos7 :ref:`clone_vm` ``z-pi-worker3`` (192.168.6.251)
- 配置虚拟化NUMA
- 加入到 :ref:`arm_k8s_deploy` 作为工作节点
- 实践 :ref:`k8s_numa`

NUMA和模拟
===========

:ref:`kernel_numa` 已经详细介绍了CPU和就近访问周边设备的架构，简单来说，就是由于CPU被切分成 ``cluster`` 节点，需要精心部署是的CPU尽可能究竟访问相同NUMA节点的内存。

对于我的测试服务器 :ref:`hpe_dl360_gen9` ，安装了2个物理处理器，在配置了 :ref:`dl360_bios_numa` 后检查::

   numactl -H

可以看到双处理器有2个node::

   available: 2 nodes (0-1)
   node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 24 25 26 27 28 29 30 31 32 33 34 35
   node 0 size: 32032 MB
   node 0 free: 25574 MB
   node 1 cpus: 12 13 14 15 16 17 18 19 20 21 22 23 36 37 38 39 40 41 42 43 44 45 46 47
   node 1 size: 32249 MB
   node 1 free: 24991 MB
   node distances:
   node   0   1
     0:  10  21
     1:  21  10

上述CPU拓扑提供了以下信息:

- 每个cpu node配置32G内存(32032 MB)
- ``node distance`` 显示了同一处理器节点访问内存开销是 1ns (10) ，而跨处理器节点访问内存开销是 2.1ns (21)

KVM虚拟机的NUMA nodes
-----------------------

参考
======

- `Using KVM to simulate NUMA configurations for OpenStack <https://www.redhat.com/en/blog/using-kvm-simulate-numa-configurations-openstack>`_
