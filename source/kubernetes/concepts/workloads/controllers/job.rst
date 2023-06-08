.. _job:

=================
Job
=================

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
