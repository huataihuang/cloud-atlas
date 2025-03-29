.. _intro_velero:

=====================================
Velero简介 - 备份和迁移Kubernetes
=====================================

Velero (以前称为Heptio) 提供了备份和恢复Kubernetes集群资源和持久卷的工具：

- 备份集群并按需恢复
- 将集群资源迁移到其他集群
- 将生产集群复制到开发和测试集群

.. note::

   类似 :ref:`mirantis` 收购Docker Enterprise，老牌的虚拟化厂商VMware于2019年收购了Heptio，全面进入Kubernetes市场竞争。

Velero工作原理
=================

所有Velero操作 - 按需备份，定时备份，恢复 - 都是通过Kubernetes :ref:`k8s_crd` 来定义的一个客户资源，并且存储在 :ref:`etcd` 中。Velero也包含了用于执行备份，恢复和所有相关操作的自定义资源的控制器。可以通过Velero备份和恢复集群所有对象，或者通过type、namespace以及label来过滤对象进行备份和恢复。

参考
======

- `Velero Overview <https://velero.io/docs/v1.6/>`_
- `How Velero Works <https://velero.io/docs/v1.6/how-velero-works/>`_
