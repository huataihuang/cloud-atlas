.. _bootstrap_kubernetes_ha:

===============================
Kubernetes集群引导(高可用)
===============================

采用 :ref:`z-k8s_env` 模拟真实的部署生产环境，我重新实践了 :ref:`ha_k8s` 模式进行部署：

- 在高性能存储服务器部署 :ref:`ha_etcd`
- 部署 :ref:`ha_k8s_lb`
- 然后在负载均衡环境中，就可以 :ref:`create_ha_k8s`
- 最后构建 :ref:`ha_k8s_external` ，实现企业级Kubernetes

整个环境基于我在 :ref:`hpe_dl360_gen9` 二手服务器上部署的 :ref:`priv_cloud_infra` :ref:`z-k8s_env` 的 :ref:`kvm` 虚拟机

.. toctree::
   :maxdepth: 1

   prepare_z-k8s.rst
   ha_k8s_lb/index
   ha_etcd.rst
   ha_k8s.rst
   ha_k8s_dnsrr/index
   create_ha_k8s.rst
   ha_k8s_stacked.rst
   ha_k8s_external.rst
