.. _ring_buffer_dma_mmio:

==========================
Ring Buffer / DMA / MMIO
==========================

在我们使用 :ref:`ethtool` debug网络故障和优化网络性能时，会发现ethtool工具提供了很多底层硬件控制，包括DMA ring size调整。我们也经常会在手册中看到DMA这个概念。那么在Linux网络中，以太网的Ring Buffer以及DMA是什么原理，我们又该如何根据实际情况来调整参数呢？

DMA
========

DMA (Direct Memory Access) 顾名思义就是 "直接内存访问"，是指一个设备和CPU共享内存总线。DMA有主要优点： 通过和CPU共享内存总线，DMA可以实现IO设备和内存之间快速的数据复制(不论内存到设备还是设备到内存，都能够加速数据传输)。

DMA是一种古老的技术，甚至比主板发明的历史更救援，早在上个世纪1950年代到60年代，就已经在硬件上使用了DMA。

MMIO
======

MMIO(Memory Mapped Input Output) 内存映射输入输出，是一种允许CPU和硬件设备通讯的替代方案。MMIO设备的内存驻留地址完全任意。MMIO的优点是CPU架构不需要特殊设置就可以从硬件设备读取或写入数据。

Ring Buffer
=============

Ring Buffer 或 Circular Buffer (环形缓存) 是主内存的一段用于存储和获取数据的部分。通常用于FIFO(First In First Out, 先进先出)访问方式。Ring Buffer除了用于网卡数据包，它也被用于串口通讯。广义上，Ring Buffer的实现包括了一个存(put)指针和一个取(get)指针，以及在缓存中的对象计数(count of the number of items)。当更新最新对象的指针(就是最高地址)就是最早指针(也就是最低地址)，两者相等时表示这两个指针都在缓存的开始位置，也表明缓存已经清空。

当你把对象放入Ring Buffer，则put指针就移到下一个位置，此时指针就不相等，也就表示缓存中有数据。当你

.. note::

   Ring Buffer是一个环形堆栈，当最晚指针和最早指针重合，就表明缓存被清空。

参考
=====

- `Ring Buffer / DMA / MMIO explanation is needed <https://forum.allaboutcircuits.com/threads/ring-buffer-dma-mmio-explanation-is-needed.135998/>`_
