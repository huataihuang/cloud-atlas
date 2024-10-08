.. _jetson_storage:

=================================
Jetson 存储
=================================

和 :ref:`pi_storage` 相似，Jetson Nano作为ARM基础的计算机系统，存储子系统对系统运行性能有很大影响，默认采用缓慢的SD卡将拖慢系统运行:

- 虽然能够将存储迁移到USB磁盘或者通过内部 m.2 WiFi接口转接NGFF存储(也就是m.2接口形式的SATA SSD)，但是依然有一个必要的分区必须是在TF卡上，所以无法完全去掉TF卡
- `can this board use m.2 ssd nvme <https://forums.developer.nvidia.com/t/can-this-board-use-m-2-ssd-nvme/72643>`_ 讨论了在 m.2 接口如何专程m.2的NGFF存储，淘宝上有这样的转接卡(不过我还没有实践)

.. toctree::
   :maxdepth: 1

   usb_boot_jetson.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
