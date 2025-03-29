.. _intel_optane_m10:

====================================
Intel Optane(傲腾) M10
====================================

.. _intel_optane:

Intel Optane(傲腾)
====================

Intel Optane(傲腾)是Intel公司推出的介于DRAM和常规3D-NAND SSD之间的特殊存储，具有非易失性的持久化存储特性，同时又兼具RAM的(接近)性能，最夸张的是具有较NAND Flash有1000倍的耐用性。

但是，由于特殊的PCM(相变化存储器)原理，无法像3D-NAND一样堆叠扩展容量，导致生产大容量成本极高。始终无法在消费市场拓展，且技术迭代进展缓慢，Intel已经放弃Optane(傲腾)技术线路。

.. note::

   我之所以关注Intel Optane(傲腾)，是因为在淘宝上，有非常廉价的小规格傲腾m.2存储: 16GB(实际是13.4G)仅需要13块RMB。如此低廉的价格，加上Intel Optane(傲腾)的超高性能和耐用度，使得我这样的电子垃圾佬不由不心动，想要尝试一下(虽然也有很多信息显示这款存储兼容性和可用度非常狭小)。

Intel Optane 的使用方法比较奇特:

- 如果是新的Optane，那么开箱即用，表现为一个16G的SSD存储一样

- 但是实际上Intel在OEM市场推广Optane是结合传统的HDD(磁盘)来使用的:

  - 使用Intel的Optane软件工具将Optane和一个HDD配对以后，对系统而言就看不到独立的Optane设备，只看到一块磁盘
  - 配对以后的Optane将无法独立使用，除非再次使用Optane软件工具unpair(我怀疑买到的一些Optane无法识别就是已经pair过的拆机存储，需要unpair才能使用)
  - Intel Optane技术非常类似 :ref:`linux_bcache` ，但是驱动限定为Windows平台

- 对于已经pair的Optane，如果安装到USB硬盘盒表现为一个U盘，可能还是可以使用的

- Optane不是内存(RAM)，也无法作为内存使用(来扩展内存容量)，它就是一个存储设备

  - 对于Linux系统，为了充分利用Optane的高速和耐用性，可以尝试 :ref:`swap_on_optane` 来部分解决系统内存不足(例如，我将购买的Optane M10作为 :ref:`pi_5` 的swap设备)

.. _optane_on_pi:

在树莓派上使用Optane(傲腾)
=============================

我购买Intel Optane(傲腾) M10的一个目标就是为 :ref:`pi_5` :ref:`swap_on_optane` :

- :ref:`pi_5` 的内存太小(8G)，运行大型程序捉胫见肘，通过增加swap来变相提升内存容量
- Intel Optane(傲腾)极高的随机读写性能以及变态超长的使用寿命，非常适合密集型随机读写
- 淘宝上售卖的16G规格Intel Optane(傲腾)价格低廉，只需要12RMB

使用小结
==========

理想很丰满，但是现实是 "折腾" :

在 :ref:`pi_5` 上，通过 :ref:`pi_5_pcie_m.2_ssd` 是可以是可以识别出 M10 并作为NVMe存储来使用的，但是有很多限制(我的验证):

- 刚购买的Optane盘，似乎需要先通过USB移动硬盘盒(此时会识别为 ``RTL9210 NVME`` )连接到主机上，先做一次磁盘分区和格式化。这样似乎就激活了磁盘属性，就能够放到 :ref:`pi_5` 的 PCIe 转 m.2 NVMe 扩展卡上识别为 ``nvme0n1``

.. literalinclude:: intel_optane_m10/fdisk_optane_before
   :caption: 在Intel Optane M10没有创建分区之前的状态

.. literalinclude:: intel_optane_m10/fdisk_optane
   :caption: 通过 ``fdisk`` 查看到的两个NVMe设备，一个是Intel OPtane M10,另一个是 :ref:`kioxia_exceria_g2` (2T)
   :emphasize-lines: 1,2,10

- 当把 Intel Optane M10 放到USB硬盘转接盒中，则会识别为 ``/dev/sdb`` 设备，两种规格都可以正常使用，就好像一个U盘

