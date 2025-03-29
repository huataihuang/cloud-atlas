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

node-problem-detector 从不同的daemon采集节点问题，然后把这些异常暴露给上层，这样上层 :ref:`remedy_system` 就能感知这些问题。

异常API(Problem API)
======================

``node-problem-detector`` 使用 ``Event`` (事件) 和 ``NodeCondition`` (节点状况)来向apiserver报告问题:

- ``NodeCondition`` : 导致pods无不可用都持久性错误会被报告为 ``NodeCondition``
- ``Event`` : 有限影响pod的临时性异常将被报告为 ``Event``

异常Daemon(Problem Daemon)
============================

Problem Daemon是一个 ``node-problem-detector`` 的子服务进程。这个Problem Daemon是用来监控特定类型节点异常以及报告给 ``node-problem-detector`` 。

一个problem daemon应该是:

- 一个设计成采用用户案例方式的tiny daemon
- 一个现有节点监考你孤独监控服务集成到 ``node-problem-detector``

当前，problem daemon是作为 ``node-problem-detector`` 二进制程序的一个 ``goroutine`` 来运行，未来将分离 ``node-problem-detector`` 和 ``problem daemon`` 到不同容器，然后将两个容器组合成特定pod。

每一类problem daemon可以设置相应的 ``build tags`` 在汇编时候禁用，。如果在汇编时禁用，则所有的编译依赖，全局变量以及后台goroutines将被从编译执行包中裁剪掉。

.. _remedy_system:

Remedy Systems(纠正系统)
==========================

remedy system是一个用于通过NPD检测出问题后自动实现纠正的进程。remedy system关注node-problem-detector发现的事件或节点状态，并采取行动将Kubernetes集群恢复到健康状态：


参考
========

- `node-problem-detector <https://github.com/kubernetes/node-problem-detector>`_
- `Monitor Node Health <https://kubernetes.io/docs/tasks/debug-application-cluster/monitor-node-health/>`_
