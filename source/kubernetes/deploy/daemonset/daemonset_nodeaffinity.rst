.. _daemonset_nodeaffinity:

=============================
Daemonset ``nodeAffinity``
=============================

要使得 :ref:`daemonset` 运行在特定节点有以下两种方式:

- 设置 ``.spec.template.spec.nodeSelector`` ，则 ``DaemonSet controller`` 会将Pods创建到符合 :ref:`k8s_nodeselector` 的节点
- 设置 ``.spec.template.spec.affinity`` ，则 ``DaemonSet controller`` 会将Pods创建到符合 :ref:`k8s_nodeaffinity` 的节点

``.spec.template.spec.affinity``
==================================

- 为安装了GPU设备的节点打上标签:

.. literalinclude:: daemonset_nodeaffinity/label_gpu_node
   :language: bash
   :caption: GPU设备节点打标签标记有GPU设备

- 部署 :ref:`dcgm-exporter` Daemonset时候，需要确保只部署到安装有GPU的节点，否则DS会无法正常启动:

.. literalinclude:: daemonset_nodeaffinity/ds_nodeaffinity.yaml
   :language: yaml
   :caption: 通过 ``nodeAffinity`` 控制 :ref:`dcgm-exporter` Daemonset 部署
   :emphasize-lines: 12-20

``nodeAntiAffinity`` (其实还是 ``nodeAffinity`` )
===================================================

对于同时部署自己的 ``kube-prometheus-stack`` 和 :ref:`aliyun_prometheus` ，需要在部署阿里云 ``starship`` Agent节点避开不安装 :ref:`dcgm-exporter` Daemonset。不过，Kubernetes没有提供 ``nodeAntiAffinity`` ，实际上是通过 ``nodeAffinity`` 变相实现的(多个Label同时匹配来缩小部署范围):

- 为部署了 ``starship`` Agent服务器打标签:

.. literalinclude:: daemonset_nodeaffinity/label_gpu_node_dcgm
   :language: bash
   :caption: GPU设备节点打标签标记启动了starship的dcgm功能

- 然后为节点部署添加控制:

.. literalinclude:: daemonset_nodeaffinity/ds_nodeantiaffinity.yaml
   :language: yaml
   :caption: 通过增加 ``nodeAffinity`` 的 ``NotIn``  控制 :ref:`dcgm-exporter` Daemonset 不部署到已经运行了 ``starship`` 的节点
   :emphasize-lines: 21-24

参考
=======

- `Daemonset: Running Pods on select Nodes <https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/#running-pods-on-select-nodes>`_
- `Anti-Node Affinity ? <https://collabnix.github.io/kubelabs/Scheduler101/Anti-Node-Affinity.html>`_
