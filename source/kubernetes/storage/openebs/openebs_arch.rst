.. _openebs_arch:

=============================
OpenEBS架构
=============================

**OpenEBS** 又称为 ``Container Attached Storage`` (基于容器的块存储):

- OpenEBS遵循微服务架构，本身作为一组容器部署在Kubernetes工作节点上，使用Kubernetes编排管理OpenEBS组件
- 完全构建于用户空间
- OpenEBS支持一系列存储引擎(storage driver)，通常使用案例:

  - Cassandra 这样的分布式应用程序可以使用 :ref:`localpv` 引擎实现低延迟写
  - :ref:`mysql` 和 :ref:`pgsql` 可以使用 :ref:`zfs` 引擎( :ref:`cstor` )进行恢复
  - :ref:`kafka` 这样的流媒体应用程序可以使用 :ref:`nvme` 引擎 :ref:`mayastor` (OpenEBS开发的NVMe-oF存储)

参考
=======

- `OpenEBS中文版 README.md <https://github.com/openebs/openebs/blob/main/translations/README.zh.md>`_
- `OpenEBS动态创建存储 <https://blog.51cto.com/liqingbiao/6051543>`_ 非常详尽的产品介绍，应该是官方文档的clone，我感觉需要多阅读几遍，并结合其包容的技术(例如 :ref:`zfs` :ref:`longhorn` 等)进行思考才能理解这个技术指南 
