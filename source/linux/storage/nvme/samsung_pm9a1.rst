.. _samsung_pm9a1:

======================
三星PM9A1 NVMe存储
======================

.. note::

   如果经费宽裕，建议购买 ``三星PM9A3`` (企业级)，使用寿命更长:
   
   - 可靠性预测 2 Mio. Hours (比PM9A1提高了33%)
   - 使用寿命 1.3 DWPD for 3 years (确实，现在V-NAND TLC存储即使是三星企业级也无法做到以前MLC的超长使用寿命)，比消费级PM9A1提高了 62.5%
   
   在2021年底，三星 PM9A3 售价1000，三星 PM9A1 售价 800 ，价格提高了 25% ，但是从使用寿命来看 PM9A1 只有 0.8 DWPD ，而 PM9A3 则提高到 1.3 DWPD，使用寿命提高了 62.5% ，确实性价比更高。

三星PM9A1 NVMe存储是三星发布的PCIe Gen4 NVMe存储，是目前能够买到的性能最强(也许也是性价比最高的)消费级NVMe存储。

这款NVMe SSD是三星为笔记本厂商提供的OEM产品，使用了三星 Elpis (S4LV003) 控制器(8nm制程工艺)，具备8通道以及512MB LPDDR4 RAM。PM9A1 NVMe存储模块使用了三星的3D-NAND TLC 128层加工工艺

技术参数
========

.. csv-table:: 三星PM9A1 NVMe存储技术规格
   :file: samsung_pm9a1/pm9a1_spec.csv
   :widths: 25, 75
   :header-rows: 1

在 `speednetz HDD Benchmarks <https://speednetz.com/hdd-benchmarks>`_ 可以看到 ``NVMe PM9A1 Samsung 1TB`` 得分位列第22 (汗，这个评测不知道是根据什么firmware版本以及测试方式)

在上述技术规格中值得关注的有：

- ``TBW`` : 写入容量(TB Write)，也就是SSD保修期内最大数据写入总量，超出即为过保。可以看到 Samsung PM9A1 SSD 保修范围总计写入300TB数据。需要注意，这个是厂商的保修承诺，并不是达到600TB写入量存储就会损坏。另外一个对应的寿命参数是 ``P/E`` , ``P/E = TBW / 存储容量`` ，对于我购买的 1TB 规格 ``PM9A1`` ， ``P/E = 600TBW / 1TB`` 数值就是 ``600`` 。这个数值实际上就是SSD存储行业的消费级TLC颗粒SSD的主流寿命相符，其他品牌差不多也是这个水平。(也是，实际上生产SSD颗粒也就是三星、Micron有限的几家厂商)
- ``MTBF`` : 即 ``Mean Time betwween Failures`` 平均故障间隔时间，即产品在总的使用阶段累计工作时间与故障次数的比值。MTBF反映了产品的时间质量，产品故障越少，MTBF越高，产品可靠性也越高。Samsung PM9A1 NVMe 1TB 标称MTBF是 1.5 百万小时，业界的企业级MTBF通常是 2 百万小时。不过这个数值是基于一定样本量、一定时间段（通过加速因子加速）进行统计推断，模拟典型用户场景，通过实测验证理论值，代表用户提前验收产品质量。看看就好...

.. note::

   在企业级固态硬盘市场有一个寿命描述方法 ``DWPD`` 也就是 ``Drive Writes Per Day`` ，即 ``每日全盘写入次数`` 。例如Intel企业级P4500， DWPD是4.62，也就是按照5年保修期，用户每天可以把硬盘写满4.62遍，可以满足服务器这种需要大量数据写入的应用场景。

- ``IOPS 4K read/Write`` : 4K读写IOPS 是SSD的重要性能指标，三星的NVMe SSD的性能指标极高。可以使用 :ref:`fio` 测试，不过这个测试非常磨损，我只能做简单测试，毕竟舍不得...

检查
======

:ref:`nvme-cli` 提供了检查NVMe的功能

- 检查控制器::

   sudo nvme id-ctrl /dev/nvme0n1

可以看到输出::

   ...
   sn        : S676NF0R908202      
   mn        : SAMSUNG MZVL21T0HCLR-00B00
   fr        : GXA7401Q
   ...
   subnqn    : nqn.1994-11.com.samsung:nvme:PM9A1:M.2:S676NF0R908202
   ...

- 也可以直接列出设备::

   sudo nvme list

.. literalinclude:: nvme-cli/nvme_list.txt
   :language: bash
   :linenos:
   :caption: nvme list 输出

可以看到我购买的NVMe存储是三星 ``PM9A1`` m.2 接口，firmware版本是 ``GXA7401Q`` ，型号是 ``SAMSUNG MZVL21T0HCLR-00B00``

参考
=======

- `三星官网 PM9A1 介绍 <https://www.samsung.com/semiconductor/cn/ssd/pm9a1/>`_
- `三星PM9A1 2T单品测评 <https://www.163.com/dy/article/GMI18U5H0512MJDN.html>`_
- `PCI-E4.0时代的极致性价比——三星PM9A1固态硬盘体验评测 <https://zhuanlan.zhihu.com/p/362831626>`_
- `三星980 PRO 1TB M.2 SSD评测 现最强PCI-E 4.0 SSD <https://www.expreview.com/76235.html>`_ 企业级TLC，规格和性能作为参考
- `满血PCIe 4.0：三星980PRO固态硬盘评测 <http://bbs.pceva.com.cn/thread-148177-1-1.html>`_ 详尽的技术说明，作为参考
- `Samsung OEM Client SSD PM9A1 1TB, M.2 (MZVL21T0HCLR-00B00) <https://skinflint.co.uk/samsung-oem-client-ssd-pm9a1-1tb-mzvl21t0hclr-00b00-a2454424.html>`_
- `SSD固态硬盘选购指标-寿命：P/E、TBW 、DWPD <https://www.jianshu.com/p/ce9edc670de7>`_
- `SSD 可靠性指标 MTTF、MTBF、AFR 解析 <https://xie.infoq.cn/article/5b1b691e4dd01901c0ec1886d>`_
