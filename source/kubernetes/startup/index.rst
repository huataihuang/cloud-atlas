.. _kubernetes_startup:

=========================
Kubernetes快速起步
=========================

任何计算机技术的快速起步就是动手实践，我建议你采用两种方式：

- 如果你对Kubernetes不熟悉，那么可以使用minikube在本地主机上学习如何使用kubernetes，请参考 :ref:`kubernetes_startup_prepare` 中前2章 :ref:`install_run_minikube` 和 :ref:`install_setup_kubectl` 。

- 如果你已经对Kubernetes有实践经验，例如在公司内部使用过Kubernetes集群并且有一定的服务器部署基础，则建议参考 :ref:`k8s_deploy` 部署基于虚拟机环境的模拟真实生产环境的Kubernetes集群，然后再学习本章节快速起步。

本章节前半部分使用 :ref:`kubernetes_startup_prepare` 所安装的Kubernetes系统(minikube)。虽然远不是一个完整的高可用集群，但是麻雀虽小五脏俱全。我们将使用这个单机版Kubernetes练习如何部署和运行基本的应用容器，以便对Kubernetes有一个初步的概念。

本章节的后半部分则在较为真实的 :ref:`k8s_deploy` 集群上实践部署真正可对外提供服务的系统。

.. toctree::
   :maxdepth: 1

   minikube_deploy_app.rst
   minikube_explore_app.rst
   minikube_expose_app.rst
   minikube_deploy_nginx_ingrerss_controller.rst
   minikube_scale_app.rst
   best_practices/index
