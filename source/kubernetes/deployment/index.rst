.. _kubernetes_deployment:

======================
Kubernetes部署
======================

虽然 :ref:`install_run_minikube` 让我们能够轻而易举获得一个可用的单机测试环境，但是实际上生产环境部署需要实现极其复杂的高可用、高性能的容灾系统。本章节将聚焦生产环境的部署交付工作，并为下一阶段的

.. toctree::
   :maxdepth: 1

   stateless_application/index
   operator/index
   install_etcd.rst
   deploy_nginx_ingress_controller.rst
   deploy_private_docker_registry_in_kubernetes.rst
   helm.rst
   draft.rst
   kustomize.rst
   kuberbuilder.rst
   terraform.rst
