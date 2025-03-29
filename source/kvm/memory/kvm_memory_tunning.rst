.. _kvm_memory_tunning:

==========================
KVM内存优化
==========================

在虚拟化技术中，为了能够将服务器资源充分发挥，通过在物理服务器运行更多虚拟机来提高CPU利用率。但是，对于物理主机来说，随着 :ref:`nvme` 技术的广泛使用，存储已经不再是虚拟化的瓶颈，物理主机内存往往限制了服务器的性能发挥。

所以，对于服务器而言，例如我采用二手的 :ref:`hpe_dl360_gen9` 就可以通过大量扩容内存来实现在一台单一物理服务器上运行大量的虚拟机来构建 :ref:`priv_cloud_infra` 。但是，物理内存毕竟是有限的资源，如何提高虚拟化内存的使用效率，对于性能有极大价值。

透明页面共享(Transparent Page Sharing)
==========================================

透明页面共享(Transparent Page Sharing, TPS)，对于KVM而言也称为内核相同页面合并(Kernel Samepage Merging)，对于Xen而言称为Memory CoW，其技术的本质是RAM内存重复数据删除。(是不是很耳熟？现代存储技术中常用的重复数据删除技术)

在虚拟化，多个几乎相同的工作负载，如果工作负载使用的大部分内存内容相同，则可以将内存指针放到第一个版本上。如果工作负载对内存页面修改，则更改写入新的内存页面。

内存压缩(Memory Compression)
================================

内存压缩(Memory Compression)技术是基于很多内存页面可能长时间不会修改，则非常适合压缩以释放内存。内存压缩技术是一种较旧的技术，比上述透明页面共享技术效率低，但是在很多内存有限的环境中非常有用。内存压缩技术最早是VMware ESX 4.1引入，现在已经在很多其他的Hypervisor中使用。

`compcache项目 <https://code.google.com/archive/p/compcache/>`_ 是一个十多年历史的开源项目，并且已经发展成 :ref:`zram` 于 :ref:`kernel` 3.14版本时合并到主线。所以 :ref:`zram` 可以直接被用于 :ref:`kvm` 和 Xen。不过，这项技术也是有争议的，是否公开使用取决于发行版或供应商。

内存膨胀(Memory Ballooning)
==============================

内存膨胀(Memory Ballooning)是比透明页面共享和内存压缩技术更为有趣的内存管理技术。通常传统的hypervisor和VM之间的关系是，VM中的操作系统并不知道自己工作在虚拟环境，所以对虚拟硬件的使用就好像裸金属物理主机一样。而在现代化虚拟化技术方案中，hypervisor guest工具会提供允许Guest虚拟机操作系统和hypervisor协作，来实现更为高效率的内存管理，也就是内存膨胀(Memory Ballooning)。

内存膨胀(Memory Ballooning)允许Guest虚拟机操作系统通过Guest工具通知hypervisor它当前不需要的一部分内存。此时hypervisor就可以回收这部分内存用于其他地方，通常是其他VM。放弃内存的VM是直到其分配内存数量的，所以当这些Guest操作系统需要更多内存时，只要通知hypervisor就能够取回之前分配给它的内存。这种内存膨胀(Memory Ballooning)技术存在于 VMware, :ref:`kvm` 和Xen虚拟化中。

.. note::

   结合 **透明页面共享(Transparent Page Sharing) **  ,  **内存压缩(Memory Compression)**  ,  **内存膨胀(Memory Ballooning)** 这三项内存管理技术，就可以实现通常称为 **内存超卖** ( ``Memory Overcommit`` )的技术解决方案，可以在物理主机上分配超过其实际内存的超量内存的VM。

Hyper-V的动态内存(Dynamic Memory)
=====================================

微软的Hyper-V虚拟化采用动态内存技术，类似于 内存膨胀(Mmeory Ballooning)，即管理员不会为Guest虚拟机分配静态数量的内存，而是让Guest虚拟机根据需要向Hypervisor申请更多内存，并且Guest操作系统会通知虚拟机Hypervisor管理器部分内存没有使用，以便Hypervisor回收内存。不过当内存回收之后，Guest操作系统内存管理器会依然认为自己可以访问峰值时消耗的内存。

内存交换(Swapping)
=========================

内存交换(Swapping)是一项非常古老的内存管理技术，也就是到hypervisor用完物理内存之后，可以将内存页面写入到磁盘或者Flash中。由于现代硬件系统普遍使用高性能的Flash，如 :ref:`nvme` 闪存，所以这种swapping内存交换的缺点已经不像早期使用机械磁盘那么明显。

虽然 :ref:`nvme` Flash依然无法取代内存，但是很多情况下对于内存受限的系统，是一个可接受的紧急溢出容量，是不得已的解决方案。

参考
=======

- `Overcoming the RAM Bottleneck <https://virtualizationreview.com/articles/2016/11/28/overcoming-the-ram-bottleneck.aspx>`_
