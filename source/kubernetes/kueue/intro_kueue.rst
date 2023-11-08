.. _intro_kueue:

==================
Kueue简介
==================

批处理管理缘起
================

早期的Kubernetes专注于微服务工作负载调度，随着Kubernetes发展已经逐步进入HPC(高性能计算)领域，提供了构建批处理平台的强大而灵活的工具。这种转变是由于 :ref:`machine_learning` 不断增长的训练需求，以及高性能计算(HPC)系统向云转变的引发。

PGS在2022年Google Cloud Next ’22上宣布采用Google Cloud Platform构建了相当于世界排名第七的超级计算机， `使用1.2M vCPU运行在云端和Spot VM替代本地Cray超级计算机 <https://www.pgs.com/company/newsroom/news/industry-insights--hpc-in-the-cloud/?utm_source=thenewstack&utm_medium=website&utm_content=inline-mention&utm_campaign=platform>`_ 。

在 :ref:`big_data` 和 :ref:`machine_learning` 领域，采用批处理工作负载的用户通常依赖 Slurm, Mesos, HTCondor 或 Nomad 这些框架，为批处理任务提供必要的功能和扩展性。但是这些框架缺乏Kubernetes的提供的充满活力的生态系统(vibrant ecosystem)，社区支持以及集成功能。现在Kubernetes社区投入大量资源，组建批处理工作组(Batch Working Group)致力于增强Kubernetes的批处理功能里。

Batch Working Group对Job API进行大量改进，使其支持更广泛的批处理工作负载。改进后的API允许用户管理批处理作业，提供可扩展性、性能和可靠性增强。

Kueue项目
===========

`Kueue作业调度系统 <https://kueue.sigs.k8s.io/>`_ 是Batch Working Group开发的专为Kubernetes批处理工作负载而设计，提供Job优先级(job prioritization)、回填(backfilling)、资源风格编排(resource flavors orchestration)和抢占(preemption)，以确保高效、及时地处理批处理作业，同时保持资源使用效率最大化。

Kueue正在致力于构建与 :ref:`kubeflow` , Ray, :ref:`spark` 和 :ref:`airflow` 等各种框架的集成。这些集成使得用户能够利用Kubernetes的强大功能和灵活性，同时利用这些框架的专业能力，从而创建无缝且高效的批处理体验。

此外，Kueue还计划提供增强功能，包括自动缩放的作业级配置API(job-level provisioning APIs in autoscaling)，嗲赌气插件、节点运行时增强等。

Kubernetes广泛的多租户、丰富的生态以及主要云计算厂商托管服务使得其成为寻求批处理任务优化和充分利用云计算的最佳选择。目前在批处理领域，有不同的框架以及方式实现通用概念(作业、作业组、作业队列)。未来可能会更快的发展，所以研究和学习 ``Kueue`` 项目，会对未来 :ref:`machine_learning` 发展有很大的助力。


参考
======

- `Kubernetes Evolution: From Microservices to Batch Processing Powerhouse <https://thenewstack.io/kubernetes-evolution-from-microservices-to-batch-processing-powerhouse/>`_
