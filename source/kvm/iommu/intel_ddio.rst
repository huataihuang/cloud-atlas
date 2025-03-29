.. _intel_ddio:

======================================
Intel Data Direct I/O技术(intel DDIO)
======================================

Intel Data Direct I/O技术(intel DDIO) 是Intel志强处理器E5和E7 v2引入的专有技术，提供了Intel以太网控制器(网卡)直接读写Inetel志强E5和E7 v2处理器 **缓存** 的能力。

随着现代处理器缓存的增加以及10Gb以太网广泛使用，采用Intel DDIO技术使得数据操作不再需要反复访问内存，而是直接使用处理器缓存作为I/O数据主要目的地和来源来更有效地处理I/O数据流。

这项Intel DDIO技术是Intel所有志强E5和E7 v2系列默认启用，不依赖于硬件，对软件不可见，也就无需更改驱动程序、操作系统、管理程序或应用程序。也就是说，这是一项Intel的黑盒技术，针对Intel以太网设备进行的硬件加速。

.. note::

   Intel Data Direct I/O技术是Intel处理器和Intel网卡结合的专有技术，带来直接处理器缓存高速存取的硬件加速。但是这项技术没有外部可控的部分，只要Intel以太网设备就会利用基于主机的处理，平衡性能、功耗、灵活性和成本。

参考
=====

- `Intel® Data Direct I/O Technology <https://www.intel.com/content/www/us/en/io/data-direct-i-o-technology.html>`_
