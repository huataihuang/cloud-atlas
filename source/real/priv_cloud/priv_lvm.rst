.. _priv_lvm:

=====================
私有云数据层LVM卷管理
=====================

在 :ref:`priv_cloud_infra` 规划了 ``数据存储层(data)`` ，其中采用了三个 ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` :ref:`ovmf` 虚拟机pass-through读写 :ref:`samsung_pm9a1` 。这样，这三个虚拟机内部都会有一块完整NVMe磁盘，规划:

- 500GB: :ref:`zdata_ceph` 用于虚拟机存储
- 300GB: 也就是本文构建用于基础服务的 :ref:`linux_lvm` 部署各种基础服务( 详见 :ref:`priv_cloud_infra` 规划 )
- 200GB: 保留给未来技术实践分布式存储

.. note::

   :ref:`deploy_lvm` 详述技术细节，本文为精简


