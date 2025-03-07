.. _intel_rst_arch:

===============================================
Intel Rapid Storage Technology(Intel RST)架构
===============================================

当使用Intel服务器 :ref:`xeon_e` 以及 :ref:`intel_c246` 会注意到规格列表中有一项 ``Intel® Rapid Storage Technology`` ，这也是 :ref:`intel_optane` 结合HDD的加速技术。那么，这项技术是否可以用于Linux，以及这个技术是否有使用价值?

.. note::

   我一直有这个疑问和好奇，这项Intel专用硬件的存储技术是否有可取之处，是否能够解决一直困扰我的 :ref:`speed_up_mdadm_rebuild_resyn` 读写延迟问题？

   我准备尝试构建实验环境来验证和测试这项技术，看看一年多前困扰我的生产问题是否能够优化解决

Intel RST概述
===============

.. warning::

   目前我整理和推测Intel RST技术，具体后续完善补充， **请勿直接采信**

(我的理解)Intel在 :ref:`intel_cpu` 和 Intel :ref:`server_chipset` 内置了 ``半硬件化`` 的RAID(加速)技术:

- RAID校验功能卸载到CPU/chipset的专用硬件进行计算，可以降低CPU的负载(?我的推测，待研究)
- 通过操作系统的软件管理(命令)可以组建和管理 Intel RST 的RAID模式以及维护监控

Intel RST主要面向 :ref:`windows` 平台，Intel仅为Linux平台提供了驱动(没有官方管理工具?):

- Intel RST是一项专用硬件技术，只有Intel CPU+Intel Chipset才能启用
- Intel RST对上层操作系统屏蔽了底层存储的特性，不利于操作系统直接控制和管理底层存储，必须依赖Intel专用软件来管理底层存储，所以在Linux内核似乎没有接收 https://lore.kernel.org/linux-pci/20190620061038.GA20564@lst.de/T/

  - 不支持NVMe设备电源管理
  - 不支持NVMe reset
  - 不支持基于PCI ID的NVMe特性
  - 不支持 :ref:`sr-iov` VF

- 如果不安装Intel RST Linux驱动，Linux将看不到已经用于Intel RST的存储设备(这应该是我购买的部分二手 :ref:`intel_optane_m10` 无法识别的原因，因为这些存储已经在Windows下使用过Intel RST): 可能可以参考 `Intel RST makes SSD disappear in Linux <https://superuser.com/questions/1655079/intel-rst-makes-ssd-disappear-in-linux>`_ 提供的方法修复(待验证)

  - `Ubuntu Help: Intel RST <https://help.ubuntu.com/rst/index.html>`_ ubuntu官方手册
  
- Linux内核开发好像拒绝了加入Intel RST支持(reddit)，所以在Linux上使用Intel RST可能比较麻烦
- Intel RST技术似乎发展停滞:

  - SDS(软件定义存储)快速发展的分布式存储目前是主要的数据中心存储技术
  - :ref:`nvme` 技术高速发展，用户倾向于直接在NVMe存储上存储数据
  - Intel已经放弃了 :ref:`intel_optane` 应该也影响了Intel RST发展

- 通常对于Linux安装是需要在BIOS中将Intel RST关闭(改为 AHCI)，但是这可能会导致同一台主机上安装的(已经使用Intel RST)Windows无法启动: 需要每次切换操作系统前先修改BIOS切换Intel RST模式(非常麻烦)

Intel RST Linux使用
===============================

.. note::

   Intel RST对硬件要求较低，早期的Intel七代处理器就可以支持使用；另一个类似技术 :ref:`intel_vroc` 则要求Intel Xeon Scalable Processors(针对NVMe SSD的企业级RAID技术)则更为专业(专注于NVMe RAID，不像 Intel RST是为了低端SATA存储混合 :ref:`intel_optane` 的消费级技术)，并且需要额外的硬件支持（如 VROC 密钥）和授权，成本较高。

概览:

- `Support for Intel® Rapid Storage Technology (Intel® RST) <https://www.intel.com/content/www/us/en/support/products/55005/technologies/intel-rapid-storage-technology-intel-rst.html>`_ Intel RST官方知识库
- `Product Overview for Intel® Rapid Storage Technology <https://www.intel.com/content/www/us/en/support/articles/000005610/technologies.html>`_
- `Defining RAID Volumes for Intel® Rapid Storage Technology <https://www.intel.com/content/www/us/en/support/articles/000005867/technologies.html>`_

Intel 2011年的手册:

- `Intel Rapid Storage Technology (Intel RST) in Linux <https://www.intel.com/content/dam/www/public/us/en/documents/white-papers/rst-linux-paper.pdf>`_
- `Intel Rapid Storage Technology User Guide <https://www.intel.com/content/www/us/en/content-details/841982/intel-rapid-storage-technology-user-guide.html>`_

参考
======

- `Is there any Linux distros that can use Intel RST? <https://www.reddit.com/r/linuxquestions/comments/no4m0f/is_there_any_linux_distros_that_can_use_intel_rst/>`_
- `How can I get around Intel RST thingy while trying to install Ubuntu? <https://askubuntu.com/questions/1369660/how-can-i-get-around-intel-rst-thingy-while-trying-to-install-ubuntu>`_
