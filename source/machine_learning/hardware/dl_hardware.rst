.. _dl_hardware:

======================
深度学习硬件指南
======================

GPU
=====

虽然机器学习也可以通过CPU来完成，但是GPU可以极大加速深度学习应用程序，相对时间精力而言，采用GPU是合适的选择。

在选择GPU时需要注意避免:

- 性能不佳硬件
- 内存不足
- 冷却不佳

选购PCIe接口GPU卡

RAM
=====

我个人感觉内存只最值得投资的能够获得较大性能提升的硬件。需要注意，采用时钟频率高的能够承担成本的最好的内存。

虽然机器学习的性能和内存大小无关，但是为了避免GPU执行代码在执行时被交换到磁盘，需要配置足够的RAM，也就是GPU所配置对等大小内存。例如使用24G内存的Titan RTX，你就至少需要配置24G内存。不过，如果你使用更多GPU并不需要更多内存。

不过，即使内存大小已经匹配了GPU卡上的内存量，仍然可能在处理极大的数据集出现内存不足。所以通常你应该购买经济能够承受的最大量的内存。

CPU
=====

机器学习使用GPU加速，则对CPU没有太大要求。

CPU和PCIe
===========

在CPU内存和GPU内存间传输数据就需要通过PCIe接口，所以PCIe带宽非常重要。特别是加载ImageNet训练图片集。不过，现在PCIe的带宽极大，通常除非使用了大量的GPU设备，例如4个GPU设备，则需要考虑PCIe通道是否足够，否则不需要太关注。

CPU核心
========

在深度学习中，很少有计算需要由CPU负责。不过需要观察实际运算时负载。

硬盘/SSD
===========

在深度学习中，硬盘驱动器通常不是瓶颈。通常在数据从磁盘加载是需要考虑磁盘性能。通常磁盘性能都能够满足要求，不过购买SSD磁盘依然是值得的，甚至可以购买NVMe SSD以获得比常规SSD更好的性能。

电源
====

电源是不应该忽视的组件，特别是GPU通常会消耗更多的电能。而且机器学习会需要大量时间演算，所以电源也非常重要。

CPU和GPU冷却
=============

对于现代计算机系统，高速运行产生大量的热量，需要及时组号设备冷却，否则会导致异常不稳定现象。

需要部署温度监控程序来见识GPU的温度，及时通过冷却来保证稳定运行。

.. note::

   对于个人，我觉得可以通过购买二手服务器以及二手显卡来构建GPU计算集群。在淘宝上有专用于多GPU的渲染AI牧场的服务器，专门设计过可以容纳很多GPU卡。

   如果侧重于虚拟化技术，兼顾深度学习，我觉得二手的机架服务器可以用低廉价格换得可靠运行的基座，然后插1~2快GPU卡完成深度学习训练。

   对于开始自学入门，可以从 :ref:`jetson` 这样的ARM结合GPU的廉价设备开始，先熟悉基本的机器学习框架和软件，再逐步根据需求升级硬件。

GPU - 深度学习关键
======================

.. note::

   由于2020年以来的芯片荒以及比特币挖矿导致GPU(显卡、计算卡)的价格水涨船高，目前2021年，二手显卡的价格都是当初全新购买价格的2倍，导致目前购买用于机器学习的GPU非常不划算。特别是仅仅为了学习和测试而不能产生效益的资金投入。

   我可能会采购非常入门的显卡来实践 :ref:`iommu` 以及 :ref:`sr-iov` 这样的虚拟化GPU技术，部署GPU集群以及使用 :ref:`kubernetes` 来实现GPU容器化部署。以及做一些初步的机器学习尝试。这部分实践暂时不需要采购昂贵的GPU，以便静待明年芯片荒度过之后，GPU降价以及新品推出实现更大的性价比，再考虑。

我的硬件设备
=============

从刚开始懵懵懂懂，2021年10月1000元购买了第一块 :ref:`tesla_p10` 到2026年1月冲动地剁手了2000元的 :ref:`tesla_a2` ，我前后购买过各种型号的GPU计算卡:

.. csv-table: 我先后购买的各种型号的GPU对比
   :file: dl_hardware/devices_compare.csv
   :widths: 20,20,20,20,20
   :header-rows: 1

需要注意，硬件规格中需要区分不同的微架构，例如 A2 的CUDA虽然只有 1280 的CUDA核心，数量上只有 P10 的CUDA核心数3840的1/3，但是A2的Ampere架构，引入了 **Concurrent Execution** (并发执行)，每个SM(流式处理器)单元可以在处理FP32浮点运算的同时，处理INT32整数运算。这使得A2的核心利用率极高，实测效率远超P10的Pascal老架构。

此外，A2的Ampere架构配备了第三代 :ref:`tensor_cores` ，在处理量化模型(GGUF/AWQ/GPTQ)时，能够实现硬件加速INT8/INT4计算，速度可以反超核心数量更多的P10。

此外，A2的新型Ampere架构，在支持现代推理优化技术( :ref:`flashattention` **2** , :ref:`pagedattention` )提供了硬件加速

参考
=======

- `A Full Hardware Guide to Deep Learning <http://timdettmers.com/2018/12/16/deep-learning-hardware-guide/>`_
- `Which GPU(s) to Get for Deep Learning: My Experience and Advice for Using GPUs in Deep Learning <https://timdettmers.com/2020/09/07/which-gpu-for-deep-learning/>`_
- `深度学习工作站攒机指南 <https://www.cnblogs.com/guoyaohua/p/deeplearning-workstation.html>`_
- `Dive into deep learning GPU购买指南 <https://zh.d2l.ai/chapter_appendix/buy-gpu.html>`_
