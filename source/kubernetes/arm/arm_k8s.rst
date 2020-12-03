.. _arm_k8s:

======================
ARM部署Kubernetes概述
======================

概述
=====

ARM架构已经得到了广泛的软件支持，包括Docker和Kubernetes。树莓派是当前应用最广泛的单板ARM计算机，廉价但性能可观的微型计算机设备，可以用来构建大量节点的分布式集群，甚至可以构建Beowulf cluster，替代了以往必须在笔记本上运行多个虚拟机来模拟集群的解决方案。

Collins撰写了一篇非常详尽的step-by-step指南，方便我们在3个或更多树莓派上构建Kubernetes集群。在此基础上，我们可以不断添加新的树莓派worker节点，也可以在Kubernetes上构建 :ref:`openshift` 以及各种 :ref:`web` 基础架构。

我的设备规划
=============

我在 :ref:`arm` 架构下，采用以下ARM设备来构建Kubernetes集群：

- 3台 :ref:`raspberry_pi` 树莓派4: 其中 1台作为master管控服务器(2G配置)，另外2台是worker节点(8G配置)
- 1台 :ref:`jetson` 作为worker节点，提供GPU设备构建GPU Docker容器，支持 :ref:`machine_learning`

参考
======

- `How Raspberry Pi and Kubernetes work together <https://enterprisersproject.com/article/2020/9/how-raspberry-pi-and-kubernetes-go-together>`_ - 提供了丰富的信息汇总
- `Build a Kubernetes cluster with the Raspberry Pi <https://opensource.com/article/20/6/kubernetes-raspberry-pi>`_ - 完整的部署指南
- `How to Build a Kubernetes Cluster with ARM Raspberry Pi then run .NET Core on OpenFaas <https://www.hanselman.com/blog/how-to-build-a-kubernetes-cluster-with-arm-raspberry-pi-then-run-net-core-on-openfaas>`_
