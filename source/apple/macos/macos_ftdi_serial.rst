.. _macos_ftdi_serial:

========================
macOS串口连接FTDI设备
========================

在管理和配置 :ref:`ws-c4948-s` ，需要通过串口程序访问交换机管理控制台。以往在Linux平台，通常会使用 ``minicom`` 或者 ``screen`` 程序。不过，在macOS平台上，稍微折腾一些。

一般我们使用的串口线内部都使用一个FTDI芯片，这样就可以和单片机(Arduino设备)的FTDI芯片通讯。macOS系统需要使用FTDI设备驱动，早期Mac OS X没有支持FTDI驱动，所以需要安装第三方FTDI驱动。大约在macOS 10.12 Sierra或更早版本，内置支持了FTDI驱动。不过，现在的macOS没有包含驱动，所以从 `FTDI Chip 官方下载驱动 <https://ftdichip.com/drivers/vcp-drivers/>`_ ，然后参考 `FTDI Chip Installation Guides <https://ftdichip.com/document/installation-guides/>`_ 进行安装。

- 下载 `FTDIUSBSerialDextInstaller_1_4_7.zip <https://www.ftdichip.com/Drivers/VCP/MacOSX/FTDIUSBSerialDextInstaller_1_4_7.zip>`_ ，解压缩以后是一个执行文件，这个执行文件必须复制到 ``Applications`` 目录下运行
- 程序 ``FTDIUSBSerialDextInstaller_1_4_7`` 移动到 ``Applications`` 目录下然后运行，此时会提示安全阻断，通过在控制面板安全性允许该程序运行，就完成了安装

重启操作系统，然后重新插入 USB 串口控制线，此时执行::

   ls /dev/tty.usb*

就会看到识别出的新串口设备，例如::

   /dev/tty.usbserial-1410

串口程序
============

可以使用 ``screen`` 程序来使用这个串口设备( :ref:`tmux` 不支持串口通讯，所以还是使用传统的 ``screen`` )::

   screen /dev/tty.usbserial-1410 9600

参数 ``9660`` 是终端串口速率。其他串口工具可以用 ``cu`` ( `cu — serial terminal emulator <https://man.openbsd.org/cu>`_ ) 或 ``minicom``

- 使用 ``cu`` ::

   sudo cu -s 9600 -l /dev/tty.usbserial-1410 

.. note::

   macOS 是BSD体系，默认内置了 ``screen`` 和 ``cu``

参考
=======

- `How to Fix FTDI Driver Issue on Mac and macOS <https://aloriumtech.com/how-to-fix-ftdi-driver-issue-on-mac-and-macos/>`_
- `How to Install FTDI Drivers <https://learn.sparkfun.com/tutorials/how-to-install-ftdi-drivers/mac>`_
- `FTDI Chip文档: Mac OS X Installation Guide <https://ftdichip.com/wp-content/uploads/2020/08/AN_134_FTDI_Drivers_Installation_Guide_for_MAC_OSX-1.pdf>`_ 
- `Is there an OS X terminal program that can access serial ports? <https://apple.stackexchange.com/questions/32834/is-there-an-os-x-terminal-program-that-can-access-serial-ports>`_
