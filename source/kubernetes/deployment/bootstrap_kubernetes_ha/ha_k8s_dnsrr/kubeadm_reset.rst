.. _kubeadm_reset:

==================
kubeadm集群重置
==================

通常 :ref:`kubeadm` 通过 ``kubeadm init`` 或者 ``kubeadm join`` 来实现集群初始化和节点添加。但是，我在 :ref:`k8s_dnsrr` 部署时没有与时俱进正确配置适配 Kubernetes v1.24 的 :ref:`containerd` 网络，导致容器无法启动。后续虽然做了很多手工修复，但是感觉离最终解决还是差了一点点。所以，改为采用重置集群，重新开始部署方式。

``kubeadm reset`` 命令提供了对本地主机重置清理能力，是 ``kubeadm init`` 和  ``kubeadm join`` 逆过程:

- ``--dry-run`` 参数可以模拟运行，显示出 ``reset`` 指令会做哪些操作，这样方便预估影响。建议在实际运行 ``kubeadm reset`` 之前先使用这个参数模拟一下
- ``kubeadm reset`` 会清理掉节点本地文件系统上之前通过 ``kubeadm init`` 或 ``kubeadm join`` 命令创建的文件。例如，对于管控节点 ``reset`` 也会移除本地运行的 ``etcd`` 成员(如果是本地堆叠的etcd)，但是如果采用外部etcd，则不会清理外部etcd集群中任何数据，此时需要独立etcd清理(见下文)

清理管控平面节点:

.. literalinclude:: kubeadm_reset/kubeadm_reset
   :language: bash
   :caption: 清理kubernetes节点

提示信息:

.. literalinclude:: kubeadm_reset/kubeadm_reset_output
   :language: none
   :caption: 清理kubernetes节点

对于 :ref:`priv_deploy_etcd_cluster_with_tls_auth` ，etcd是独立运行的外部etcd集群，需要独立命令清理:

.. literalinclude:: kubeadm_reset/kubeadm_reset_clean_etcd
   :language: bash
   :caption: 清理kubernetes外部etcd集群数据

参考
=====

- `Kubernetes Documentation: kubeadm reset <https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-reset/>`_
