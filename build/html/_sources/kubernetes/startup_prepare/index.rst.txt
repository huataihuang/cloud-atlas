.. _kubernetes_startup_prepare:

=========================
Kubernetes起步准备
=========================

我们学习了 :ref:`kubernetes_overview` 之后，要开始动手实践了。不过，Kubernetes的架构非常复杂，倘若一开始就搭建一个完整的集群系统，是非常困难的任务。我们的实践之旅从单机版Kubernetes开始，即minikube。

通过minikube不仅可以实践Kubernetes的运维管理，也是构建Kubernetes开发环境的基础。后续我们将在这个minikube环境中运行不同的容器环境，用于开发软件以及开发Kubernetes自身。

.. toctree::
   :maxdepth: 1

   install_run_minikube.rst
   install_setup_kubectl.rst
   remote_minikube.rst

