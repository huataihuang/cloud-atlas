.. _intro_pi_uart:

==================
树莓派UART通讯简介
==================

UART(Universal Asynchronous Receiver/Transmitter) (通用异步接收器/发送器)是一种串行通信协议，其中数据是串行传输的，即逐位传输。异步串行通讯是广泛使用的面向字节的传输。在异步串行通讯中，一次传输一个字节的数据。

异步传输运训发送方不必想接收方发送时钟信号就可以传输数据。相反，发送方和接收方事先就时序参数(timing parameters)达成一致(agree on timing parameters in advance)，并且将称为 ``起始位`` (start bits)的特殊位添加到每个字中，并用于同步发送和接收单元。

UART串行通讯协议对其数据字节使用定义的帧接口。在异步通信中的帧结构包括:

- 起始位(START bit): 该位表示串行通信已经开始，并且这个位始终是低电平
- 数据位包(Data bits packet): 数据位可以是5到9位的数据包。通常我们使用8位数据包，数据包总是在START bit之后发送
- 停止位(STOP bit): 停止位通常是1到2位长度。停止为在数据包之后发送指示帧的结束。停止位始终是高电平

.. figure:: ../../../_static/arm/raspberry_pi/uart/1_PIC18F4550_USART_Frame_Structure.png 
   :scale: 70

UART通常在树莓派上用于通过GPIO来作为控制方式，或者从串行控制台访问内核启动消息(默认启用)。

.. note::

   我们在服务器和网络设备上，经常会使用一种串口控制台，来实现没有网络情况下访问计算机系统。特别在操作系统异常情况下，排查内核故障需要这种设备通讯。树莓派的硬件上，提供了这种关键的串行通讯技术。

激活UART
===========

树莓派提供了一个激活 ``UART`` 的属性参数，不过激活 ``UART`` 默认会将核心频率设置为最小，以便确保稳定性。

- ``/boot/usercfg.txt`` ::

   # Enable UART
   enable_uart=1

还有一种设置是启用 ``UART`` 同时保持处理器核心主频依然最高，不过需要注意提供足够电力，并且要确保系统冷却(风扇)。这个设置需要同时启用以下2个参数：

- ``/boot/usercfg.txt`` ::

   # Enable UART
   enable_uart=1
   force_turbo=1

详细参考 `STICKY: Pi3 UART stopped working? Read this. <https://forums.raspberrypi.com/viewtopic.php?f=28&t=141195>`_

参考
=====

- `Raspberry Pi UART Communication using Python and C <https://www.electronicwings.com/raspberry-pi/raspberry-pi-uart-communication-using-python-and-c>`_
- `UART - Universal Asynchronous Receiver/Transmitter <https://pinout.xyz/pinout/uart>`_
- `UART for Serial Console or HAT on Raspberry Pi 3 <https://www.hackster.io/fvdbosch/uart-for-serial-console-or-hat-on-raspberry-pi-3-5be0c2#>`_
