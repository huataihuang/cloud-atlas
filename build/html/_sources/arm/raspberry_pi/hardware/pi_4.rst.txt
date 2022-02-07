.. _pi_4:

======================
树莓派Raspberry Pi 4
======================

.. figure:: ../../../_static/arm/raspberry_pi/hardware/pi4.png
   :scale: 75

Raspberry Pi 4是一个非常小巧的多显示输出桌面级计算机，刚拿到手，我就觉得制作工艺已经比前几代有很大提高，特别是元器件小型化，使得加上金属保护壳之后的颜值非常高。

.. figure:: ../../../_static/arm/raspberry_pi/hardware/pi4_case.png
   :scale: 75

.. note::

   我最初购买的是无风扇金属外壳，外观更靓，并且我感觉无风扇静音更适合随身使用。但是非常可惜树莓派4确实发热量大，无风扇情况下室温25度左右，待机大约50+度。出于对设备保护以及安放在桌下角落中，我还是推荐购买带风扇外壳。

技术规格
==========

.. figure:: ../../../_static/arm/raspberry_pi/hardware/pi_4_blueprint-labelled.png
   :scale: 75

- Broadcom BCM2711处理器：4核心Cortex-A72(ARM v8) 64位处理器，主频1.5GHz (2021年11月软件更新后默认turbo-mode从1.5GHz升级到1.8GHz，等同于 :ref:`pi_400` `Your Raspberry Pi 4 may have just got an unexpected speed boost <https://www.zdnet.com/article/your-raspberry-pi-4-may-have-just-got-an-unexpected-speed-boost/>`_ ) 

  - 树莓派4b的处理器属于A72架构，比 :ref:`jetson` 的A57架构要先进一代，据评测性能提升了1.8倍。(不过，NVIDIA是买GPU送CPU，所以也不能要求太高)
  - Cortex-A72(ARM v8) 支持 :ref:`arm_kvm` 

- 提供2GB, 4GB 或 8GB LPDDR4-3200 SDRAM 三种规格
- 2.4GHz和5.0GHz IEEE 802.11ac无线以及蓝牙5.0
- 一个千兆以太网 - 据说已经能够跑满千兆网速，待测试
- 2个USB 3.0和2个USB 2.0接口 - USB 3.0接口可以用来连接外部移动硬盘，扩展树莓派存储能力
- 2个micro-HDMI接口，支持4k高清60帧播放
- 4-pole立体声和合成视频端口
- 支持 H.265(4kp60编码)，H264(1080p60编码，1080p30编码)
- OpenGL ES 3.0图形支持
- Micro-SD卡(TF卡)插槽支持加载操作系统和数据存储
- 5V直流USB-C接口(最小3A)
- 支持Power over Ethernet(PoE) enabled(需要独立的PoE HAT)
- 可以在0-50摄氏度之间运行

参考
======

- `Raspberry Pi 4 Tech Specs <https://www.raspberrypi.org/products/raspberry-pi-4-model-b/specifications/>`_
