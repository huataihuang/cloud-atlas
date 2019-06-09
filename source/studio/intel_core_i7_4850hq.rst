.. _intel_core_i7_4850hq:

============================
Intel Core i7-4850HQ处理器
============================

.. note::

   在整个云计算模拟的环境中，底层硬件是一个必要条件，从Intel `Haswell系列 <https://ark.intel.com/content/www/us/en/ark/products/codename/42174/haswell.html>`_ 逐步开始支持完善的硬件加速 ``嵌套虚拟化`` ，提高了硬件的利用率，给我们模拟数据中心带来极大的便利。也就是说，本书的模拟集群技术需要2013年以后的Intel硬件支持（当然之前的硬件也能实现，但是硬件利用率会低很多）。

在我的测试环境使用的MacBook Pro 2015 later版本笔记本，使用的处理器是 `Intel® Core™ i7-4850HQ Processor <https://ark.intel.com/content/www/us/en/ark/products/76086/intel-core-i7-4850hq-processor-6m-cache-up-to-3-50-ghz.html>`_ 。

i7-4840HQ 处理器属于第四代Intel Core i7处理器，Code Nmae 是 `Crystal Well系列 <https://en.wikichip.org/wiki/intel/crystal_well>`_ ，和同期i7-4800MQ 处理器(Code Nmae `Haswell系列 <https://ark.intel.com/content/www/us/en/ark/products/codename/42174/haswell.html>`_  ，例如Intel Xeon process E5 v3也是Haswell系列，支持 :ref:`intel_rdt` )相似，具备以下高级特性

- Advanced Vector Extensions 2.0 (AVX2) Haswell系列是首款支持高级适量扩展指令集2.0的Intel志强处理器。AVX2对于高性能计算应用（如数据库和性能基准应用）带来改进
- Intel Cache Monitoring Technology (CMT) 高速缓存监控就是可以向操作系统（OS）或虚拟机监控器（VMM ）提供每台虚拟机（VM）高速缓存利用率信息，以便更好决策如何调度工作负载。
- Intel Virtual Machine Control Structure (Intel VMCS) shadowing技术降低客户机虚拟机监控器 (VMM) 从母 VMM 请求帮助的频率，这样可以大幅降低客户机 VMM 执行 VMREAD 和 VMWRITE 指令所带来的 VM 退出的情况。

.. note::

   `英特尔® 至强™ E5-2600 v3 产品家族 <https://software.intel.com/zh-cn/articles/e5-2600-v3-0>`_

Crystal Well
================

Crystal Well 是指具有L4缓存（一种用于高端Iris Pro的独立的eDRAM硅芯片）等同于Intel `Haswell <https://en.wikichip.org/wiki/Haswell>`_ 微处理器。这块eDRAM硅芯片和主Haswell芯片互相独立但是集成在一起。

.. note::

   非常巧的是，我所使用的MacBook Pro 2015 later版本笔记本芯片是等同于服务器Haswell芯片的Crystal Well系列，所以可以支持Intel硬件加速的嵌套虚拟化。

Crystal Well具有的真正的128MB L4缓存可以被CPU核心使用，但不仅仅用于Iris Pro(显卡核心)使用。例如，L3缓存内容会迁移到L4，L4缓存服务于GPU和CPU内存访问，而且内存访问是在CPU和GPU之间分区的。如果禁用了GPU，例如有另外一块GPU安装，则L4缓存会由CPU独占使用。

.. note::

   MacBook Pro 2015 later 使用的显卡在Linux安装默认识别的是NVIDIA ``GK107M [GeForce GT 750M Mac Edition]`` ，没有启用Intel集成的Iris显卡芯片，推测L4缓存会用于CPU，待验证。


