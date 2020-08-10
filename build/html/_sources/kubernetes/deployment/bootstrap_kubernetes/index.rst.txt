.. _bootstrap_kubernetes:

=======================
Kubernetes集群引导
=======================

这个章节内容是我实践真实部署的记录，不过由于kubernetes有多种部署模式，所以我这里概述如下：

- :ref:`single_master_k8s` 依然是单节点部署，有点类似 :ref:`install_run_minikube` ，所以仅作为个人学习和开发，不适合生产部署
- 真实的部署生产环境，则应该按照 :ref:`ha_k8s` 模式进行部署：
  - 首先部署 :ref:`ha_k8s_lb`
  - 然后在负载均衡环境中，就可以 :ref:`create_ha_k8s`
  - 然后进一步可以拆分etcd，完成 :ref:`ha_etcd` ，就构建 :ref:`ha_k8s_external` ，可以实现企业级Kubernetes

.. toctree::
   :maxdepth: 1

   kubeadm.rst
   single_master_k8s.rst
   change_master_ip.rst
   ha_k8s.rst
   ha_k8s_lb.rst
   create_ha_k8s.rst
   ha_k8s_stacked.rst
   ha_etcd.rst
   ha_k8s_external.rst
