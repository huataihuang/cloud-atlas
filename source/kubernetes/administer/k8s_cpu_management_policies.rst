.. _k8s_cpu_management_policies:

===============================
Kubernetes节点CPU管理策略
===============================

Kubernetes的设计思路是对用户屏蔽pod的底层细节。但是，为了能够调优性能(例如用户对延迟或性能有强要求)，则Kubernetes也提供了方法来实现复杂的节点CPU管理策略(但同时保持抽象简化)。

CPU管理策略
=============

默认情况下， Kubelet 采用 :ref:`linux_cfs_bandwidth_control` 来执行Pod的CPU约束。当节点运行了很多CPU密集型Pod时，工作负载可能会迁移到不同的CPU核心。这取决于调度时Pod是否被限制 ( ``throttled`` )以及在调度时是否有可用的CPU核心。很多工作负载对于这种CPU迁移并不敏感，因此可以无需干预就可正常工作。但是，也有一些工作负载对于CPU缓存亲和性(CPU cache affinity)和调度延迟敏感。这种情况下Kubelet允许替换CPU管理策略来获得更好的业务特性。

更改Kubelet策略不会对现有Pod起作用，所以正确的修改节点CPU管理策略需要:

- :ref:`drain_node`
- 停止Kubelet
- 删除旧的CPU管理器状态文件，默认为 ``/var/lib/kubelet/cpu_manager_state`` ，这将清楚CPUManager维护的状态，以便新策略设置的 ``cpu-sets`` 不会与之冲突
- 编辑 Kubelet 配置将CPU挂你策略更改为所需值
- 启动Kubelet

none策略
----------

``none`` 策略就是显式地启用现有的默认CPU亲和方案，不提供操作系统调度器默认行为之外的亲和性策略，也就是使用CFS配额

static策略
--------------

static 策略针对具有整数型 CPU requests 的 Guaranteed Pod， 它允许该类 Pod 中的容器访问节点上的独占 CPU 资源。这种独占性是使用 cpuset cgroup 控制器来实现的。

- 当 Guaranteed Pod 调度到节点上时，如果其容器符合静态分配要求， 相应的 CPU 会被从共享池中移除，并放置到容器的 cpuset 中。
- 这种静态分配增强了 CPU 亲和性，减少了 CPU 密集的工作负载在节流时引起的上下文切换。

.. note::

   待实践

参考
======

- `控制节点上的 CPU 管理策略 <https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/cpu-management-policies/>`_
