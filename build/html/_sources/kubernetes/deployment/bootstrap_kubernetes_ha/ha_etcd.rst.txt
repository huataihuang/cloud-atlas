.. _ha_etcd:

=====================
高可用etcd集群部署
=====================

在部署 :ref:`ha_k8s_external` 之前，首先需要搭建一套具有高可用冗灾的 :ref:`etcd` 集群。构建环境采用 :ref:`priv_cloud_infra` 中 ``z-b-data-X`` 3台通过 pass-through :ref:`iommu` 技术将 :ref:`nvme` 存储作为磁盘，单独划分出 :ref:`linux_lvm` 卷给 ``etcd`` 存储数据。 


参考
========

- `Tutorial: Set up a Secure and Highly Available etcd Cluster <https://thenewstack.io/tutorial-set-up-a-secure-and-highly-available-etcd-cluster/>`_
- `Set up a High Availability etcd cluster with kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/>`_ Kubernetes官方文档，通过 :ref:`kubeadm` 来部署安装，由于通过 ``kubeadm`` 包装，所以不如直接运行etcd指令简洁清晰，本文没有采用kubeadm，而采用直接运行
