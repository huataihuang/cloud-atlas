.. _intel_optane_m10:

====================================
Intel Optane(傲腾) M10
====================================

Intel Optane(傲腾)是Intel公司推出的介于DRAM和常规3D-NAND SSD之间的特殊存储，具有非易失性的持久化存储特性，同时又兼具RAMD的(接近)性能，最夸张的是具有较NAND Flahs有1000倍的耐用性。

但是，由于特殊的PCM(相变化存储器)原理，无法像3D-NAND一样堆叠扩展容量，导致生产大容量成本极高。始终无法在消费市场拓展，且技术迭代进展缓慢，Intel已经放弃Optane(傲腾)技术线路。

.. note::

   以上论述综合往上资料，不一定准确，后续不断完善

我之所以关注Intel Optane(傲腾)，是因为在淘宝上，有非常廉价的小规格傲腾m.2存储: 16GB(实际是13.4G)仅需要13块RMB。如此低廉的价格，加上Intel Optane(傲腾)的超高性能和耐用度，使得我这样的电子垃圾佬不由不心动，想要尝试一下(虽然也有很多信息显示这款存储兼容性和可用度非常狭小)。

使用小结
==========


在 :ref:`pi_5` 上，通过 :ref:`pi_5_pcie_m.2_ssd` 是可以是可以识别出 M10 并作为NVMe存储来使用的，但是有很多限制(我的验证):

- 刚购买的Optane盘，似乎需要先通过USB移动硬盘盒(此时会识别为 ``RTL9210 NVME`` )连接到主机上，先做一次磁盘分区和格式化。这样似乎就激活了磁盘属性，就能够放到 :ref:`pi_5` 的 PCIe 转 m.2 NVMe 扩展卡上识别为 ``nvme0n1``

.. literalinclude:: intel_optane_m10/fdisk_optane_before
   :caption: 在Intel Optane M10没有创建分区之前的状态

.. literalinclude:: intel_optane_m10/fdisk_optane
   :caption: 通过 ``fdisk`` 查看到的两个NVMe设备，一个是Intel OPtane M10,另一个是 :ref:`kioxia_exceria_g2` (2T)
   :emphasize-lines: 1,2,10

- 当把 Intel Optane M10 放到USB硬盘转接盒中，则会识别为 ``/dev/sdb`` 设备，两种规格都可以正常使用，就好像一个U盘

- 非常奇怪的经验:

  - ``2042`` 规格的 **短** Intel Optane M10 可以在 **双NVMe转接卡** 上使用(内置 :ref:`pcie_bifurcation` )
  - 但是 ``2080``  规格 **长** Intel Optane M10 在 **双NVMe转接卡** 上不能识别，似乎；但是同样这个 ``2080`` 规格，在 ``单NVMe转接卡`` 上却能正常识别是使用
  - 看起来似乎同样的 Optane M10却又不同的特性，似乎是什么开关没有激活导致，待后续探索

- **错误经验** :strike:`只能单通道(单块NVMe)存储使用，不能使用双NVMe转接卡，也就是不支持` :ref:`pcie_bifurcation`
- **错误经验** :strike:`在双NVMe转接卡上，不管安装在哪个插槽(slot 0 或 slot 1)都无法识别，只有安装回单块NVMe转接卡才能识别`

我还没有在Intel架构的服务器上测试，可能测试情况会和 :ref:`arm` 架构不同:

- Intel官方资料是说Optane(傲腾)只支持X86环境和Windows，不过我估计那是因为商业策略导致Intel只开发X86平台Windows的存储加速技术(因为傲腾就是Intel用于存储加速的技术线路)，实际上作为通用的NVMe接口存储，可能是 :ref:`arm` 架构也支持的(至少我验证能够正常作为NVMe SSD存储使用
- :strike:`我怀疑是Intel做了技术限制(非常"愚蠢"的技术线路)，强制每个HDD存储只能使用一块Optane(傲腾)存储进行加速，我怀疑是这个原因导致无法将2块Optane连接到一个PCIe接口上。目前测试这个限制打消了我使用多块M10构建一个简单存储(实验环境)的念头；也使得我想用M10为树莓派的NVMe存储加速的愿望破灭`

如果一个通道只能使用一块Optane(傲腾)进行加速，则大大限制了使用场景。希望我后续还能突破这个限制，能够真正发挥好这块存储的性能。 

参考
======

- `What Is Intel Optane Memory? <https://www.howtogeek.com/317294/what-is-intel-optane-memory/>`_
- `英特尔傲腾内存M10 <https://www.intel.cn/content/www/cn/zh/products/details/memory-storage/optane-memory/optane-memory-m10-series.html>`_
- `Intel (傲腾) Optane 工作原理 <https://zhuanlan.zhihu.com/p/347543437>`_
