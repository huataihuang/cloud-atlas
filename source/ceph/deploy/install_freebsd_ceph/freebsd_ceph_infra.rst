.. _freebsd_ceph_infra:

=======================
FreeBSD云计算Ceph架构
=======================

作为 :ref:`bsd_cloud_infra` 架构的底层分布式存储:

- 采用 :ref:`thin_jail` 来模拟Ceph多节点
- 为上层 :ref:`bsd_cloud_infra` / :ref:`bsd_cloud_bhyve_infra` 提供支持

参考
======

- `Ceph docs: Ceph Internals » FreeBSD Implementation details <https://docs.ceph.com/en/quincy/dev/freebsd/>`_
