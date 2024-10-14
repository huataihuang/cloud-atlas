.. _pi_5_optane_ssd:

===============================
树莓派5存储Intel Optane(傲腾)
===============================

.. warning::

   我的测试方法有问题，没有实际测试出 Optane(傲腾)和常规NVMe :ref:`kioxia_exceria_g2` 的真实性能差异。不过，我没有精力继续测试，暂时先这样记录。以后有实际需求再搞。

对比随机写4k， :ref:`intel_optane_m10` (16G)和 :ref:`kioxia_exceria_g2` (2T) 没有什么太大区别:

- 傲腾 和 现在主流的 3D NAND SSD 在树莓派上使用 :strike:`性能几乎相同` 可能还是Optane(傲腾)性能更好：

  - 树莓派孱弱的NVMe 2.0接口限制了存储性能，这个瓶颈很容易就被NVMe接口的傲腾和3D NAND SSD跑满， :strike:`所以实际使用没有差异` 但是我的测试实际上存在问题: 我忘记 :ref:`kioxia_exceria_g2` 配备了1GB DDRAM 缓存，也就是说当测试写入数据没有超过1GB(写透)的话，实际上比较的是Optane(傲腾)和DDRAM的性能，所以我这里测试出来两者4k写性能几乎一致(但是读是4k随机读绕过缓存所以体现出两者的性能差异)
  - 4k写达到 920MB/s ~ 940MB/s 

- 傲腾 4k 读性能似乎是 3D NAND SSD 的 2倍多 (有可能是因为 :ref:`kioxia_exceria_g2` 安装在双NVMe槽上，分得的带宽只有一半 **等我后续搞成一样的双NVMe转接卡再测试一遍** )

  - 傲腾 4k 读 758MB/s
  - :ref:`kioxia_exceria_g2` 4k 读 366MB/s

- 傲腾 4k 随机读写的 CPU使用率 比常规 3D NAND SSD 低一些

fio 4k随机写
==================

.. literalinclude:: pi_5_optane_ssd/fio_4k_write
   :caption: ``fio`` 测试4k写性能

- :ref:`intel_optane_m10` (16G) ``4k随机写`` :

.. literalinclude:: pi_5_optane_ssd/intel_optane_m10_4k_write
   :caption: :ref:`intel_optane_m10` (16G) 4k 写fio测试
   :emphasize-lines: 32

- :ref:`kioxia_exceria_g2` (2T) ``4k随机写`` :

.. literalinclude:: pi_5_optane_ssd/kioxia_exceria_g2_write
   :caption: :ref:`kioxia_exceria_g2` (2T) 4k 写fio测试
   :emphasize-lines: 32

fio 4k随机读
===================- 

.. literalinclude:: pi_5_optane_ssd/fio_4k_read
   :caption: ``fio`` 测试4k读性能

- :ref:`intel_optane_m10` (16G) ``4k随机读`` :

.. literalinclude:: pi_5_optane_ssd/intel_optane_m10_4k_read
   :caption: :ref:`intel_optane_m10` (16G) 4k 读fio测试
   :emphasize-lines: 35

- :ref:`kioxia_exceria_g2` (2T) ``4k随机读`` :

.. literalinclude:: pi_5_optane_ssd/kioxia_exceria_g2_read
   :caption: :ref:`kioxia_exceria_g2` (2T) 4k 读fio测试
   :emphasize-lines: 35

参考
=========

- `如何在 Linux 中使用 Fio 来测评硬盘性能 <https://zhuanlan.zhihu.com/p/41802948>`_
