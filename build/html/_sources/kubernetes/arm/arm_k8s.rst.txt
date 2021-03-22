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
  - 我在2021年重新思考部署架构，准备参考 `How to Build a Kubernetes Cluster with ARM Raspberry Pi then run .NET Core on OpenFaas <https://www.hanselman.com/blog/how-to-build-a-kubernetes-cluster-with-arm-raspberry-pi-then-run-net-core-on-openfaas>`_ 调整成采用3台树莓派3作为管控节点，将原先的树莓派4B改造成纯工作节点，这样可以充分利用硬件性能。
  - 2021年初购买的 :ref:`pi_400` 可以作为性能测试以及客户端主机，来对整个集群进行压测和管理

- 1台 :ref:`jetson` 作为worker节点，提供GPU设备构建GPU Docker容器，支持 :ref:`machine_learning`

- 1台 :ref:`thinkpad_x220` 运行 :ref:`arch_linux` 作为模拟X86异构Kubernetes工作节点

- 若干台在远程服务器上运行 :ref:`kvm` 虚拟机，作为X86异构的Kubernetes工作节点，实现模拟现实数据中心Kubernetes集群异构。(这里有一个跨机房以及外网网段和内网网段问题，我在思考如何解决，或许需要采用复杂的VPC架构来解决)

部署和实践
============

通过上述ARM硬件组合 :ref:`arm_k8s_deploy` ，并完成 :ref:`kubernetes_in_action`

参考
======

- `How Raspberry Pi and Kubernetes work together <https://enterprisersproject.com/article/2020/9/how-raspberry-pi-and-kubernetes-go-together>`_ - 提供了丰富的信息汇总
- `Build a Kubernetes cluster with the Raspberry Pi <https://opensource.com/article/20/6/kubernetes-raspberry-pi>`_ - 完整的部署指南
- `How to Build a Kubernetes Cluster with ARM Raspberry Pi then run .NET Core on OpenFaas <https://www.hanselman.com/blog/how-to-build-a-kubernetes-cluster-with-arm-raspberry-pi-then-run-net-core-on-openfaas>`_ - 介绍了在6台树莓派3上构建完整的Kubernetes集群，对我有很大启发
- `luxas/kubernetes-on-arm开源项目 <https://github.com/luxas/kubernetes-on-arm>`_ 是一个早期(2016)年的项目，开发者介绍了 `Building a multi-platform Kubernetes cluster on bare metal with kubeadm <https://github.com/luxas/kubeadm-workshop>`_ 使用了不同的ARM设备构建了Kubernetes集群
