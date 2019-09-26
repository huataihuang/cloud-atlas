.. _kubernetes_deployment:

======================
Kubernetes部署
======================

虽然 :ref:`install_run_minikube` 让我们能够轻而易举获得一个可用的单机测试环境，但是实际上生产环境部署需要实现极其复杂的高可用、高性能的容灾系统。本章节将模拟生产环境的部署交付工作，并为下一阶段的冗灾和故障演练打下基础。

部署采用在KVM虚拟机环境，NAT虚拟网络中部署多个虚拟机，实现Kubernetes集群，域名 ``test.huatai.me`` 的测试环境。这个测试环境也是我用于开发软件的模拟线上部署测试。

.. toctree::
   :maxdepth: 1

   k8s_hosts.rst
   container_runtimes.rst
   bootstrap_kubernetes/index
   stateless_application/index
   operator/index
   etcd/index
   nginx_ingress.rst
   docker_registry.rst
   helm.rst
   draft.rst
   kustomize.rst
   kuberbuilder.rst
   terraform.rst
