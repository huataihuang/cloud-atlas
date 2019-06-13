.. _minikube_explore_app:

======================
在Minikube中探索应用
======================

Kubernetes Pods概念
====================

当我们 :ref:`minikube_deploy_app` ，Kubernetes创建了一个承载应用实例的 ``Pod`` 。所谓Pod就是Kubernetes抽象出来，用于表示一组包含一个或多个应用容器（例如Docker或rkt），以及一些共享给这些容器的资源。这些资源包括:

- 共享存储，例如Volume卷
- 共享网络，具有一个唯一的集群IP地址
- 有关如何运行每个容器的信息，例如容器镜像的版本或者使用的特殊端口

一个Pod能给一个特定应用 "逻辑主机" 模式，并且可以包含不同的应用容器，例如这些容器有相关性。举例，一个Pod可能会包含运行Node.js应用的容器以及一个将数据发送个Node.js web服务器的容器。

.. note::

   在一个Pod中的所有容器 ``共享`` **同一个IP地址以及端口范围** ，并且总是一起调度和分发，这样可以保证同一个Pod的相关所有容器都运行在一个相同Node节点上。

   你可以将Pod视为一个逻辑主机，这个逻辑主机中多个容器实际上就是这个主机上运行的多个进程，只不过进程间通过 namespace 和 cgroup 进行了良好隔离。这个逻辑主机可以在不同Node之间迁移，则这个逻辑主机中所有相关容器（进程）也就共同迁移。正是因为Pod是一个逻辑主机，所以只有一个IP地址和一个端口范围。

   当然，如果你以前学习过Docker概念，对Docker把容器比喻成集装箱的概念印象深刻的话，你可以继续把容器container想像成集装箱，但是是小尺寸集装箱。而包含多个容器的Pod就是一个大尺寸的集装箱，里面装了几个小集装箱（容器）。所以每次调度Pod的时候就是一起调度多个小集装箱（相关容器）。

   Pod 是Kubernetes平台的原子单位。当我们在Kubernetes中创建一个部署，这个部署将创建Pod并在Pod中运行容器。每个Pod会运行在调度到的Node节点上，并保持持续运行，直到Pod被终止（根据重启策略）或删除。当出现Node故障时，故障的Pod会被调度到集群其他正常节点上继续运行。

Pod概览
---------

.. figure:: ../../_static/kubernetes/kubernetes_pods.svg

- Pod可以包含一个或多个 containerd app
- Pod可以包含一个或多个（共享的）volume
- 一个Pod只有一个IP地址，这个IP地址是Pod中所有容器共享的

Kubernetes Nodes概念
======================

Pod总是运行在Node上。所谓Node就是在Kubernetes集群中的工作服务器，可以是虚拟机也可以是物理服务器。所有的Node节点都是由Master管理的。一个Node节点可以运行多个Pods，并且Kubernetes master会自动处理调度，以便将pods分布到整个集群。Master自动调度任务会对每个节点的可用资源进行记账。

每个Kubernetes Node极少具有:

- Kubelet: 负责在Kubernetes Master和Node之间通讯，负责管理主机上的Pod和容器。
- 一个容器运行时（container runtime)，例如 Docker, rkt : 负责从镜像中心（registry）拉取容器镜像，解包容器，并运行应用程序

Node概览
----------

.. figure:: ../../_static/kubernetes/minikube_nodes.svg

使用kubectl排查问题
====================

常用的kubectl命令如下:

- ``kubectl get`` - 列出资源
- ``kubectl describe`` - 显示一个资源的详细信息
- ``kubectl logs`` - 打印一个pod中的某个容器的日志
- ``kubectl exec`` - 执行一个pod中某个容器中的命令

参考
========

- `Viewing Pods and Nodes <https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/explore-intro/>`_
