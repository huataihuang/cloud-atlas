.. _metrics-server:

====================
metrics-server
====================

安装
=====

``Metrics Server`` 可以通过 YAML manifest 直接安装，也可以通过官方的 `Metrics Server Helm Chart <https://artifacthub.io/packages/helm/metrics-server/metrics-server>`_ 安装

YAML安装
---------

- 执行以下命令安装最新版本 ``Metrics Server`` :

.. literalinclude:: metrics-server/kubectl_apply_metrics-server
   :caption: 采用YAML manifest安装 ``Metrics Server``

安装显示:

.. literalinclude:: metrics-server/kubectl_apply_metrics-server_output
   :caption: 采用YAML manifest安装 ``Metrics Server`` 的输出信息

- 检查运行 ``pod`` :

.. literalinclude:: metrics-server/kubectl_get_metrics-server_pod
   :caption: 检查安装的 ``metrics-server``

可以看到管控服务器上运行了一个 ``metrics-server`` :

.. literalinclude:: metrics-server/kubectl_get_metrics-server_pod_output
   :caption: 检查安装的 ``metrics-server`` 运行了一个实例

Helm安装
-----------

- 执行以下命令可以通过 :ref:`helm` chart 安装 ``Metrics Server`` :

.. literalinclude:: metrics-server/helm_install_metrics-server
   :caption: 采用Helm安装 ``Metrics Server``

高可用部署
------------

通过设置 ``replicas`` 值大于1，Metrics Server可以通过YAML manifest或者Helm chart部署高可用模式:

- 对于 Kubernetes v1.21+:

.. literalinclude:: metrics-server/kubectl_apply_metrics-server_ha
   :caption: 在Kubernetes v1.21+上部署高可用Metrics Server

对于 Kubernetes v1.19-1.21:

.. literalinclude:: metrics-server/kubectl_apply_metrics-server_ha_k8s_before_v1.21
   :caption: 在Kubernetes v1.19-1.21 上部署高可用Metrics Server

.. _kubectl_top:

``kubectl top``
================

部署 ``Metrics Server`` 之后，可以通过 ``kubectl top`` 来观察 Node 和 Pod 的工作情况:

- 检查node负载:

.. literalinclude:: metrics-server/kubectl_top_node
   :caption: 使用 ``kubectl top`` 可以观察Node负载

问题排查
------------

``kubectl top ndoe`` 我遇到一个报错:

.. literalinclude:: metrics-server/kubectl_top_node_err
   :caption: 使用 ``kubectl top node`` 报错

检查 ``metrics-server`` 的pod日志:

.. literalinclude:: metrics-server/kubectl_logs_metrics-server
   :caption: 检查 ``metrics-server`` 日志

输出显示:

.. literalinclude:: metrics-server/kubectl_logs_metrics-server_output
   :caption: 检查 ``metrics-server`` 日志显示证书错误导致无法抓取
   :emphasize-lines: 2,13-15

可以看出，由于不能验证被监控的服务器证书，导致抓取失败

在 `metrics-server (GitHub) <https://github.com/kubernetes-sigs/metrics-server>`_ 的文档中说明有运行参数:

- ``--kubelet-insecure-tls`` 运行参数将不会验证Kubelets提供的CA证书，但是这个运行参数不建议在生产环境使用

`Metrics server throwing X509 error in logs, fails to return Node or Pod metrics #1025 <https://github.com/kubernetes-sigs/metrics-server/issues/1025>`_ 社区答复是这个问题是因为k8s(dev/non-prod)发行版如minikube没有提供相应的证书设置以允许和Kubelet安全通讯，所以需要在 ``Metrics Server`` 的运行参数中使用 ``--kubelet-insecure-tls`` 。

`metrics-server (GitHub) <https://github.com/kubernetes-sigs/metrics-server>`_ 拒绝默认启用这个参数，而是要求k8s的发行版来fix这个问题。我的集群是通过 :ref:`kubespray` 快速部署的，所以这块的证书可能确实是存在问题的。

手工修订 ``kubectl -n kube-system edit deployment metrics-server`` 添加配置如下:

.. literalinclude:: metrics-server/kubectl_edit_metrics-server
   :language: xml
   :caption: 修订 ``metrics-server``
   :emphasize-lines: 5

使用
------

- 简单使用检查Node:

.. literalinclude:: metrics-server/kubectl_top_node
   :caption: 使用 ``kubectl top`` 可以观察Node负载

输出显示类似:

.. literalinclude:: metrics-server/kubectl_top_node_output
   :caption: 使用 ``kubectl top`` 可以观察Node负载输出案例

注意，这里 ``top`` 显示的cpu类似 ``757m`` 表示 ``0.757`` 个CPU ( 1000m 相当于 1 CPU )

- 检查pods:

.. literalinclude:: metrics-server/kubectl_top_pod
   :caption: 使用 ``kubectl top`` 可以观察pod

可以按照cpu排序(没有指定namespace则是default):

.. literalinclude:: metrics-server/kubectl_top_pod_cpu
   :caption: 使用 ``kubectl top`` 可以观察按cpu排序pod(默认namespace)

.. literalinclude:: metrics-server/kubectl_top_pod_cpu_output
   :caption: 使用 ``kubectl top`` 可以观察按cpu排序pod(默认namespace)

- 观察指定namespace并且按照cpu排序:

.. literalinclude:: metrics-server/kubectl_top_pod_cpu_kube-system
   :caption: 使用 ``kubectl top`` 观察 ``kube-system`` namespace 按cpu排序pod

.. literalinclude:: metrics-server/kubectl_top_pod_cpu_kube-system_output
   :caption: 使用 ``kubectl top`` 观察 ``kube-system`` namespace 按cpu排序pod输出

进一步
=======

``kubectl top`` 虽然使用方便，但是展示的信息维度有限，在Kubernetes的 `Kubernetes社区sig-cli <https://github.com/kubernetes/community/blob/master/sig-cli>`_ 提供了 ``kubectl`` 以及一系列相关工具，其中 :ref:`krew` 的 ``resource-capacity`` 插件提供了多角度分析集群资源使用情况。

参考
=====

- `metrics-server (GitHub) <https://github.com/kubernetes-sigs/metrics-server>`_
- `Kubectl Top Pod/Node | How to get & read resource utilization metrics of K8s? <https://signoz.io/blog/kubectl-top/#what-is-kubectl-top-command>`_
- `Metrics server throwing X509 error in logs, fails to return Node or Pod metrics #1025 <https://github.com/kubernetes-sigs/metrics-server/issues/1025>`_
- `通过 Metrics Server 查看 Kubernetes 资源指标 <https://www.cnblogs.com/-k8s/p/18076869>`_
