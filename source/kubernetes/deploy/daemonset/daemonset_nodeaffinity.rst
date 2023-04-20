.. _daemonset_nodeaffinity:

=============================
Daemonset ``nodeAffinity``
=============================

要使得 :ref:`daemonset` 运行在特定节点有以下两种方式:

- 设置 ``.spec.template.spec.nodeSelector`` ，则 ``DaemonSet controller`` 会将Pods创建到符合 :ref:`k8s_nodeselector` 的节点
- 设置 ``.spec.template.spec.affinity`` ，则 ``DaemonSet controller`` 会将Pods创建到符合 :ref:`k8s_nodeaffinity` 的节点

``.spec.template.spec.affinity``
==================================

部署 :ref:`dcgm-exporter` Daemonset时候，需要确保只部署到安装有GPU的节点，否则DS会无法正常启动:

.. literalinclude:: daemonset_nodeaffinity/ds_nodeaffinity.yaml
   :language: yaml
   :caption: 通过 ``nodeAffinity`` 控制 :ref:`dcgm-exporter` Daemonset 部署
   :emphasize-lines: 12-20

参考
=======

- `Daemonset: Running Pods on select Nodes <https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/#running-pods-on-select-nodes>`_
