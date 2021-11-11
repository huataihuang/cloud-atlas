.. _samsung_pm9a1:

======================
三星PM9A1 NVMe存储
======================

三星PM9A1 NVMe存储是三星发布的PCIe Gen4 NVMe存储，是目前能够买到的性能最强(也许也是性价比最高的)消费级NVMe存储。

这款NVMe SSD是三星为笔记本厂商提供的OEM产品，使用了三星 Elpis (S4LV003) 控制器，具备8通道以及512MB LPDDR4 RAM。PM9A1 NVMe存储模块使用了三星的3D-NAND TLC 128层加工工艺

技术参数
========

.. csv-table:: 三星PM9A1 NVMe存储技术规格
   :file: samsung_pm9a1/pm9a1_spec.csv
   :widths: 25, 75
   :header-rows: 1

在 `speednetz HDD Benchmarks <https://speednetz.com/hdd-benchmarks>`_ 可以看到 ``NVMe PM9A1 Samsung 1TB`` 得分位列第22 (汗，这个评测不知道是根据什么firmware版本以及测试方式)

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
