.. _pcie_bifurcation:

=========================
PCIe bifurcation选项
=========================

:ref:`hpe_dl360_gen9` 支持PCIe直接使用NVMe存储，这样可以在服务器上实现高性能存储集群。(原厂的 U.2 接口NVMe SSD存储升级套件实在成本太高)

在淘宝上可以购买到 PCIe X16 四盘NVMe扩展卡:

.. figure:: ../../../../_static/linux/server/hardware/hpe/pcie_nvme_extendcard.png

.. figure:: ../../../../_static/linux/server/hardware/hpe/pcie_nvme_extendcard-1.png
   :scale: 60

.. figure:: ../../../../_static/linux/server/hardware/hpe/pcie_nvme_extendcard-2.png
   :scale: 50

PCIe bifurcation
====================

需要注意，扩展卡是 PCIe x16 规格的，为了能够支持4个NVMe m.2 存储，需要将这个 X16 分成4个 X4 才能支持4个NVMe盘。需要主板支持一种称为 ``PCIe bifurcation`` 技术，这样在主板BIOS中可以将 PCIe X16 改成 ``x4x4x4x4`` 

.. figure:: ../../../../_static/linux/server/hardware/hpe/pcie_bifurcation-1.png
   :scale: 50

参考HP官方文档，DL360 gen10 是支持 PCIe Bifurcation 的:

``System Configuration > BIOS/Platform Configuration (RBSU) > PCIe Device Configuration > PCIe Bifurcation Options``

对于 :ref:`hpe_dl360_gen9` 我尝试完成 :ref:`dl360_bios_upgrade` 再做BIOS配置验证

.. note::

   目前尚未实践，等完成 :ref:`dl360_bios_upgrade` 之后看能否实现分成4个X4，如果只支持对半分，则购买2块双盘NVMe扩展卡，安装到 PCIe 3.0 Slot 1 和 Slot 2上，也能实现相同效果 - 因为HP DL360的Slot 1和Slot 2都连接在CPU 1上，和在一个Slot 1上切分4个X4一样。

PCIe设备和bifuration
=======================

参考 `HPE Proliant dl160 gen9 bifurcation <https://community.hpe.com/t5/Servers-General/HPE-Proliant-dl160-gen9-bifurcation/td-p/7133232#.YXdM-y8RppQ>`_ 提到:

- 有人提出 DL360和DL380更新到最新的Bios 2.90也没有出现 ``pcie options`` 选项，不过， ``dual bifuration`` 支持是从 2016 年开始的，在 `HPE UEFI System Utilities and Shell Release Notes for HPE ProLiant Gen9 Servers <https://support.hpe.com/hpesc/public/docDisplay?docLocale=en_US&docId=c05060771>`_ 文档第5页(2016年文档)有说明::

   Addedsupportto configurethe systemto bifurcatePCIe Slot 1 on the DL360Gen9 or PCIeSlot 2 on the DL380Gen9

也就是说对于 DL360 Gen9 是支持Slot 1的 ``PCIe bifurcation`` ，对于 DL380 Gen9 则支持 Slot 2的 ``PCIe bitfurcaton``

- HP的人说DL360和DL380 Gen9是支持，但是需要PCIe扩展卡厂商的部件适配bifurcate，部件需要和firmware和驱动适配正确的速率才能实现 x8 / x4 。所以，这可能是没有插入PCIe扩展卡就看不到 ``PCIe Device Configuratio`` 选项的原因？

参考 `HPE Gen9 with asus hyper m.2 x16 card v2 <https://linustechtips.com/topic/1279595-hpe-gen9-with-asus-hyper-m2-x16-card-v2/>`_ 提到有人购买了 Asus hyper m.2 x16 card v2 以及 4块 Samsung 970 plus:

- ``PCIe bifurcation`` 需要CPU和主板同时支持，Intel E5 v3处理器支持 ``40个`` PCIe 路径(lanes)

参考 `Setting Gpu Configurations; Selecting Pcie Bifurcation Options; Configuring Specific Pcie Devices - HPE ProLiant Gen10 User Manual <https://www.manualslib.com/manual/1391841/Hpe-Proliant-Gen10.html?page=120>`_ 说明了对于GPU设备::

   System Configuration > BIOS/Platform Configuration(RBSU) > PCIe Device Configuration > GPU CFG

有2个选项::

   4:1—Maps 4 PCIe slots to each installed processor
   8:1—Maps all slots to a single processor

综合
--------

- ``PCIe bifurcation`` 需要PCIe设备和主板firmware/driver配合进行协商，所以如果系统没有安装PCIe设备(GPU或NVMe卡)则看不到 ``PCIe Device Configuration`` 配置选项
- HPE gen9服务器更新到最新的BIOS是支持 ``PCIe bifurcation`` 的，但是有可能需要扩展卡能够适配才能正确设置，但是没有看到 ``PCIe Device Configuration`` 配置入口:



我的实践
============

我购买了 3个 :ref:`samsung_pm9a1` 以及 佳翼M2X16四盘NVMe扩展卡( 宣传称 ``支持PCIE 4.0 GEN4， 向下兼容PCIE3.0 GEN3`` )。我比较担心能否配合DL 360 Gen9实现 ``PCIe bifurcation`` 

- 我最初尝试将 NVMe扩展卡 安装在 Slot 3上(因为我想能在 Slot 1上安装显卡，然后可以还留出空间在Slot 2上安装第二个NVMe扩展卡)，但是确实启动以后没有找到PCIe配置选项

- 将 NVMe 扩展卡 改到安装到 Slot 1，重新启动系统，检查 ``BIOS/Platform Configuration(RBSU)`` 配置选项，依然没有看到 ``PCIe Device Configuration`` 配置入口(只看到 ``PCI Device Enable/Disable`` 激活关闭设置):

.. figure:: ../../../../_static/linux/server/hardware/hpe/rbsu_no_pcie_config.png
   :scale: 80

`HPE Proliant dl160 gen9 bifurcation <https://community.hpe.com/t5/Servers-General/HPE-Proliant-dl160-gen9-bifurcation/td-p/7133232#.YXdM-y8RppQ>`_ 中答复中也提到了，这个功能需要扩展卡厂商支持firmware，有人换了6个扩展卡都没有看到BIOS能够显示出 ``PCIe Device Configuration`` 配置项。看起来我购买的 ``佳翼M2X16四盘NVMe扩展卡`` 也同样没有适配成功。

目前能够找到的确定支持HP DL360 Gen9的NVMe扩展卡是使用PLX主控芯片( PLX 是PCIe交换和桥接芯片供应商 )，在淘宝上能够找到不需要主板自带PCIe bifurcation就可以使用多块NVMe存储的扩展卡都是使用PLX主控芯片。

真是让人非常沮丧，折腾这么久，查询很多资料都没有明确的 HPE Gen9 解决 PCIe bifurction 的解释和适配方法，虽然2016年 `HPE UEFI System Utilities and Shell Release Notes for HPE ProLiant Gen9 Servers <https://support.hpe.com/hpesc/public/docDisplay?docLocale=en_US&docId=c05060771>`_ 提到了支持，但是该文档最新2021年版本已经找不到这项说明了。

最终，我还是重新购买了 ``M.2 NVMe SSD扩展卡 PCIe3.0 X8X16扩2口4口M2 PLX8747`` ，需要注意，接口应该是 PCIe3.0 X16 ，这样拆分4个以后才是 x4x4x4x4 ，可以满足较高速的 NVMe 读写。
