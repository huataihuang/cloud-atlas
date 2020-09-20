.. _usb_boot_ubuntu_pi_4:

====================================
树莓派4 USB启动Ubuntu Server 20.04
====================================

我在折腾 :ref:`usb_boot_pi_3` 时发现Ubuntu Server 20.04 for Raspberry Pi版本在树莓派上启动特性和标准的树莓派不同，设置USB存储启动步骤比较复杂。


参考
======

- `USB Boot Ubuntu Server 20.04 on Raspberry Pi 4 <https://eugenegrechko.com/blog/USB-Boot-Ubuntu-Server-20.04-on-Raspberry-Pi-4>`_ - 这篇文章非常详尽解说了从外接USB存储启动Ubuntu Server for Raspberry Pi的方法，比通过工具无脑操作要更有技术性
- `How to Boot Raspberry Pi 4 From a USB SSD or Flash Drive <https://www.tomshardware.com/how-to/boot-raspberry-pi-4-usb>`_ 采用了 raspi-config 工具来设置Raspberry Pi OS，是树莓派官方解决方案，比较简单傻瓜化，不过只能用于树莓派官方操作系统
