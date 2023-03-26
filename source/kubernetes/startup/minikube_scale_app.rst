.. _minikube_scale_app:

========================
Minikube的应用部署伸缩
========================

虽然在 :ref:`minikube_deploy_app` 后通过 :ref:`minikube_expose_app` 能够让外部访问到应用服务，但是可以发现，这样的部署只有一个Pod在运行应用程序。当系统负载流量增加时，单个Pod是无法支持业务的，这就需要使用Kubernetes的横向扩展能力。

**Scaling** 是通过修改Deployment的部署副本replicas来实现的。

伸缩(Scaling)概览
===================

.. figure:: ../../_static/kubernetes/kubernetes_scaling.svg

部署的伸缩是通过在可用资源上调度,创建新的Pod或删除运行的Pod来实现的，Kubernetes将按指定Pod数量增加或缩减Pod以提供恰当的负载能力。当具有多个应用程序运行实例(Pods)时，不仅具有更大的负载能力，也能够实现滚动升级而不影响系统。

伸缩应用
===========

我们在 :ref:`minikube_deploy_app` 中部署了Pod，名为 ``my-dev`` ，现在我们来扩展这个应用。

.. note::

   请注意，我的案例和 `Google提供的在线教程 <https://kubernetes.io/docs/tutorials/>`_ 不同，我采用了从 `Ubuntu Docker官方镜像 <https://hub.docker.com/_/ubuntu>`_ 从头开始定制镜像内容，所以初始的 ``my-dev`` 容器已经做了一定的内容修改（相当于自己做了一个和Google案例相同的容器），这样就需要把容器转换（存储）成自定义镜像，然后通过自定义镜像来重新部署应用。

部署私有镜像仓库
--------------------

请参考 :ref:`k8s_deploy_registry` 部署私有镜像仓库，通过私有镜像仓库，我们可以把前期自定义容器转换成镜像，并用自定义镜像创建我们需要的容器集群。

参考
=====

- `Scale Your App <https://kubernetes.io/docs/tutorials/kubernetes-basics/scale/scale-intro/>`_
- 
