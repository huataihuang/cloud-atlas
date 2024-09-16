.. _pi_5:

======================
树莓派Raspberry Pi 5
======================

硬件规格
============

- 处理器: Broadcom BCM2712 quad-core Arm Cortex A76 processor @ 2.4GHz (大约是上一代 :ref:`pi_4` 的2~3倍性能)
- 内存: 最高8GB
- 存储接口: PCIe 2.0 X1 接口FPC连接器
- PWM控制风扇接口(需要主动散热)

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

.. note::

   树莓派5由于芯片频率提升且多核，必须采用主动散热来确保系统稳定运行

参考
========

- `官网Raspberry Pi 5 <https://www.raspberrypi.com/products/raspberry-pi-5/>`_
