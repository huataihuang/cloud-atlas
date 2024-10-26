.. _pi_5_nvme_zfs:

========================
树莓派5 NVMe存储ZFS
========================

.. _pi_5_nvme_zfs_prepare:

树莓派5 NVMe存储ZFS磁盘准备
================================

我在 :ref:`pi_soft_storage_cluster` 方案中采用了3台 :ref:`pi_5` ，每台 :ref:`pi_5` 配置了一个 :ref:`kioxia_exceria_g2` ``2TB`` 规格存储，按照 :ref:`pi_soft_storage_cluster` 规划划分磁盘:

.. csv-table:: 树莓派5模拟集群NVMe存储分区
   :file: ../../../../raspberry_pi/pi_cluster/pi_soft_storage_cluster/parted.csv
   :widths: 5, 15, 20, 30, 30
   :header-rows: 1
