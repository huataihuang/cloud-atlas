.. _z-k8s_cilium_kubeproxy_free:

==================================================
Kubernetes集群(z-k8s)配置Cilium完全取代kube-proxy
==================================================

:ref:`cilium_kubeproxy_free` 提供优化的网络架构

.. note::

   在 ``kubeadm`` 初始化集群时候就可以跳过安装 ``kube-proxy`` :

   .. literalinclude:: ../../kubernetes/network/cilium/networking/cilium_kubeproxy_free/kubedam_init_skip_kube-proxy
      :language: bash
      :caption: kubeadm初始化集群时跳过安装kube-proxy

   但是对于已经部署 ``kube-proxy`` 的集群需要谨慎操作(会断网)

已经安装 ``kube-proxy`` 的替换
========================================

- 对于已经安装了 ``kube-proxy`` 作为 DaemonSet 的Kubernetes集群，则通过以下命令移除 ``kube-proxy``

.. warning::

   删除kube-proxy会导致现有服务中断链接，并且停止流量，直到Cilium替换完全安装好才能恢复

.. literalinclude:: ../../kubernetes/network/cilium/networking/cilium_kubeproxy_free/delete_ds_kube-proxy
   :language: bash
   :caption: 移除Kubernetes集群Kube-proxy DaemonSet

- 设置Helm仓库:

.. literalinclude:: ../../kubernetes/network/cilium/installation/cilium_install_with_external_etcd/helm_repo_add_cilium
   :language: bash
   :caption: 设置cilium Helm仓库 

- 执行以下命令启用 cilium kube-proxy free 支持:

.. literalinclude:: ../../kubernetes/network/cilium/networking/cilium_kubeproxy_free/kubeproxy_replacement_helm_upgrade
   :language: bash
   :caption: Cilium替换kube-proxy

.. note::

   这里执行 ``helm upgrade`` 是因为我采用的是安装 :ref:`z-k8s` 时已经部署 :ref:`cilium` ，现在是更新配置。如果在安装时就启用 ``kube-proxy-free`` 则使用 ``helm install``

- 现在我们可以检查cilium是否在每个节点正常工作:

.. literalinclude:: ../../kubernetes/network/cilium/networking/cilium_kubeproxy_free/kubectl_get_cilium_pods
   :language: bash
   :caption: kubectl检查cilium的pods是否在各个节点正常运行

完成上述步骤即完成了 Kube-proxy 完全替换成 Cilium ，验证是否工作正常可通过 :ref:`z-k8s_cilium_ingress`
