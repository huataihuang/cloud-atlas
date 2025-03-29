.. _kubenetes_in_studio:

=====================
Studio中的kubernetes
=====================

在我的 :ref:`studio` 环境中，我采用多种模式来运行kubernetes:

- ``xcloud`` 物理主机，不使用kvm hypervisor，而是采用裸物理主机运行 minikube
  - 目标是最小化系统消耗，所有的计算资源都能能充分利用
  - 通过kubenetes来简化（或者说更熟悉Native Cloud）容器管理
  - 日常常用的应用和学习环境尽量容器化，并且通过minikube管理，促进自己对kubenetes的熟悉

- 通过KVM后端采用虚拟机运行minikube
  - 由于虚拟机可以方便重建和销毁，所以准备用于测试各种存在一定风险的实验环境
  - 主要用于开发测试

.. note::

   虽然KVM后端运行minikube提供了更好的系统隔离，但是对于个人使用开发测试环境，觉得浪费了部分计算资源用于虚拟化有些得不 偿失。所以目前我放弃了KVM方式运行minikube。不过，你可以自由选择上述两种方式，其中使用KVM方式可以更好隔离，使得自己的Host物理主机更为"干净"。

- 通过 :ref:``kubevirt`` 来实现多个KVM虚拟机运行一个手工部署的kubernetes集群
  - 主要是想绕开复杂的OpenStack部署底座同时能够测试一些前沿的kubenetes扩展技术

- 部署OpenStack集群，在OpenStack集群中运行kubernetes集群
  - 完整复杂的模拟实际生产环境
  - 实现全功能的测试

详细的部署方法，请参考：

- :ref:`install_run_minikube`
