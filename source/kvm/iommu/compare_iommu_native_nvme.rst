.. _compare_iommu_native_nvme:

===================================
比较IOMMU NVMe和原生NVMe存储性能
===================================

我通过 :ref:`ovmf` 将 :ref:`samsung_pm9a1` assign到kvm虚拟机，这种 pass-through 技术可以极大提升虚拟机的存储性能。本文将采用 :ref:`fio` 对比存储性能，观察能否满足性能要求，后续还会进行 :ref:`iommu_tuning`

.. note::

   在 :ref:`ovmf` 虚拟机指定NVMe设备前，需要先在物理主机上内核屏蔽了 NVMe 设备。所以要测试物理服务器，必须在内核没有屏蔽之前进行。

   由于我已经完成NVMe assign 给虚拟机 ``z-iommu`` ，所以我先在虚拟机内部完成fio测试，然后关闭虚拟机，去除内核屏蔽nvme设备。然后重启服务器，让物理主机能够访问NVMe设备，再进行对比测试。

磁盘性能测试
==============

iommu虚拟机
---------------

- 随机写IOPS::

   fio -direct=1 -iodepth=32 -rw=randwrite -ioengine=libaio -bs=4k -numjobs=4 -time_based=1 -runtime=60 -group_reporting -filename=/dev/nvme0n1 -name=test

测试结果:

.. literalinclude:: compare_iommu_native_nvme/iommu_randwrite_iops.txt
   :language: bash
   :linenos:
   :caption: IOMMU虚拟机 随机写IOPS

- 随机读IOPS::

   fio -direct=1 -iodepth=32 -rw=randread -ioengine=libaio -bs=4k -numjobs=4 -time_based=1 -runtime=60 -group_reporting -filename=/dev/nvme0n1 -name=test

测试结果:

.. literalinclude:: compare_iommu_native_nvme/iommu_randread_iops.txt
   :language: bash
   :linenos:
   :caption: IOMMU虚拟机 随机读IOPS

- 顺序写吞吐量::

   fio -direct=1 -iodepth=128 -rw=write -ioengine=libaio -bs=128k -numjobs=1 -time_based=1 -runtime=60 -group_reporting -filename=/dev/nvme0n1 -name=test

测试结果:

.. literalinclude:: compare_iommu_native_nvme/iommu_write.txt
   :language: bash
   :linenos:
   :caption: IOMMU虚拟机 顺序写吞吐量

- 顺序读吞吐量::

   fio -direct=1 -iodepth=128 -rw=read -ioengine=libaio -bs=128k -numjobs=1 -time_based=1 -runtime=60 -group_reporting -filename=/dev/nvme0n1 -name=test

测试结果:

.. literalinclude:: compare_iommu_native_nvme/iommu_read.txt
   :language: bash
   :linenos:
   :caption: IOMMU虚拟机 顺序读吞吐量

测试结果
============

.. csv-table:: IOMMU虚拟机和物理机 NVMe性能对比
   :file: compare_iommu_native_nvme/compare_iommu_native_nvme.csv
   :widths: 40, 30, 30
   :header-rows: 1

参考
=========

- `阿里云帮助文档: 测试块存储性能 <https://help.aliyun.com/document_detail/147897.html>`_
