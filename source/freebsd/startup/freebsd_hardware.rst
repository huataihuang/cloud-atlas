.. _freebsd_hardware:

==========================
FreeBSD硬件
==========================

.. note::

   本文根据gemini建议整理，也许有一天我会购买新的笔记本硬件来运行FreeBSD

   目前我使用 :ref:`thinkpad_x220` 来运行FreeBSD

笔记本
========

虽然 FreeBSD 在笔记本硬件支持上不如 Linux 覆盖面广，但社区长期以来形成了非常明确、成熟的硬件选型共识。“买旧不买新、首选 ThinkPad” 是 FreeBSD 社区最经典的经验法则。

社区首选标杆：ThinkPad 系列
---------------------------------

Lenovo ThinkPad 是 FreeBSD 社区支持度最高、文档与驱动最完善的笔记本系列。FreeBSD 很多 core team 开发者和核心贡献者本身就是 ThinkPad 的长期使用者。

- 经典一代（最完美的兼容性，适合纯命令行或轻量 GUI）:

  - :ref:`thinkpad_x220` / X230 / T420 / T430 / T440p
  - 社区经验: 硬件完全被驱动识别。 ``Intel HD Graphics`` （Sandy/Ivy Bridge, Haswell）的  ``drm-kmod`` 极为稳定，ACPI 挂起/休眠（Suspend/Resume）、音量按键、TrackPoint（红点）以及 Fn 快捷键全功能正常。

- 现代黄金一代（性能与兼容性的最佳平衡点）:

  - ThinkPad X1 Carbon (Gen 5 / Gen 6 / Gen 7)
  - ThinkPad T480 / T480s / T490
  - 社区经验: 搭载 Intel 8代至10代 CPU 的机型是目前社区最推崇的“主力干活机”。Intel AC 9260 / 8265 无线网卡、核显加速、NVMe 固态硬盘均有完美支持，电池续航优化也非常成熟。

- 较新一代（11代~13代 Intel/AMD）:

  - ThinkPad T14 / P14s (Intel/AMD)
  - 社区经验: 需要运行最新的 FreeBSD 14.x 或 15-CURRENT。Intel Iris Xe 或 AMD Radeon (amdgpu) 驱动在最新的 drm-kmod 下已得到良好支持，但 Wi-Fi 6（AX200 等）速度或睡眠唤醒可能需要稍作调优。

其他社区验证良好的机型
----------------------------

- Framework Laptop (13-inch, Intel 11th/12th Gen):

  - 特点： 高度可模块化。FreeBSD 社区对 Framework 有极高热情，官方论坛有非常详尽的 FreeBSD 安装指导，所有模块扩展卡在 FreeBSD 下均能良好工作。

- Dell XPS 13 (如 9360 / 9370 / 9380):

  - 特点： 经典的高颜值轻薄本。除了部分机型集成的 Broadcom 无线网卡需要替换（替换为 Intel 网卡）之外，显示、电源管理和键盘映射都很完美。

避坑指南与选型硬性指标
=======================

.. csv-table:: FreeBSD笔记本硬件选择
   :file: freebsd_hardware/laptop.csv
   :widths: 20,20,30,30
   :header-rows: 1

参考
======

在入手具体机型前，强烈建议先查询社区整理的硬件兼容数据库:

- `FreeBSD Laptops Wiki (官方 Wiki) <https://wiki.freebsd.org/Laptops>`_ : 收录了数十种具体机型（从 ThinkPad 到 Framework）的逐项测试报告（包含了 Suspend/Resume、Wi-Fi、Audio、GPU 的测试状态）
- `BSD Hardware Database (HW-Probe) <https://bsd-hardware.info/>`_ : 全球 BSD 用户上传的硬件扫描报告，可以清晰看到某款笔记本在 FreeBSD 哪个版本下的硬件驱动率（Probed / Working 比例）

