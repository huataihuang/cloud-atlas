.. _iommu_cpu_pinning:

========================
IOMMU调优: CPU pinning
========================

为了使得PCI passthroughs 更为稳定和高性能，通过 ``CPU pinning`` 可以实现 :ref:`numa` 让处理器访问近端 PCIe 设备提高性能，同时也可以避免 ``缓存踩踏`` 导致性能下降。

原理
=======

KVM guest默认是运行在和虚拟机相同县城数量，这些县城由Linux调度器按照优先级和等级队列调度到任何可用的CPU核心。这种方式下，如果线程被调度到不同的物理CPU就会导致本地CPU缓存(L1/L2/L3)失效，此时会明显影响虚拟机性能。CPU pinning就是针对这种虚拟CPU分配到物理CPU上运行的问题，设置两者的映射关系，尽可能减少缓存失效。此外，现代CPU通常使用一种共享的L3缓存，精心配置虚拟CPU和物理CPU的映射，可以使得L3缓存近端访问，降低缓存失效。

在完成 :ref:`ovmf` 虚拟机设置添加NVMe pass-through 之后，从物理连接角度， :ref:`hpe_dl360_gen9` 的 PCIe 3.0 Slot 1 和 Slot 2 是和CPU 0(第一块CPU)直连的，所以最佳配置是将虚拟机的vcpu绑定到物理主机的 ``CPU 0`` 下的cpu core。

CPU拓扑
==========

现代CPU处理器硬件都是多任务的，在Intel CPU称为超线程 ``hyper-threading`` ， AMD处理器称为 ``SMT`` 。检查CPU拓扑，采用以下命令::

   lscpu -e

在 :ref:`hpe_dl360_gen9` 上 ``E5-2670 v3`` 处理器拓扑如下

.. literalinclude:: ../../../kernel/cpu/intel/xeon_e5/xeon_e5-2670_v3/lscpu_e5-2670_v3.txt
   :language: bash
   :linenos:
   :caption: XEON E5-2670 v3处理器拓扑

按照 :ref:`numa` 执行::

   numactl -H

在 :ref:`hpe_dl360_gen9` 上 ``E5-2670 v3`` 处理器NUMA结构如下

.. literalinclude:: ../../../kernel/cpu/intel/xeon_e5/xeon_e5-2670_v3/numa_e5-2670_v3.txt
   :language: bash
   :linenos:
   :caption: XEON E5-2670 v3处理器NUMA

请注意:

- 默认开启了超线程，所以一个CPU核心对应了2个超线程，为了最大化存储性能，需要将负载高的存储虚拟机分配到不同到CPU核心(超线程不冲突)
- 物理服务器上安装了2个CPU(socket)， ``SOCKET 0`` 对应了CPU 0， ``SOCKET 1`` 对应了CPU 1，也就是 ``node 0`` 和 ``node 1`` ; 在 ``numactl -H`` 输出中可以清晰看到::

   node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 24 25 26 27 28 29 30 31 32 33 34 35
   node 1 cpus: 12 13 14 15 16 17 18 19 20 21 22 23 36 37 38 39 40 41 42 43 44 45 46 47

- 由于 :ref:`hpe_dl360_gen9` 只在 ``Slot 1`` 提供了 :ref:`pcie_bifurcation` ，所以我把2块 :ref:`samsung_pm9a1` 通过NVMe扩展卡安装在 ``Slot 1`` ，把第3块 :ref:`samsung_pm9a1` 安装在 ``Slot 2`` 。这意味着，服务器的3块NVMe存储都是直接和 ``node 0`` 连接的，所以对应虚拟机也要 ``pinning`` 到这个 ``CPU 0`` 上，也就是CPU超线程 ``0 - 11`` 和 ``24 - 35`` 。这两组CPU超线程实际上对应的物理CPU core一共是12个。
- 我分配的 ``z-b-data-X`` 虚拟机共3个，采用 ``4c8g`` 规格，分配到 CPU 超线程 ``24 - 35`` 可以确保不重合，性能最大化

配置cpu pinning
=================

- 修订 ``z-b-data-1`` (举例) ::

   sudo virsh edit z-b-data-1

设置 ``vcpu`` 和 ``cpuset`` 对应映射关系::

     <vcpu placement='static'>4</vcpu>
     <cputune>
       <vcpupin vcpu='0' cpuset='24'/>
       <vcpupin vcpu='1' cpuset='25'/>
       <vcpupin vcpu='2' cpuset='26'/>
       <vcpupin vcpu='3' cpuset='27'/>
     </cputune>

- 然后启动虚拟机::

   sudo virsh start z-b-data-1

- 通过 :ref:`compare_iommu_native_nvme` ，可以看到 :ref:`fio` 启动4个jobs，物理服务器上繁忙的CPU就是 ``24 - 27`` 

参考
======

- `arch linux: PCI passthrough via OVMF <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF>`_
