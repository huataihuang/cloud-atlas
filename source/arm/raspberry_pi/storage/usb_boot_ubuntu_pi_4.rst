.. _usb_boot_ubuntu_pi_4:

====================================
树莓派4 USB启动Ubuntu Server 20.04
====================================

我在折腾 :ref:`usb_boot_pi_3` 时发现Ubuntu Server 20.04 for Raspberry Pi版本在树莓派上启动特性和标准的树莓派不同，设置USB存储启动步骤比较复杂。

更新firmware以支持USB启动
==========================

首先需要确保Raspberry Pi 4支持从USB启动，就是需要将Raspbian (树莓派官方操作系统) 安装到SD卡并更新firmware。

可以参考 `YouTube上视频 "Stable Raspberry Pi 4 USB boot (HOW-TO)" <https://www.youtube.com/watch?v=tUrX9wzhygc>`_ 升级树莓派的boot loader，完成后再进入下一步。

.. note::

   树莓派官方提供的raspbian系统包含了 ``rpi-eeprom`` 和 ``rpi-eeprom-images`` ，用于更新树莓派firmware。可以直接使用官方提供的32位Raspbian系统就可以，我们只是使用官方镜像来更新firmware，完成后，我们依然安装Ubuntu 64位Server版本。

使用树莓派官方镜像启动系统后，进入操作系统，执行以下命令进行系统更新::

   sudo apt update
   sudo apt upgrade
   sudo rpi-update
   sudo reboot

如果你的firmware是beta版本，则需要修改 ``/etc/default/rpi-eeprom-update`` 配置文件，将::

   FIRMWARE_RELEASE_STATUS="critical"

修改成::

   FIRMWARE_RELEASE_STATUS="stable"

如果你的firmware是beta版本，则修改上述 ``/etc/default/rpi-eeprom-update`` ，从 ``beta`` 参数 修改成 ``stable`` ，也是一样的方法。

然后执行以下命令更新bootloader(具体需要根据实际当时提供的软件版本来定)::

   sudo rpi-eeprom-update -d -f /lib/firmware/raspberrypi/bootloader/stable/pieeprom-2020-09-03.bin

.. note::

   目前GPU的firmware还是beta版本，今后可能还需要刷新。

完成bootloader更新之后，再次重启::

   sudo reboot

重启以后确保能够正常进入系统，然后我们需要验证firmware是否更新成功::

   vcgencmd bootloader_version

需要确保版本显示的是正确的 ``Sep 03`` 日期。

然后检查 bootloader 配置::

   vcgencmd bootloader_config

显示中有::

   ...
   BOOT_ORDER=0xf41

.. note::

   只需要在第一台树莓派上完成firmware和bootloader更新，然后把这个TF卡放到其他没有升级过的树莓派上，只需要第一次启动，存储在TF卡中最新的firmware就会自动更新硬件，因为默认就配置了启动时自动更新firmwre，所以只要操作系统存储着最新的firmware就会在启动时更新。

   所以，上述操作只需要做一次，其他树莓派只需要用这个TF卡插入开机重启一次就可以升级好。(树莓派每次启动都会检查本机最新的firmware进行升级)

安装64位Ubuntu Server
========================

参考 :ref:`ubuntu64bit_pi` 安装Ubuntu 64位树莓派服务器版本。

.. note::

   现在我们已经不再需要树莓派官方提供的 Raspbian 运行TF卡了，请把该存储卡保存好，今后可能还会再次使用用来更新firmware。

划分SSD存储
==============

我的规划是使用SSD存储30G空间部署系统，启用空间划分给 :ref:`gluster` 和 :ref:`ceph` ，以及构建本地 :ref:`docker` 运行存储。

- 把 :ref:`wd_passport_ssd` 插入树莓派4的USB接口(请使用蓝色的USB 3.0接口)，然后执行以下命令进行磁盘分区和文件系统格式化。划分方法统一采用分区方法，参考 :ref:`usb_boot_pi_3`

.. literalinclude:: parted_pi_ssd
   :linenos:

- 格式化文件系统::

   mkfs.fat -F32 /dev/sda1
   mkfs.ext4 /dev/sda2

挂载SSD存储的系统启动分区
============================

- Ubuntu for Raspberry Pi 分区挂载如下::

   /dev/mmcblk0p2  117G  4.1G  109G   4% /
   /dev/mmcblk0p1  253M   97M  156M  39% /boot/firmware

需要对应复制到新的SSD存储中，采用 ``tar`` 打包::

   cd /
   tar -cpzf pi.tar.gz --exclude=/pi.tar.gz --one-file-system /


更新 .dat 和 .elf 文件
============================

- 下载最新的raspberry pi的firmware::

   git clone git@github.com:raspberrypi/firmware.git

 不过，这个仓库非常巨大，所以如果你要节约下载时间，可以采用chrome插件 `GitZip <https://gitzip.org/>`_ 来指定只下载部分文件。

可以直接从 raspbian 的 目录 ``/boot`` 复制 .dat 和 .elf 文件到Ubuntu的 ``/boot`` 分区::

   sudo cp /boot/*.dat /mnt/boot/
   sudo cp /boot/*.elf /mnt/boot/

也可以从 GitHub 获取 `raspberrypi/firmware <https://github.com/raspberrypi/firmware/tree/master/boot>`_ 获取。

参考
======

- `USB Boot Ubuntu Server 20.04 on Raspberry Pi 4 <https://eugenegrechko.com/blog/USB-Boot-Ubuntu-Server-20.04-on-Raspberry-Pi-4>`_ - 这篇文章非常详尽解说了从外接USB存储启动Ubuntu Server for Raspberry Pi的方法，比通过工具无脑操作要更有技术性
- `How to Boot Raspberry Pi 4 From a USB SSD or Flash Drive <https://www.tomshardware.com/how-to/boot-raspberry-pi-4-usb>`_ 采用了 raspi-config 工具来设置Raspberry Pi OS，是树莓派官方解决方案，比较简单傻瓜化，不过只能用于树莓派官方操作系统
