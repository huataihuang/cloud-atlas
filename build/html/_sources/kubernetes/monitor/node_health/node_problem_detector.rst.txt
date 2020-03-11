.. _node_problem_detector:

========================
node-problem-detector
========================

node-problem-detector是处理节点不同问题传递给集群管理栈的上层系统的服务。在每个节点运行的 node-problem-detector 会侦测节点故障，并报告给apiserver。这个 node-problem-detector 可以运行为 DaemonSet 或者独立运行。当前在GCE集群中，node-problem-detector默认作为Kubernetes Addon激活。


参考
========

- `node-problem-detector <https://github.com/kubernetes/node-problem-detector>`_
