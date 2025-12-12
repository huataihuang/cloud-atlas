.. _pi_5:

======================
树莓派Raspberry Pi 5
======================

硬件规格
============

- 处理器: Broadcom BCM2712 quad-core Arm Cortex A76 processor @ 2.4GHz (大约是上一代 :ref:`pi_4` 的2~3倍性能)

  - 内置 ``H.265`` (HEVC)硬件加速解码( **但是不支持H.264硬件解码** ，所以播放H.264视频会非常卡顿)

- 内存: 最高8GB(LPDDR4-4267)
- 存储接口: PCIe 2.0 X1 接口FPC连接器
- PWM控制风扇接口(需要主动散热)
- 千兆以太网，支持双频802.11ac的无线网络及蓝牙5.0 (和 :ref:`pi_4` 一样)
- 额定功率 25W(5V/5A)

.. note::

   淘宝 `亚博智能科技: 树莓派5代 <https://item.taobao.com/item.htm?abbucket=13&id=752288296981&ns=1>`_

.. figure:: ../../_static/raspberry_pi/hardware/pi_5.avif

   树莓派5

必要配件
===========

运行基础环境，至少应该有:

- Raspberry Pi 5 主板
- 树莓派5 官方主动散热器

  - 安装手册见 `Raspberry Pi Active Coller for Raspberry Pi 5 <https://datasheets.raspberrypi.com/cooling/raspberry-pi-active-cooler-product-brief.pdf>`_ ：注意，连接线接头插入方向(红线向内)，主板上 ‘FAN’ 有一个盖帽需要取下来( `How do you attach the case fan on the Raspberry Pi 5? <https://raspberrypi.stackexchange.com/questions/145095/how-do-you-attach-the-case-fan-on-the-raspberry-pi-5>`_ / `Constant Fan - Active Cooler for Raspberry Pi 5 <https://forums.raspberrypi.com/viewtopic.php?t=358253>`_ )

- 树莓派5 官方电源

  - 官方标配27W USB-C电源: 考虑到 :ref:`pi_5_pcie_m.2_ssd` 需要稳定电力，建议选用官方认证电源

日常我使用苹果 20W 快充(比较轻携带方便)，但是在执行 :ref:`` 重负载编译，会出现如下(控制台输出)电源电压过低告警，并且在2分钟后hang机:

.. literalinclude:: pi_5/hwmon_undervoltage_error
   :caption: 没有使用官方电源在重负载下会导致电邀过低宕机

.. note::

   树莓派5由于芯片频率提升且多核，必须采用主动散热来确保系统稳定运行

Raspberry Pi CM5
====================

2025年7月， `Build Your Own ARM Laptop with the New Argon ONE UP! <https://www.youtube.com/watch?v=WLilGkSihXo>`_ 介绍了一款由 Argon 众筹的基于Raspberry Pi CM5计算模块的 `Argon ONE UP笔记本电脑 <https://www.kickstarter.com/projects/argonforty/upton-one-the-true-raspberry-pi-compute-module-5-laptop>`_ 。从介绍视频来看，确实是一款非常实用的ARM架构笔记本电脑。而且，还通过改造过的USB-C接口，输出了GPIO模块接口。

虽然性能有限，作为16GB内存的树莓派5移动设备，一体化体验的开放软硬件系统，感觉非常有意思。如果价格能够压制到 ``2000RMB`` 以内，感觉 :strike:`还是可以选择的` 。

.. note::

   时光白驹过隙，很多年前我曾经想尝试 :ref:`pinebook_pro` 笔记本，然而购买渠道和售价劝退了我。感觉 ``Argon ONE UP笔记本`` 出得太晚了，明年苹果即将推出廉价版MacBook，以苹果设计和制造工艺，使得这些小众的产品凸显了产量太低而成本过高、品控难保，除非是自己经济宽裕到能够买来作为爱好的玩具。唉...

参考
========

- `官网Raspberry Pi 5 <https://www.raspberrypi.com/products/raspberry-pi-5/>`_
