.. _compare_iommu_native_nvme:

===================================
比较IOMMU NVMe和原生NVMe存储性能
===================================

我通过 :ref:`ovmf` 将 :ref:`samsung_pm9a1` assign到kvm虚拟机，这种 pass-through 技术可以极大提升虚拟机的存储性能。本文将采用 :ref:`fio` 对比存储性能，观察能否满足性能要求，后续还会进行 :ref:`iommu_tunning`

.. note::

   在 :ref:`ovmf` 虚拟机指定NVMe设备前，需要先在物理主机上内核屏蔽了 NVMe 设备。所以要测试物理服务器，必须在内核没有屏蔽之前进行。

   由于我已经完成NVMe assign 给虚拟机 ``z-iommu`` ，所以我先在虚拟机内部完成fio测试，然后关闭虚拟机，去除内核屏蔽nvme设备。然后重启服务器，让物理主机能够访问NVMe设备，再进行对比测试。

磁盘性能测试
==============

虚拟机配置
---------------

- 测试虚拟机的 ``vcpu`` 需要匹配 ``fio`` 的 ``numjobs`` 数量，按照我下文测试命令采用 ``-numjobs=4`` 所以配置虚拟机 ``vcpu=4``
- 虚拟机分配内存 16GB (可选)

随机写IOPS
------------

- 测试命令::

   fio -direct=1 -iodepth=32 -rw=randwrite -ioengine=libaio -bs=4k -numjobs=4 -time_based=1 -runtime=60 -group_reporting -filename=/dev/nvme0n1 -name=test

- 虚拟机测试结果:

.. literalinclude:: compare_iommu_native_nvme/iommu_randwrite_iops.txt
   :language: bash
   :linenos:
   :caption: IOMMU虚拟机 随机写IOPS

- 物理主机测试结果:

.. literalinclude:: compare_iommu_native_nvme/host_randwrite_iops.txt
   :language: bash
   :linenos:
   :caption: 物理主机 随机写IOPS

随机读IOPS
-------------

- 测试命令::

   fio -direct=1 -iodepth=32 -rw=randread -ioengine=libaio -bs=4k -numjobs=4 -time_based=1 -runtime=60 -group_reporting -filename=/dev/nvme0n1 -name=test

- 虚拟机测试结果:

.. literalinclude:: compare_iommu_native_nvme/iommu_randread_iops.txt
   :language: bash
   :linenos:
   :caption: IOMMU虚拟机 随机读IOPS

- 物理主机测试结果:

.. literalinclude:: compare_iommu_native_nvme/host_randread_iops.txt
   :language: bash
   :linenos:
   :caption: 物理主机 随机读IOPS

顺序写吞吐量
-------------

- 测试命令::

   fio -direct=1 -iodepth=128 -rw=write -ioengine=libaio -bs=128k -numjobs=1 -time_based=1 -runtime=60 -group_reporting -filename=/dev/nvme0n1 -name=test

- 虚拟机测试结果:

.. literalinclude:: compare_iommu_native_nvme/iommu_write.txt
   :language: bash
   :linenos:
   :caption: IOMMU虚拟机 顺序写吞吐量

- 物理主机测试结果:

.. literalinclude:: compare_iommu_native_nvme/host_write.txt
   :language: bash
   :linenos:
   :caption: 物理主机 顺序写吞吐量

顺序读吞吐量
----------------

- 测试命令::

   fio -direct=1 -iodepth=128 -rw=read -ioengine=libaio -bs=128k -numjobs=1 -time_based=1 -runtime=60 -group_reporting -filename=/dev/nvme0n1 -name=test

- 虚拟机测试结果:

.. literalinclude:: compare_iommu_native_nvme/iommu_read.txt
   :language: bash
   :linenos:
   :caption: IOMMU虚拟机 顺序读吞吐量

- 物理主机测试结果:

.. literalinclude:: compare_iommu_native_nvme/host_read.txt
   :language: bash
   :linenos:
   :caption: 物理主机 顺序读吞吐量

测试结果
============

.. note::

   我第一次测试 :ref:`ovmf` 虚拟机，设置了 ``1c2g`` 规格。实际上上述随机读写测试采用了4个job，我观察了实际上会把4个CPU核心打满。对于 ``1c2g`` 虚拟机由于只有1个cpu，会导致性能无法满足并发4个读写进程对要求: 测试结果读写性能只有物理主机的 1/4 不到

   第二次测试我分配了4cpu的虚拟机，并发果然跑满4个vcpu之后，虚拟机存储性能基本上接近物理主机存储性能

.. csv-table:: IOMMU虚拟机和物理机 NVMe性能对比
   :file: compare_iommu_native_nvme/compare_iommu_native_nvme.csv
   :widths: 14, 15, 15, 15, 15, 15, 11
   :header-rows: 1

- 采用 iommu 方式pass-through NVMe存储给虚拟机，结合了 :ref:`ovmf` (uefi)虚拟机 + :ref:`iommu_cpu_pinning` ，可以接近直接物理主机读写NVMe性能: 随机4k读写性能 92% ~ 94% ，顺序读写性能 99%

  - 后续准备实践 :ref:`huge_memory_pages` 以及 :ref:`cpu_frequency_governor` 、 :ref:`isolating_pinned_cpus` 技术来进一步提高虚拟化性能

- 由于我使用的二手 :ref:`hpe_dl360_gen9` 硬件是PCIe 3.0，所以对于 PCIe 3.0 x4 接口，最高只支持大约 3500 MB/s 接口速率，从我的 :ref:`fio` 测试来看

  - 物理读写NVMe存储受限于PCIe3.0接口，只能获得顺序读写能力50%(已接近理想值)和随机读写能力77%
  - 虚拟化消耗的存储性能不多，所以也能获得硬件顺序读写能力50%和随机读写能力72%
  - 对于我的模拟测试环境，采用iommu虚拟化存储应该能过满足部署大规模云计算需求

参考
=========

- `阿里云帮助文档: 测试块存储性能 <https://help.aliyun.com/document_detail/147897.html>`_
