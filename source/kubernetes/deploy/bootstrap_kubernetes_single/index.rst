.. _bootstrap_kubernetes_single:

===============================
Kubernetes集群引导(单master)
===============================

这个章节内容是我早期实践真实部署的记录：

:ref:`single_master_k8s` 是单节点部署，有点类似 :ref:`install_run_minikube` ，所以仅作为个人学习和开发，不适合生产部署

2021年底，在二手 :ref:`hpe_dl360_gen9` 上，我构建了 :ref:`priv_cloud_infra` 实践了 :ref:`bootstrap_kubernetes_ha`

.. toctree::
   :maxdepth: 1

   kubeadm.rst
   single_master_k8s.rst
   change_master_ip.rst
