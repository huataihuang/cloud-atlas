.. _docker_in_docker_arch:

======================
Docker in Docker架构
======================

在开发测试环境，为了能够建立一个完整的 :ref:`kubernetes` 集群，使用大量的物理服务器是不经济的。最初我采用 :ref:`kvm_docker_in_studio` 在一台物理主机上构建多个KVM虚拟机，然后再在虚拟机内部部署Docker来运行Kubernetes。

这种基于虚拟机运行的Kubernetes集群，在云计算厂商中较为流行，不过云计算厂商采用虚拟机的优势主要是：

- 虚拟机强隔离，弥补了容器隔离不彻底的安全隐患
- 继承了KVM虚拟机的成熟技术，例如热迁移，以及大量的成熟调度、资源分配技术

不过，对于测试环境以及内部使用的有安全保障的运行环境，嵌套KVM虚拟化和Docker容器带来了性能损耗。特别是个人电脑上模拟Kubernetes技术，大量的虚拟机资源消耗影响过大。

Docker in Docker背景
=======================

`Docker in Docker <https://store.docker.com/images/docker>`_ 可以在一个Docker系统中运行Docker镜像，实现一个本地化Kubernetes集群。在2017年时，可以通过GitHub项目 `Mirantis/kubeadm-dind-cluster <https://github.com/Mirantis/kubeadm-dind-cluster>`_ 来使用Docker in Docker设置一个Kubernetes集群。当然，你的底层Docker可以是运行在Linux上的Docker，也可以是macOS上的Docker Desktop。

.. note::

   `Mirantis/kubeadm-dind-cluster <https://github.com/Mirantis/kubeadm-dind-cluster>`_ 已停止开发，建议采用 :ref:`kind_cluster` 来实现这个部署。

.. note::

   和 :ref:`minikube` 不同的是：minikube是一个单节点kubernetes，没有扩展性，只能做基本的命令操作。Docker in Docker提供了完整的在单个节点上运行多个Docker节点来实现多节点Kubernetes集群。除了没有物理服务器的冗灾，Docker in Docker可以模拟完整的Kubernetes集群，并且 :ref:`kind_startup` 可以实现多集群模拟，以便能够测试不同的应用部署架构。

Docker in Docker 主要用于帮助Docker的开发，很多人用Docker in Docker来运行持续集成(CI，例如 :ref:`jenkins` )。

参考
=====

- `Setting up a Kubernetes cluster using Docker in Docker <https://callistaenterprise.se/blogg/teknik/2017/12/20/kubernetes-on-docker-in-docker/>`_
