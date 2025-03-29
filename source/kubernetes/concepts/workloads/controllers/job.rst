.. _job:

=================
Job
=================

概念
======

- Job 会创建一个或者多个 Pod，并将继续重试 Pod 的执行，直到指定数量的 Pod 成功终止。(当数量达到指定的成功个数阈值时，任务（即 Job）结束。)
- 删除 Job 的操作会清除所创建的全部 Pod。 挂起 Job 的操作会删除 Job 的所有活跃 Pod，直到 Job 被再次恢复执行。

简单的使用场景:

创建一个 Job 对象以便以一种可靠的方式运行某 Pod 直到完成。 当第一个 Pod 失败或者被删除（比如因为节点硬件失效或者重启）时，Job 对象会启动一个新的 Pod。

Job controller
=================

2022年底，随着 Kubernetes 1.26 发布，官方宣布了稳定Job controller已经发布:

- 与索引完成模式配合使用，作业控制器可以处理大规模并行批处理作业，支持多达 100k 并发 Pod
- Pod 故障策略的开发成为可能，该策略在 1.26 版本中处于测试阶段
- 为了在大型作业上获得最大性能，Kubernetes 项目建议使用索引完成模式。 在这种模式下，控制平面能够通过更少的 API 调用来跟踪作业进度。
- 对于批处理、HPC、AI、ML 或相关工作负载的操作员开发人员，社区鼓励使用 Job API 将准确的进度跟踪委托给 Kubernetes
- 1.26 开始逐步放弃 ``batch.kubernetes.io/job-tracking`` annotation，并且在1.27后不再使用，所以需要确保升级1.27前系统中没有采用该annotation的job

实现
------

- finalizer位于 pod 对象内部，记账则位于 Job 对象中，很难实现自动删除Pod中的finalizer并更新job中的计数器。新版本实现方法(三阶段的方法):

  - 对于每个终止的 Pod，将 Pod 的唯一 ID (UID) 添加到存储在所属Job的 ``.status`` 中的短期列表( ``.status.uncountedTermeratedPods`` )
  - 从Pod中删除Finalizer
  - **原子地执行** 以下操作:

    - 从短期列表中删除UID
    - 增加Job状态中的总体成功和失败计数器

- 复杂性在于:

  - Job控制器会无序地接收上述步骤1和步骤2中API更改结果: 新版通过为已经删除的Finalizer添加内存缓存来解决这个问题
  - 目前已经得到客户通过Job API在集群中运行数万个Pod的报告，所以标记1.26该功能为稳定版本( **看来还是初期阶段** )

.. _clean_up_finished_jobs_automatically:

自动清理完成的Job
==================

完成的Job通常有两种清理方式:

- 由某种更高级别的控制器来管理，例如 :ref:`cronjob` 基于特定的根据容量配置的清理策略进行清理
- 通过TTL控制器自动清理: 只需要设置Job的 ``.spec.ttlSecondsAfterFinished`` 字段，就可以让控制器清理掉已经结束的资源

**TTL控制器清理Job时，会级联式地删除Job对象** : 会删除掉所有依赖的对象，包括Pod及Job本身

参考
=======

- `Kubernetes 文档/概念/工作负载/工作负载资源/Job <https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/job/>`_
- `Kubernetes 1.26: Job Tracking, to Support Massively Parallel Batch Workloads, Is Generally Available <https://kubernetes.io/blog/2022/12/29/scalable-job-tracking-ga/>`_
