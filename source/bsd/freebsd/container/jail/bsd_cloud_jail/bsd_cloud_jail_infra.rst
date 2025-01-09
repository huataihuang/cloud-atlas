.. _bsd_cloud_jail_infra:

========================
FreeBSD云计算Jail架构
========================

作为 :ref:`bsd_cloud_infra` 的Jail部分，在单机上构建Jail来实现开发运维，模拟大规模集群

- 结合 :ref:`thin_jail` 和 :ref:`vnet_jail` 在单机运行多个Jails
- 使用 :ref:`thin_jail_using_nullfs` 来构建Jail，但是做一些改进定制，以便尽可能实现同意更新系统
- 采用NullFS将Host主机ZFS dataset ``docs`` 提供给 :ref:`dev_jail` 以便在Jail内部完善的开发环境中进行开发
- Host主机ZFS 为 :ref:`pgsql_in_jail` 提供存储

.. note::

   在 :ref:`bsd_cloud_infra` 构建中我结合了FreeBSD Jail的不同技术组合，并适当调整以适配自己的架构。完整的技术解析和探索请参考 :ref:`freebsd_jail` 的实践。

   后续随着经验的积累会逐步优化和调整。

.. csv-table:: FreeBSD云计算主机分配
   :file: ../../../../../real/bsd_cloud/bsd_cloud_infra/hosts.csv
   :widths: 20, 20, 60
   :header-rows: 1
