.. _hackintosh_wifi_bluetooth:

=============================
黑苹果无线和蓝牙
=============================

.. warning::

   由于我的台式机和 :ref:`dell_t5820` 的 PCIe 接口非常宝贵，全部用于 :ref:`machine_learning` GPU 和万兆网卡，所以当前我暂时还没有实践。

   不过，我对这个方案很感兴趣，考虑到后续 :ref:`dell_t5820` 可以把主板上的 2个 SFF-8654 接口 (PEIe0/PCIe1)转接PCIe插槽，如果没有足够的存储或GPU来填满这个接口，可以考虑购买一块 **BCM94360CD千兆双频5G台式机无线网卡蓝牙**

.. figure:: ../../_static/apple/hackintosh/bcm94360cd.png

   BCM94360CD千兆双频5G台式机无线网卡蓝牙4

我最初想在 :ref:`c246_mi50_hackintosh` 复用我为Linux购买的 :ref:`mediatek_mt7921au` ，但是发现macOS 原生仅支持 Broadcom（博通）部分芯片以及苹果自家的无线网卡。对于 MediaTek（联发科）、Realtek（瑞昱）以及大多数 Intel 网卡，macOS 内部完全没有内置驱动。

gemini推荐的方法 **使用 Broadcom（博通）拆机卡 + PCIe 转接卡** : 这两款网卡都是非常成熟的"原生白苹果拆机卡" ，主要核心差异在于 **天线通道数量、速率、天线接口规范 以及 PCIe 转接卡的物理尺寸**

.. csv-table:: BCM94360CD vs BCM943602CS 核心对比
   :file: hackintosh_wifi_bluetooth/bcm.csv
   :widths: 20,40,40
   :header-rows: 1

- 天线与蓝牙独立性（BCM94360CD 占优）

  - **BCM94360CD** : 具备 4 个独立的 IPEX 接口，其中 3 根给 5GHz/2.4GHz Wi-Fi 数据传输，第 4 根专门作为蓝牙天线。这种设计使得在连接大量蓝牙设备（如蓝牙键盘、鼠标、AirPods、手柄）同时传输大文件时，蓝牙与 Wi-Fi 之间几乎零干扰。
  - **BCM943602CS** : 只有 3 个接口，蓝牙是与 Wi-Fi 天线共用的。在某些高负载 2.4GHz Wi-Fi 环境下，可能对蓝牙音质或鼠标延迟有极其微小的干扰。

- 蓝牙版本细节

  - BCM94360CD 原厂标配蓝牙 4.0
  - BCM943602CS 采用了稍新的芯片，支持 蓝牙 4.1/4.2（在对低功耗蓝牙 BLE 设备和 AirPods 的连接稳定度上稍微好一点点，但体感差异不大）

我的选择: ``BCM94360CD（4 天线版）`` - 常年挂载多个蓝牙音频/外设，且不在意机箱内部空间和额外的 1 根天线，它的独立蓝牙天线设计在多设备并发时最稳固

OpenCore设置
===============

在 OS X 10.9 Mavericks 到 macOS 13 Ventura 期间， ``BCM94360CD`` 是苹果官方的原生白名单免驱网卡，它的 Wi-Fi 和蓝牙驱动本来就内置在 macOS 的 Kext 库中。

但在 **macOS 14 Sonoma 及更新的系统（包括 macOS 26 Tahoe）** 中，苹果彻底废弃了古老的 PCIe Wi-Fi 驱动架构（IO80211Family）。因此，要想在全新的 macOS 上继续驱动这块网卡，必须通过 **OpenCore Legacy Patcher (OCLP) 的 Root Patches 机制** ，配合特定的 Kexts 将旧版驱动补丁"注入"回系统内核中。

驱动 BCM94360CD 的蓝牙与 Wi-Fi 镜像需要以下 Kext 驱动:

- ``Lilu`` 已经在 :ref:`c246_mi50_hackintosh` 完成
- `BlueToolFixup <https://github.com/acidanthera/BrcmPatchRAM/releases>`_ 包含在 `BrcmPatchRAM <https://github.com/acidanthera/BrcmPatchRAM/releases>`_ 里面，这个补丁是为了在macOS 12+蓝牙堆栈打补丁来支持第三方卡
- `AirportBrcmFixup <https://github.com/acidanthera/AirportBrcmFixup/releases>`_ 用于non-Apple/non-Fenvi的Broadcom网卡，对于OS X 10.10及更新版本都需要
－ `BrcmPatchRAM <https://github.com/acidanthera/BrcmPatchRAM/releases>`_ 用于更新Broadcom蓝牙firmware，对于所有non-Apple/non-Fenvi Airport卡都需要。需要注意，这个kext是和 ``BrcmFirmwareData.kext`` 配对使用的，并且针对不同macOS需要使用不同的 ``BrcmPatchRAM`` :

  - 对于macOS 10.15+，必须配对 ``BrcmBluetoothInjector`` 使用 ``BrcmPatchRAM3``
  - 对于macOS 10.11-10.14 ，使用 ``BrcmPatchRAM2``
  - 对于macOS 10.8-10.10，使用 ``BrcmPatchRAM``
  - 对于macOS 10.11 到 macOS 11，还需要 ``BrcmBluetoothInjector``

- ``BrcmFirmwareData.kext`` (见上文 ``BrcmPatchRAM`` )
- ``BrcmBluetoothInjector`` (见上文 ``BrcmPatchRAM`` )

.. note::

   实际上上述kexts分别来自2个包:

   - `BrcmPatchRAM <https://github.com/acidanthera/BrcmPatchRAM/releases>`_
   - `AirportBrcmFixup <https://github.com/acidanthera/AirportBrcmFixup/releases>`_

修订config.plist
==================

打开了配置文件以后，按下 ``Cmd/Ctrl + Shift + R`` 然后指向 ``EFI/OC`` 来执行一个 ``Clean Snapshot`` ，此时会移除 ``config.plist`` 中所有对象，然后添加所有前面配置的 ``SSDTs`` ， ``Kexts`` 和 Firmware驱动。

这个过程自动完成，并且会自动排列 ``Lilu`` 在BlueToolFixup等扩展前面(表示依赖关系)

参考
=======

- gemini
- `dortania: Wireless Buyers Guide <https://dortania.github.io/Wireless-Buyers-Guide/>`_ 官方文档说明了应该选择哪种无线网卡来安装黑苹果
