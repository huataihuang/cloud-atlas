.. _intel_vroc_arch:

================================
Intel Virtual RAID on CPU架构
================================

.. note::

   Intel Virtual RAID on CPU技术对硬件的最低要求是使用 Xeon Scalable Processors ，也就是 Skylake-SP 。目前我的二手硬件 :ref:`hpe_dl360_gen9` 差距实在太大(落后了2代) 是无法实践的，所以本文仅做技术搜集和索引，以后有机会再做实践。

Intel Virtual RAID on CPU (Intel VROC)是一种基于NVMe固态硬盘(SSDs)结合最新的Intel Xeon Scalable processor PCIe lanes实现的硬件级别RAID。这种RAID技术不使用传统的RAID HBA卡，而是CPU处理器直接访问NVMe存储，使用CPU内置的RAID功能来实现高性能NVMe RAID。

Intel VROC释放了NVMe存储的性能，支持不同级别的RAID (RAID 0,1,5,10) 。

Intel VROC需要使用最新的Intel Xeon Scalable processors处理器的Volume Managemnet Device(Intel VMD)硬件功能，通常是OEM/ODM提供平台配置功能。该技术对硬件兼容性有很高要求，需要参考 `Intel Virtual RAID on CPU (Intel VROC) Supported Configurations <https://www.intel.com/content/www/us/en/support/articles/000030310/memory-and-storage/ssd-software.html>`_ 选择 CPU处理器、操作系统 以及 SSD。

需要注意，Intel VROC (VMD NVMe RAID) 需要license来激活处理器提供对应功能。这个license SKU决定了能够使用对RAID级别以及RAID阵列可以管理的NVMe SSD设备。此外，要组建VROC RAID需要使用Intel NVMe SSD，其他第三方NVMe SSD只支持pass-through模式。(这招真狠，估计是跟苹果学的)

参考
=======

- `Frequently Asked Questions about Intel Virtual RAID on CPU (Intel VROC) <https://www.intel.com/content/www/us/en/support/articles/000024550/memory-and-storage.html>`_
- `Intel Virtual RAID on CPU (Intel VROC) Linux Software User Guide <https://www.intel.com/content/dam/support/us/en/documents/memory-and-storage/ssd-software/Linux_VROC_6-0_User_Guide.pdf>`_
