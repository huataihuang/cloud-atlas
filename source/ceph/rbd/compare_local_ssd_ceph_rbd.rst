.. _compare_local_ssd_ceph_rbd:

=========================================
比较KVM虚拟机本地SSD和Ceph RBD存储性能
=========================================

我在 :ref:`compare_iommu_native_nvme` 中，对比了在 :ref:`ovmf` 虚拟机内部采用IOMMU技术读写NVMe存储和裸物理机读写NVMe的性能差异。现在，按照 :ref:`priv_cloud_infra` 部署了 :ref:`ceph` 存储来提供虚拟机存储，也需要考虑分布式存储Ceph对性能的损耗。所以本文将采用相同的 :ref:`fio` 测试方法，对比性能差异。

.. note::

   我希望测试能够获得在分布式Ceph上运行的KVM虚拟机磁盘性能达到使用本地SSD的性能，毕竟底层硬件是性能更佳的NVMe，即使分布式消耗，也希望能够达到本地SSD磁盘性能。

测试环境
===========

- 虚拟机采用 :ref:`ceph_rbd_libvirt` 部署完全相同的 :ref:`ubuntu_linux` 20.04 ，虚拟机配置采用 ``4c8g`` 配置( ``vcpu=4`` 匹配 ``fio`` 测试命令 ``-numjobs=4`` 并发数量 )

磁盘性能测试
==============

测试说明
----------

- ``/dev/vda`` 磁盘已经安装了虚拟机操作系统，所以 ``fio`` 采用文件进行测试，和直接读写块设备文件有差异(存在操作系统缓存影响)，不过对于测试两个一致操作系统还是可以有一定对比性。
- 提供Ceph服务的3个虚拟机已经做了 cpu pinning ，分配到socket 0上的CPU核心; 但是由于我的 :ref:`hpe_dl360_gen9` 配置的XEON处理器是 :ref:`xeon_e5-2670_v3` ，物理核心数量有限，不考虑超线程已经全部一一分配给这3个Ceph虚拟机；所以我不确定Ceph客户端虚拟机绑定在同一个Socket的处理器上超线程cpu core上性能更好还是绑定到Socket 1的CPU核心更好(需要实测，并且我估计和负载、软件版本有关)
- 本次测试简化，没有绑定虚拟机的vcpu pinning

测试结果不精确，仅供参考

随机写IOPS(文件)
===================

- 测试命令::

   fio -direct=1 -iodepth=32 -rw=randwrite -ioengine=libaio -bs=4k -numjobs=4 -time_based=1 -runtime=60 -group_reporting -filename=${HOME}/fio -size=2g -name=test

- ``z-ubuntu20`` 本地SSD测试结果:

.. literalinclude:: compare_local_ssd_ceph_rbd/local_sdd_randwrite_iops.txt
   :language: bash
   :linenos:
   :caption: 本地SSD虚拟机 随机写IOPS

- ``z-ubuntu20-rbd`` Ceph RBD测试结果:

.. literalinclude:: compare_local_ssd_ceph_rbd/ceph_rbd_randwrite_iops.txt
   :language: bash
   :linenos:
   :caption: Ceph RBD虚拟机 随机写IOPS

让我有点吃惊， ``z-ubuntu20-rbd`` Ceph RBD 测试文件的随机写iops只有 ``4801`` ，虽然比 本地SSD测试iops ``1197`` 好很多，大约是4倍性能；但是，比直接 :ref:`ovmf` 读写单NVMe性能 ( ``629k`` ) 差距太大了，只有原始性能 0.7% ？ ``是不是测试方法的问题?``

.. note::

   ``z-b-data-1`` 、 ``z-b-data-2`` 和 ``z-b-data-3`` 上重新按照上述命令测试(读写文件而不是块设备)，减少测试差异进行对比(注意， ``z-b-data-1`` 和 ``z-b-data-2`` 位于物理主机的不同PCIe插槽，并且 ``1和2`` 是同一个PCIe采用 :ref:`pcie_bifurcation` 切分，而 ``3`` 是独立使用 PCIe 8x插槽 )

