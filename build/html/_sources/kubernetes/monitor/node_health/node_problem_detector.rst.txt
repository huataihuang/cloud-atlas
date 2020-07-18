.. _node_problem_detector:

========================
node-problem-detector
========================

node-problem-detector是处理节点不同问题传递给集群管理栈的上层系统的服务。在每个节点运行的 node-problem-detector 会侦测节点故障，并报告给apiserver。这个 node-problem-detector 可以运行为 DaemonSet 或者独立运行。当前在GCE集群中，node-problem-detector默认作为Kubernetes Addon激活。

node-problem-detector (NPD) 开发的目标是为了解决node运行的大量问题：

- 基础架构服务问题(Infrastructure daemon issues) 例如每个服务器上都需要运行ntp服务，基础服务监控和故障恢复决定了节点是否能够正常工作
- 硬件故障(Hardware issues) 例如故障的cpu，内存或者硬盘
- 内核异常(Kernel issues) 例如内核死锁，异常的文件系统
- 容器运行时异常(Container runtime issues) 例如无响应的运行时daemon

node-problem-detector 从不同的daemon采集节点问题，然后把这些异常暴露给上层，这样上层 :ref:`remedy_system` 

.. _remedy_system:

Remedy Systems(纠正系统)
==========================

remedy system是一个用于通过NPD检测出问题后自动实现纠正的进程。remedy system关注node-problem-detector发现的事件或节点状态，并采取行动将Kubernetes集群恢复到健康状态：


参考
========

- `node-problem-detector <https://github.com/kubernetes/node-problem-detector>`_
- `Monitor Node Health <https://kubernetes.io/docs/tasks/debug-application-cluster/monitor-node-health/>`_
