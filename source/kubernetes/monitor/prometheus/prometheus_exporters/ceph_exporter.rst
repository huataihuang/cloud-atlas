.. _ceph_exporter:

========================
Ceph Exporter
========================

`Ceph Exporter(GitHub) <https://github.com/digitalocean/ceph_exporter>`_ 是 DigitalOcean 开源的Prometheus Exporter，为 ;ref:`ceph` 提供了 ``rados_mon_command()`` 包装监控，可以直接部署到一个运行的Ceph集群。

DigitalOcean的Ceph Exporter使用了Ceph官方提供的 :ref:`golang` 客户端来运行采集命令以支持通用的Ceph监控，所以需要配置一些环境变量来运行.

.. note::

   我准备实践Ceph官方的 ``Ceph MGR(s) Prometheus Metrics Endpoints`` : :ref:`ceph_dashboard_prometheus`

参考
======

- `Ceph Exporter(GitHub) <https://github.com/digitalocean/ceph_exporter>`_