- 非常奇怪的经验:

  - **单NVMe转接卡** 较适合安装Intel Optane(傲腾) M10，根据我的实测经验和树莓派论坛帖子综合，Optane(傲腾)可能不能作为常规启动NVMe，但是启动后将其作为数据存储盘使用没有问题
  - ``2042`` 规格的 **短** Intel Optane M10 可以在 **双NVMe转接卡** 上使用(内置 :ref:`pcie_bifurcation` )
  - 但是 ``2080``  规格 **长** Intel Optane M10 在 **双NVMe转接卡** 上不能识别，似乎；但是同样这个 ``2080`` 规格，在 ``单NVMe转接卡`` 上却能正常识别是使用
  - 识别不稳定:

    - 我一共购买了4快 ``2042`` 规格的 **短** Intel Optane M10，其中有2快能够在 **双NVMe转接卡** 上使用，另外2快始终不能识别
    - 能够识别使用的 ``2042`` 规格Intel Optane M10也存在问题: 启动树莓派的时候，有时候能识别，有时候又完全看不到该 :ref:`nvme` 设备( ``lspci`` 也看不到)

      - 如果启动 :ref:`pi_5` 时能够 **幸运** 识别出Optane，则 ``lspci`` 可以看到 ``0000:04:00.0 Non-Volatile memory controller: Intel Corporation NVMe Optane Memory Series`` ，之后使用就非常稳定，性能极佳
      - 在淘宝上看到 **双NVMe转接卡** 说明中提到(虽然不同品牌但是实际使用的都是 ``ASM1182e`` PCIe Switch芯片实现 :ref:`pcie_bifurcation` ): 

        - :ref:`pi_5` 的PCIe只有 ``1X`` ，而且经过扩展后只支持Gen 2模式，所以功耗会降低至额定参数的1/3。
        - 如果SSD上标记 3.3V 2.5A，实际从5V侧测量峰值也仅仅500mA多，两个SSD则峰值电流为 0.75A

      - 由于上述淘宝的产品说明，我推测是因为 **双NVMe转接卡** 比 **单NVMe转接卡** 电流更低，导致无法满足 Intel Optane(傲腾) 正常工作(在树莓派论坛上用户提到Optane虽然不能用作启动盘但是从SD卡启动后就可以正常使用，很可能他们使用的都是 ``单`` NVMe转接卡)

    - 我想到 :ref:`pi_5_overclock` 会配置较高一些的电压以便能够提供更高的功率支持，或许也能同时解决 Intel Optane(傲腾) 识别的问题 -- 实践经验如下:

      - 实施 :ref:`pi_5_overclock` 之后，虽然没有百分百解决 :ref:`pi_5` 启动识别Optane的问题，但是我观察明显好转，大多数情况下启动时能够识别Optane
      - 只要识别了 Optane ，则启动后使用就没有任何问题，性能极佳
      - 如果偶然没有正确识别Optane，则关机以后，过一会再开机基本上都识别

我还没有在Intel架构的服务器上测试，可能测试情况会和 :ref:`arm` 架构不同:

- Intel官方资料是说Optane(傲腾)只支持X86环境和Windows，不过我估计那是因为商业策略导致Intel只开发X86平台Windows的存储加速技术(因为傲腾就是Intel用于存储加速的技术线路)，实际上作为通用的NVMe接口存储，可能是 :ref:`arm` 架构也支持的(至少我验证能够正常作为NVMe SSD存储使用
- :strike:`我怀疑是Intel做了技术限制(非常"愚蠢"的技术线路)，强制每个HDD存储只能使用一块Optane(傲腾)存储进行加速，我怀疑是这个原因导致无法将2块Optane连接到一个PCIe接口上。目前测试这个限制打消了我使用多块M10构建一个简单存储(实验环境)的念头；也使得我想用M10为树莓派的NVMe存储加速的愿望破灭`

参考
======

- `What Is Intel Optane Memory? <https://www.howtogeek.com/317294/what-is-intel-optane-memory/>`_
- `Intel Optane Memory Module - Frequently Asked Questions <https://www.dell.com/support/kbdoc/en-us/000175253/optane-memory-module-frequently-asked-questions>`_
- `英特尔傲腾内存M10 <https://www.intel.cn/content/www/cn/zh/products/details/memory-storage/optane-memory/optane-memory-m10-series.html>`_
- `Intel (傲腾) Optane 工作原理 <https://zhuanlan.zhihu.com/p/347543437>`_
- `How do I use intel optane memory as ram?  <https://www.reddit.com/r/buildapc/comments/ab17fg/how_do_i_use_intel_optane_memory_as_ram/>`_
