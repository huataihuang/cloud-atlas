.. _priv_cloud_infra_2025_xcloud:

===============================
私有云架构2025: XCloud
===============================

2025年6月，在断断续续组装完 :ref:`nasse_c246` 台式机之后，开启了另一条基于 :ref:`freebsd` 的技术线路( :ref:`priv_cloud_infra_2025` 则继续采用 :ref:`lfs` Linux技术线路):

- 虚拟化和容器化:

  - :ref:`bhyve`
  - :ref:`freebsd_jail`

- 在FreeBSD构建一个新的生态，运行基础服务:

  - :ref:`ceph`
  - :ref:`pgsql`
  - :ref:`gitlab`

- 在FreeBSD的 :ref:`bhyve` 中运行 :ref:`linux` 来实现 :ref:`machine_learning`

  - :ref:`tesla_p10` 和 :ref:`tesla_t10` 廉颇老矣尚能饭否: 学习部署和维护基于 :ref:`kubernetes` 容器化的大规模集群
  - 从0开始系统学习

虚拟化服务器分布
=================

- xcloud集群的主机分配

.. csv-table:: xcloud服务器部署多层虚拟化虚拟机分配
   :file: priv_cloud_infra_2025_xcloud/hosts.csv
   :widths: 30, 30, 40
   :header-rows: 1