- 在 ``z-b-data-1`` 、 ``z-b-data-2`` 和 ``z-b-data-3`` 上划分一个测试分区，建立文件系统进行以便进行fio测试::

   parted /dev/nvme0n1 print

显示::

   Model: SAMSUNG MZVL21T0HCLR-00B00 (nvme)
   Disk /dev/nvme0n1: 1024GB
   Sector size (logical/physical): 512B/512B
   Partition Table: gpt
   Disk Flags:

   Number  Start   End    Size   File system  Name     Flags
    1      1049kB  500GB  500GB               primary

划分一个6G临时分区(从500GB开始到506GB结束，所以空间是6GB)，用于测试::

   parted -s -a optimal /dev/nvme0n1 mkpart primary 500GB 506GB
   mkfs.xfs /dev/nvme0n1p2

   mount /dev/nvme0n1p2 /mnt
   mkdir /mnt/test
   chown huatai:huatai /mnt/test

- 执行fio测试(以 ``huatai`` 用户身份执行)::

   fio -direct=1 -iodepth=32 -rw=randwrite -ioengine=libaio -bs=4k -numjobs=4 -time_based=1 -runtime=60 -group_reporting -filename=/mnt/test/fio -size=2g -name=test

.. literalinclude:: compare_local_ssd_ceph_rbd/iommu_2g_file_randwrite_iops.txt
   :language: bash
   :linenos:
   :caption: IOMMU虚拟机文件系统2GB文件 随机写IOPS

云盘性能分析
===============

- 对 ``1TB`` NVMe 磁盘设备文件进行 ``fio`` 随机读写压测，IO是随机分散到整个固态硬盘，所以整体性能卓越；而对单个文件(特别是只有 ``2GB`` 的小文件)测试随机读写压测，则IO只能局限于2GB的NVMe局部进行读写测试，所以性能 "下降" 到 ``2G/1024G = 1/512`` ，也就是只有整体设备读写性能的 ``1/512``
- 固态设备规格越小，同样型号的SSD性能越差；要 ``公平`` 测试性能，只能对比相同规格固态磁盘
- 对于云盘，也有类似的分散读写效应，也即是云盘越大，云盘分散读写到更多的底层固态设备块上，就能获得更高性能；此外，类似 :ref:`ceph` 的分布式存储，底层越多的 ``OSD`` 支撑，就能够获得更好的读写性能；这个性能是由 Ceph 的 ``PG`` 来决定的(分散度)，但同时分布式复制、网络性能、CPU繁忙、缓存冲突等等都会影响分布式存储性能，无法像直接访问NVMe设备那样获得稳定的一致性的性能

对磁盘文件系统上的文件进行 ``fio`` 测试得到的随机写IOPS非常低，之前在 :ref:`compare_iommu_native_nvme` 随机写IOPS高达 ``629k`` ，但同样的iommu虚拟机环境，对该设备上6GB分区中的2GB大小文件进行随机写测试，也只能获得 ``8180`` IOPS。仅比我构建的 Ceph RBD 随机写性能 ``4801`` 高70%，并不是数量级的差异。这也说明，对小规格文件进行测试只能做横向相同环境比较，没有绝对的测试意义。粗略估计，采用分布式Ceph存储，性能下降约40%。不过，这个性能完全可以通过扩大Ceph规模，构建更大规格云盘来调整到接近甚至超越的性能。

所以，我感觉测试绝对数值没有太大意义，通过配置完全可以改变测试结果数值。只有相对同样规格横向对比才能有一定参考意义，然而也是受到底层参数调整影响，所以我就不再做进一步的性能压测了(太磨损固态硬盘寿命了)。后续只有对 :ref:`ceph_tunning` 时，做参数对比才有测试意义。

目前初步可以确认:

- ceph构建的虚拟化分布式存储，存储性能大约是直接pass-through本地NVMe性能的 ``60%`` ，但是是虚拟化本地SSD磁盘(非pass-through)性能的 ``4倍`` ，所以应该能够满足我构建大规模 :ref:`priv_cloud_infra` 的需求

目前我将集中精力构建云计算，在完成部署的基础上，再做性能调优
