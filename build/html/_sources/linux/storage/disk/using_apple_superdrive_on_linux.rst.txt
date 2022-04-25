.. _using_apple_superdrive_on_linux:

======================================
在Linux系统中使用Apple SuperDrive光驱
======================================

我在Linux( :ref:`kali_linux` )上使用过之前为苹果电脑购买的Apple SuperDrive光驱(原装吸入式)，发现当插入USB接口之后，光驱毫无反应。虽然操作系统日志显示已经识别了设备::

   [Sat Apr 23 19:51:40 2022] usb 2-1: new SuperSpeed Gen 1 USB device number 2 using xhci_hcd
   [Sat Apr 23 19:51:40 2022] usb 2-1: LPM exit latency is zeroed, disabling LPM.
   [Sat Apr 23 19:51:40 2022] usb 2-1: New USB device found, idVendor=08e4, idProduct=017a, bcdDevice= 1.00
   [Sat Apr 23 19:51:40 2022] usb 2-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
   [Sat Apr 23 19:51:40 2022] usb 2-1: Product: Pioneer Blu-ray Drive
   [Sat Apr 23 19:51:40 2022] usb 2-1: Manufacturer: Pioneer Corporation
   [Sat Apr 23 19:51:40 2022] usb 2-1: SerialNumber: 1340072912700015
   [Sat Apr 23 19:51:40 2022] usb-storage 2-1:1.0: USB Mass Storage device detected
   [Sat Apr 23 19:51:40 2022] scsi host0: usb-storage 2-1:1.0
   [Sat Apr 23 19:51:41 2022] scsi 0:0:0:0: CD-ROM            PIONEER  BD-RW  BDR-XS07  1.00 PQ: 0 ANSI: 0
   [Sat Apr 23 19:51:41 2022] sr 0:0:0:0: Power-on or device reset occurred
   [Sat Apr 23 19:51:41 2022] sr 0:0:0:0: [sr0] scsi3-mmc drive: 62x/62x writer dvd-ram cd/rw xa/form2 cdda tray
   [Sat Apr 23 19:51:41 2022] sr 0:0:0:0: Attached scsi CD-ROM sr0
   [Sat Apr 23 19:51:41 2022] sr 0:0:0:0: Attached scsi generic sg0 type 5

但是在文件管理器 ``thunar`` 中却看不到光驱图标显示，而光驱也毫无加电轴承转动的声音。

由于苹果的SuperDrive光驱是吸入式并且没有任何按钮，没有动静也无法插入光盘。

Google了一下，原来在Linux上使用Apple SuperDrive光驱，需要首先安装 SCSI 通用设备驱动::

   sudo apt install sg3-utils

安装以后，使用 ``sg_raw`` 命令激活光驱::

   sg_raw /dev/sr0 EA 00 00 00 00 00 01

此时提示::

   NVMe Result=0x0

就会看到文件管理器中自动出现了光驱图标，而且SuperDrive光驱的转轴开始转动。此时就可以塞入光盘进行读写。

为了能够自动完成上述命令动作，可以在 ``udev`` 中添加规则::

   cat << EOF > /etc/udev/rules.d/60-apple-superdrive.rules
   # Apple's USB SuperDrive
   ACTION=="add", ATTRS{idProduct}=="1500", ATTRS{idVendor}=="05ac", DRIVERS=="usb", RUN+="/usr/bin/sg_raw /dev/$kernel EA 00 00 00 00 00 01"
   EOF

然后出发udev规则生效::

   udevadm trigger

或者重启操作系统使之生效

参考
=======

- `Using Apple’s SuperDrive on Linux <https://kuziel.nz/notes/2018/02/apple-superdrive-linux.html>`_
