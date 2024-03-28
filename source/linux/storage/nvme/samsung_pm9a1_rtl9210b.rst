.. _samsung_pm9a1_rtl9210b:

======================================
三星PM9A1 通过RTL9210B NVMe转USB
======================================

**这是一个曲折的过程，我不确定能否解决，逐步记录**

我在 :ref:`edge_cloud_infra` 采用 :ref:`raspberry_pi` 组件集群，想采用我之前购买的 :ref:`samsung_pm9a1` 来作为USB外接存储，以解决默认TF卡读写缓慢问题，同时扩大存储空间。

我在淘宝上搜索找到了 ``JEYI佳翼领航员M.2移动硬盘盒U盘直插式`` ：

- 无需外接USB线，看起来比较整齐和美观 (之前我使用过西部数据的SSD移动硬盘，但是通过USB软连接线连接总觉得不美观)
- 支持NVMe和SATA双协议

主控芯片是RTL9210B

RTL9210B兼容性问题
=====================

我遇到一个异常问题，当 :ref:`samsung_pm9a1` 安装到 ``佳翼M.2硬盘盒`` 中，插入到电脑上，没有任何反应。虽然U盘的电源指示灯是亮起(绿色)，但是操作系统日志没有显示检测到任何USB设备。同时使用 ``fdisk -l`` 也看不到新增磁盘。

这个问题可能是 ``三星PM9A1`` 兼容问题:

- 我替换测试了其他 ``三星PM9A1`` ，也都无法检测到USB磁盘，就好像设备根本不存在一样
- 但是使用了古旧的 ``三星PM871A`` (SATA接口，非NVMe)是能够识别和正常使用的

SMART
--------

`Nvme to usb using Realtek RTL9210B and SMART status issue <https://forum.virtualmin.com/t/nvme-to-usb-using-realtek-rtl9210b-and-smart-status-issue/115527>`_ 提到了 Realtek RTL9210B 的NVMe存储SMART支持问题，其中一些检测命令可以借鉴使用

- SMART检测:

.. literalinclude:: samsung_pm9a1_rtl9210b/smartctl_test
   :caption: 检测SMART

输出显示

.. literalinclude:: samsung_pm9a1_rtl9210b/smartctl_test_output
   :caption: 检测SMART输出信息
   :emphasize-lines: 4,5

- 然后尝试检测SMART，发现报错，显示不支持SCSI指令

.. literalinclude:: samsung_pm9a1_rtl9210b/smartctl_sntrealtek
   :caption: 检查sntrealtek

输出报错

.. literalinclude:: samsung_pm9a1_rtl9210b/smartctl_sntrealtek_output
   :caption: 检查sntrealtek报错
   :emphasize-lines: 4

RTL9210B-CG 资料分析
=====================

根据 `REALTEK官网资料: RTL9210B-CG <https://www.realtek.com/en/products/connected-media-ics/item/rtl9210b-cg>`_ 可以看到:

- Realtek RTL9210B-CG 是USB桥接器，将USB设备与PCIe控制器和SATA控制器相结合
- 通过M.2机械的PEDET接口，RTL9210B-CG可以自动切换USB-to-PCIe模式或USB-to-SATA模式
- RTL9210B-CG 支持 USB 3.1 GEN2（超高速），兼容  USB 3.1 GEN1（超高速）、USB 高速和全速
- 海量存储事务支持仅批量传输 (BOT) 和 USB 连接 SCSI 协议 (UASP)
- 对于USB，提供高达10Gbps 的带宽
- **USB 转 PCIe 模式下，RTL9210B-CG 支持 PCIe Gen3 x2** 提供高达 16Gbps 的带宽 ; 向后兼容 PCIe Gen2/Gen1
- 为了进一步降低功耗，RTL9210B-CG 支持链路电源管理（PCIe L1.Off 和 L1.Snooze）、PCI MSI（消息信号中断）和 MSI-X
- USB 转 SATA 模式下，RTL9210B-CG 支持 Gen3 速度的 SATA 主机 ;  6Gbps 的带宽，向后兼容 SATA Gen2/Gen1

.. note::

   由于官方资料仅显示 RTL9210B-CG 支持 PCIe 3 ，而 三星 PM9A1 是一款 PCIe 4接口 NMVe ，所以推测可能存在不兼容问题

参考
==========

- `Nvme to usb using Realtek RTL9210B and SMART status issue <https://forum.virtualmin.com/t/nvme-to-usb-using-realtek-rtl9210b-and-smart-status-issue/115527>`_
- `Does a PCIe SSD need a different driver if it is moved from an internal slot to an external enclosure and connected via usb? <https://superuser.com/questions/1754326/does-a-pcie-ssd-need-a-different-driver-if-it-is-moved-from-an-internal-slot-to>`_
- `REALTEK官网资料: RTL9210B-CG <https://www.realtek.com/en/products/connected-media-ics/item/rtl9210b-cg>`_
