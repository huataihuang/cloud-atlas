.. _k8s_events:

==================
Kubernetes events
==================

在我们日常Kubernetes维护中，经常会检查 Kubernetes events 来确定最近一段实践是否出现 集群范围 或 特定namesapce 相关的事件。这方便我们快速纵览和定位异常。

Kubernetes 默认保持 **最近一小时** 事件记录，这是通过 ``kube-apiserver`` 来负责保持的，所以也提供了一个参数::

   --event-ttl duration     Default: 1h0m0s
   Amount of time to retain events.

这个 ``--event-ttl`` 默认是一小时，多数集群都是采用这个默认值

事件存储方案
===============

.. note::

   `Kubernetes events — how to keep historical data of your cluster <https://medium.com/@andrew.kaczynski/kubernetes-events-how-to-keep-historical-data-of-your-cluster-835d685cc45>`_ 原文介绍了通过 :ref:`metricbeat` 将Kubernetes的 :ref:`metrics` 采集到 :ref:`elasticsearch` 进行分析

   我这里整理的概要有待实践

   此外，我在考虑是否可以采用 :ref:`loki` 这样的 :ref:`log_systems` 来实现类似的集群事件采集？


   

参考
======

- `Kubernetes events — how to keep historical data of your cluster <https://medium.com/@andrew.kaczynski/kubernetes-events-how-to-keep-historical-data-of-your-cluster-835d685cc45>`_
