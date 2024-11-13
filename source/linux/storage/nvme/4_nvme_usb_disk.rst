.. _4_nvme_usb_disk:

========================
4盘位NVMe转USB3.2硬盘盒
========================

由于苹果 :ref:`macos` 设备非常昂贵，特别是基础版本之上任何组件升级选购都需要比PC通用设备昂贵很多，所以很多时候我们不得不选择 "丐中丐" 的基础规格。当然，现代Mac设备已经无法替换升级内存和硬盘，但是由于 :ref:`thunderbolt` 和 USB接口 的速度不断进步，所以依然可以通过扩容移动设备来增强容量。

我最初是调研 :ref:`mac_mini_2024` 如何扩展存储，由于 Mac mini 的 :ref:`thunderbolt` 接口较多(3个)，所以考虑可以购买多个 :ref:`thunderbolt` 外接盘来构建扩展存储:

- 优点: 性能相对较高，每一个 :ref:`nvme` 存储都有独立I/O通道，尽可能发挥存储性能
- 缺点:

  - 每个 :ref:`thunderbolt` 外接硬盘都需要花费300~400元，至少3个累计需要 1000~1200 元
  - 需要占用宝贵的 :ref:`thunderbolt` ，实际上 :ref:`thunderbolt` 也是外接 :ref:`pcie` 扩展GPU的重要接口，是提升 :ref:`macos` / :ref:`linux` GPU性能以及 :ref:`machine_learning` 重要接口
  - 通用性较差: :ref:`thunderbolt` 接口外接存储只能用于 :ref:`macos` 系统，无法在常规的PC服务器，例如 :ref:`hpe_dl360_gen9` 上使用

综合考虑成本、通用性以及性能，我最终选择了 **OTSK** `` 4盘位NVMe转USB3.2硬盘盒`` :

.. figure:: ../../../_static/linux/storage/nvme/4_nvme_usb_disk.jpg

   4盘位NVMe转USB3.2硬盘盒外观



