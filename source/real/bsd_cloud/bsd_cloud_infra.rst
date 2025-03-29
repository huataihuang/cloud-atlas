.. _bsd_cloud_infra:

======================
FreeBSD云计算架构
======================

2025年，突然心血来潮 "皈依" FreeBSD，准备在这一年在BSD系统上全方位探索服务器架构，所以有了在 :ref:`mbp15_late_2013` 上构建完整FreeBSD模拟云计算的规划:

- :ref:`freebsd_ceph_infra` 构建存储
- 主要通过 :ref:`freebsd_jail` 来模拟集群
- 部分涉及Linux核心内核无法使用Jail则采用 :ref:`bhyve` 虚拟化集群

.. csv-table:: FreeBSD云计算Jail主机分配
   :file: bsd_cloud_infra/hosts.csv
   :widths: 20, 20, 60
   :header-rows: 1

