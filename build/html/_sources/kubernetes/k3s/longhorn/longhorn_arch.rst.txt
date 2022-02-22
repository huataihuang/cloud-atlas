.. _longhorn_arch:

========================
Longhorn分布式存储架构
========================

Longhorn是采用Go开发的面向Kubernetes的分布式存储，和历史悠久的分布式 :ref:`ceph` 比较而言功能和结构较为简单:

- 主要实现 NFS 和 iSCSI 存储服务
- 底层实现3副本存储复制
- 从设计和开发初始就面向 :ref:`kubernetes` ，提供了 :ref:`helm` 部署的便利方式
- 结构简化可能有助于在 :ref:`k3s_arch` 中承担高可用分布式存储，有可能更为适合硬件较弱的 :ref:`edeg_cloud`

参考
=======

