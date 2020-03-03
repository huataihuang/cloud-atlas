.. _pod_overview:

============
Pod 概览
============

Pods概念
=========

``Pod`` 是Kubernetes应用的最基本执行单元 - 也就是在创建或部署Kubernetes对象模式的最小和最简单的单元。Pod相当于在集群中运行的进程。

Pod包装了一个应用程序的容器(或者在某些情况下，是多个容器)、存储资源、独一无二的网络IP以及容器如何运行的选项。Pod在Kubernetes中相当于一个应用程序的单一实例的部署单元，可以包含一个容器或紧密结合并共享资源的一组容器。

在Docker Pod中最常用的容器运行时(container runtime)是 :ref:`docker` ，但是实际上Pod也支持其他的容器运行时。

在Kubernetes集群中，Pod有两种主要使用方法：

* ``运行一个单一容器的Pod`` : ``每个Pod一个容器`` 的模式是Kubernetes最常使用的模式，这种模式下，你可以将Pod是为一个单一容器的再包装，这样Kubernetes通过管理Pod而不是直接管理容器来运行。
* ``运行多个需要共同运行的多个容器的Pod`` : 当一个应用需要紧密组合多个容器并且这些容器需要使用共享资源的时候，则使用多容器Pod。这种位于同一位置(co-located)的容器可以是一组服务的集合，即通过一个共享的卷容器输出服务文件，然后一个独立的 ``sidecar`` (边车) 容器刷新或更新这些文件。这样Pod通过将这些容器以及存储资源打包成一个单一的可管理对象。

参考
======

- `kubernetes官方文档：Pod Overview <https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/>`_
