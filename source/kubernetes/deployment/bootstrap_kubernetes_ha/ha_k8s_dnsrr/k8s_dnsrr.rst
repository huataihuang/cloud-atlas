.. _k8s_dnsrr:

========================================
基于DNS轮询构建高可用Kubernetes
========================================

.. note::

   在 :ref:`ha_k8s_lb` 部署中，负载均衡采用的是 :ref:`haproxy` 结合keeplived实现VIP自动漂移。可以在部署基础上改造DNSRR到负载均衡模式

在完成 :ref:`priv_deploy_etcd_cluster_with_tls_auth` ，具备了扩展etcd架构，就可以开始部署本文 ``基于DNS轮询构建高可用Kubernetes`` 。后续再补充 :ref:`haproxy` 这样的负载均衡，就可以进一步改造成 :ref:`ha_k8s_lb` 架构。

准备etcd访问证书
===================

由于是访问外部扩展etcd集群，所以首先需要将etcd证书复制到管控服务器节点，以便管控服务器服务(如apiserver)启动后能够正常读写etcd:

- 在管控服务器 ``z-k8s-m-1`` / ``z-k8s-m-2`` / ``z-k8s-m-3`` 上创建 ``etcd`` 访问证书目录，并将 :ref:`priv_deploy_etcd_cluster_with_tls_auth` 准备好的证书复制过来:

``etcd`` 客户端所需要的证书可以从 :ref:`priv_deploy_etcd_cluster_with_tls_auth` 配置的 ``etctctl`` 客户端配置找到对应文件

.. literalinclude:: ../../etcd/priv_deploy_etcd_cluster_with_tls_auth/etcdctl_endpoint_env
   :language: bash
   :caption: etcd客户端配置:使用证书
   :emphasize-lines: 4-6

将上述 ``etcdctl`` 客户端配置文件和Kubernetes访问etcd配置文件一一对应如下:

.. csv-table:: kubernetes apiserver访问etcd证书对应关系
      :file: k8s_dnsrr/etcd_key.csv
      :widths: 40, 60
      :header-rows: 1

- 分发kubernetes的apiserver使用的etcd证书:

.. literalinclude:: k8s_dnsrr/deploy_k8s_apiserver_key
   :language: bash
   :caption: 分发kubernetes的apiserver使用的etcd证书

.. note::

   我是在具备密钥认证管理主机 ``z-b-data-1`` 上作为客户端，通过ssh远程登录到 ``z-k8s-m-1`` / ``z-k8s-m-2`` / ``z-k8s-m-3`` ，执行上述 ``deploy_k8s_etcd_key.sh`` 分发密钥

配置第一个管控节点(control plane ndoe)
=======================================

- 创建 ``kubeadm-config.yaml`` :

.. literalinclude:: k8s_dnsrr/create_kubeadm-config
   :language: bash
   :caption: 创建第一个管控节点配置 kubeadm-config.yaml



参考
========

- `Creating Highly Available Clusters with kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/>`_ 官方文档综合了 :ref:`ha_k8s_stacked` 和 :ref:`ha_k8s_external` ，我在本文实践中拆解了 :ref:`ha_k8s_external`
