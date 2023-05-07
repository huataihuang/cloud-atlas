.. _k8s_garbage_collecttion:

=========================
Kubernetes垃圾回收
=========================

.. note::

   我在测试 :ref:`kube-prometheus-stack_alert_config` 时，验证磁盘告警，向磁盘目录下填充数据，意外发现Kuberntes会自动将磁盘打爆(默认超过85%)的节点容器驱逐

参考
=======

- `Kubernetes 文档/概念/Kubernetes 架构/垃圾收集 <https://kubernetes.io/zh-cn/docs/concepts/architecture/garbage-collection/>`_
