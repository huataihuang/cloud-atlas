.. _k8s_deploy:

======================
Kubernetes部署
======================

虽然 :ref:`install_run_minikube` 让我们能够轻而易举获得一个可用的单机测试环境，但是实际上生产环境部署需要实现极其复杂的高可用、高性能的容灾系统。本章节将模拟生产环境的部署交付工作，并为下一阶段的冗灾和故障演练打下基础。

最新的实践采用 :ref:`z-k8s_env` 准备的KVM虚拟化环境，实践中引用的服务器列表请参考 :ref:`priv_cloud_infra`

.. note::

   Kubernetes运行依赖 :ref:`container_runtimes` ，所以务必在部署Kubernetes之前完成对应 :ref:`container_runtimes` 的安装配置( **一定要使用满足K8s版本要求的runtimes** ，例如 K8s 1.24 必须使用 :ref:`containerd` 1.6.4+,1.5.11+ )

.. toctree::
   :maxdepth: 1

   k8s_fuck_gfw.rst
   bootstrap_kubernetes_single/index
   etcd/index
   bootstrap_kubernetes_ha/index
   stateless_application/index
   operator/index
   helm/index
   deploy_pod/index
   kubespray/index
   kops/index
   nginx_ingress.rst
   haproxy_ingress.rst
   istio_ingress.rst
   minikube_deploy_docker_registry.rst
   draft.rst
   kustomize.rst
   kuberbuilder.rst
   kubebox/index
   k8s_hosts_in_mbp/index
