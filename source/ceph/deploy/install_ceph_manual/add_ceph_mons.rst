.. _add_ceph_mons:

=======================
Ceph集群添加ceph-mon
=======================

在 :ref:`install_ceph_mon` 我们已经安装部署了1个 ``ceph-mon`` 。虽然这样也能工作，Ceph monitor可以使用Pasos算法来建立一致性映射以及集群的其他关键信息。但是，对应稳定的集群，需要一个奇数数量的monitor，所以，推荐至少3个 ``ceph-mon`` ，为了在出现更多失效能够继续服务，可以部署更多 monitor ，如5个 ``ceph-mon`` 。

.. note::

   虽然 ``ceph-mon`` 是非常轻量级的监控服务，可以运行在OSD相同的服务器上。但是，对于生产集群，特别是高负载集群，建议将 ``ceph-mon`` 和 ``ceph-osd`` 分开服务器运行。这是因为高负载下，有可能 ``ceph-osd`` 压力过大影响 ``ceph-mon`` 的稳定性(响应延迟)，从而导致系统误判而出现雪崩。

部署monitor
================

- 登陆需要部署monitor的服务器，例如，我这里部署到 ``z-b-data-2`` 服务器上，执行以下命令创建mon默认目录::

   sudo mkdir /var/lib/ceph/mon/ceph-{mon-id}

实际命令::

   sudo mkdir /var/lib/ceph/mon/ceph-z-b-data-2
