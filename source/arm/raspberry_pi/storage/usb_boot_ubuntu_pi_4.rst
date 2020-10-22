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

复制系统到SSD存储
==================

通过dd复制系统(可选)
---------------------

- 采用 ``dd`` 命令完整复制磁盘::

   dd if=/dev/mmcblk0 of=/dev/sda bs=100M

- 然后挂载SSD磁盘分区::

   mount /dev/sda2 /mnt
   mount /dev/sda1 /mnt/boot/firmware

通过tar复制系统(推荐)
----------------------------------------------

.. note::

   采用tar包方式clone系统，可以灵活调整磁盘分区。

我的规划是使用SSD存储30G空间部署系统，启用空间划分给 :ref:`gluster` 和 :ref:`ceph` ，以及构建本地 :ref:`docker` 运行存储。

- 把 :ref:`wd_passport_ssd` 插入树莓派4的USB接口(请使用蓝色的USB 3.0接口)，然后执行以下命令进行磁盘分区和文件系统格式化。划分方法统一采用分区方法，参考 :ref:`usb_boot_pi_3`

.. literalinclude:: parted_pi_ssd
   :linenos:

.. warning::

   虽然根据网上信息，树莓派不支持GPT分区表启动，但是我实践下来发现GPT分区表是可行的，也就是可以非常容易支持超过2T的磁盘。

- 格式化文件系统::

   mkfs.fat -F32 /dev/sda1
   mkfs.ext4 /dev/sda2

.. note::

   如果你格式化磁盘加上了原先TF卡分区的label，就可以使得SSD磁盘标识和原先TF卡一致，这样就可以省去启动配置中有关磁盘PARTUUID的麻烦。所以，我推荐你采用格式化磁盘时加上label。详细见下文。

- Ubuntu for Raspberry Pi 分区挂载如下::

   /dev/mmcblk0p2  117G  4.1G  109G   4% /
   /dev/mmcblk0p1  253M   97M  156M  39% /boot/firmware

需要对应复制到新的SSD存储中，采用 ``tar`` 打包::

   cd /
   #tar打包系统不包含跨磁盘目录，所以/boot/firmware需要单独复制
   tar -cpzf pi.tar.gz --exclude=/pi.tar.gz --one-file-system /
   
   mount /dev/sda2 /mnt
   sudo tar -xpzf /pi.tar.gz -C /mnt --numeric-owner

   mount /dev/sda1 /mnt/boot/firmware
   (cd /boot/firmware && tar cf - .)|(cd /mnt/boot/firmware && tar xf -)

以上已经完整将原先在TF卡上运行的 :ref:`ubuntu64bit_pi` 复制到了USB外接的SSD移动硬盘上。

- 检查SSD磁盘的UUID，我们需要将PARTUUID配置到启动命令 ``cmdline.txt`` 配置文件以及 ``fstab`` 配置文件，正确反映磁盘挂载和启动分区::

   # blkid /dev/sda
   /dev/sda: PTUUID="b541639f" PTTYPE="dos"
   # blkid /dev/sda1
   /dev/sda1: UUID="6E36-5E03" TYPE="vfat" PARTUUID="b541639f-01"
   # blkid /dev/sda2
   /dev/sda2: UUID="f4d2caed-9b2c-4645-99b4-8b406eb7d3f1" TYPE="ext4" PARTUUID="b541639f-02"

这里的 ``PARTUUID`` 需要修改对应配置。

- 编辑 ``/mnt/boot/firmware/cmdline.txt`` 将::

   net.ifnames=0 dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=LABEL=writable rootfstype=ext4 elevator=deadline rootwait fixrtc

修改成::

   net.ifnames=0 dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=PARTUUID="b541639f-02" rootfstype=ext4 elevator=deadline rootwait fixrtc

.. note::

   这里 ``PARTUUID=`` 是USB外接SSD磁盘的分区2的PARTUUID。注意，是SSD磁盘，所以 ``elevator=`` 参数保持和原先TF卡配置一样，还是 ``deadline`` 。不过，如果你的外接磁盘是机械硬盘，则参数改为 ``cfq`` 。

- 编辑 ``/mnt/etc/fstab`` ，将::

   LABEL=writable	/	 ext4	defaults	0 0
   LABEL=system-boot       /boot/firmware  vfat    defaults        0       1

修改成::

   PARTUUID="b541639f-01"	/	 ext4	defaults	0 0
   PARTUUID="b541639f-02"  /boot/firmware  vfat    defaults        0       1

.. note::

   以上是通过tar方式复制系统，我在最初尝试时没有成功。我还以为是这个方法存在问题，后来才发现实际上是因为内核没有解压缩导致的。详见下文

有关树莓派分区表
----------------

注意到SD卡使用的分区表是msdos，但是我在划分USB外接移动硬盘时候，使用了 ``parted`` 将磁盘的分区表构建成了GPT。参考 `booting from a GPT mass storage device <https://www.raspberrypi.org/forums/viewtopic.php?t=205418>`_ 了解到树莓派不支持GPT分区表的磁盘启动，而是要使用2TB以下磁盘，采用msdos分区表启动。有人尝试将MBR转换成GPT(使用 ``gdisk`` 工具的选项 ``r-f-y-w`` )，虽然GPT分区正确并且数据能够在Mac/Windows/Linux上读取，但是树莓派3不能从磁盘启动，始终看到的是彩虹屏幕。

我在树莓派4上最后测试验证GPT分区表是可以支持启动的，树莓派3后续有机会再测试。

`Hybrid MBRs: The Good, the Bad, and the So Ugly You'll Tear Your Eyes Out <https://www.rodsbooks.com/gdisk/hybrid.html>`_ 使用 ``gdisk`` 转换分区表来实现混合分区表(方法待参考)::

   # gdisk /dev/sda
   GPT fdisk (gdisk) version 1.0.5
   
   Partition table scan:
     MBR: protective
     BSD: not present
     APM: not present
     GPT: present
   
   Found valid GPT with protective MBR; using GPT.
   
   Command (? for help): r
   
   Recovery/transformation command (? for help): p
   Disk /dev/sda: 2000343040 sectors, 953.8 GiB
   Model: My Passport 25F3
   Sector size (logical/physical): 512/4096 bytes
   Disk identifier (GUID): A0ACD939-81CF-4874-B5E3-45B51A11B1B5
   Partition table holds up to 128 entries
   Main partition table begins at sector 2 and ends at sector 33
   First usable sector is 34, last usable sector is 2000343006
   Partitions will be aligned on 2048-sector boundaries
   Total free space is 1941751741 sectors (925.9 GiB)
   
   Number  Start (sector)    End (sector)  Size       Code  Name
      1            2048          499711   243.0 MiB   EF00  primary
      2          499712        58593279   27.7 GiB    8300  primary
   
   Recovery/transformation command (? for help): h
   
   WARNING! Hybrid MBRs are flaky and dangerous! If you decide not to use one,
   just hit the Enter key at the below prompt and your MBR partition table will
   be untouched.
   
   Type from one to three GPT partition numbers, separated by spaces, to be
   added to the hybrid MBR, in sequence: 1 2
   Place EFI GPT (0xEE) partition first in MBR (good for GRUB)? (Y/N): y
   
   Creating entry for GPT partition #1 (MBR partition #2)
   Enter an MBR hex code (default EF):
   Set the bootable flag? (Y/N): y
   
   Creating entry for GPT partition #2 (MBR partition #3)
   Enter an MBR hex code (default 83):
   Set the bootable flag? (Y/N): n
   
   Unused partition space(s) found. Use one to protect more partitions? (Y/N): n
   
   Recovery/transformation command (? for help): o
   
   Disk size is 2000343040 sectors (953.8 GiB)
   MBR disk identifier: 0x16F2A91F
   MBR partitions:
   
   Number  Boot  Start Sector   End Sector   Status      Code
      1                     1         2047   primary     0xEE
      2      *           2048       499711   primary     0xEF
      3                499712     58593279   primary     0x83
   
   Recovery/transformation command (? for help): w
   
   Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
   PARTITIONS!!
   
   Do you want to proceed? (Y/N): y
   OK; writing new GUID partition table (GPT) to /dev/sda.
   The operation has completed successfully.

.. note::

   转换完成后，使用 ``fdisk -l`` 和 ``parted /dev/sda`` 检查，可以看到分区表依然是GPT(暂时没有探索明白)，后续我准备再采购新设备时重新实践一下。

解压缩内核
============

.. note::

   每次Ubuntu更新内核都需要重复执行这个步骤。

当前不支持压缩版本的64位arm内核启动，所以我们需要将 ``vmlinuz`` 解压成 ``vmlinux`` 。

- 找出镜像中gzip压缩的内容起点::

   cd /mnt/boot/firmware
   od -A d -t x1 vmlinuz | grep '1f 8b 08 00'

输出类似::

   0000000 1f 8b 08 00 00 00 00 00 02 03 ec 5c 0d 74 14 55

这里第一串数字 ``0000000`` 就是起点，也就是镜像的开始位置。

.. note::

   注意 /boot 目录和 /boot/firmware 目录下都有一个 vmlinuz 文件，前者是软链接，指向 ``/boot/vmlinuz-5.4.0-1021-raspi`` ，后者是实际文件 ``vmlinuz`` 。一定要操作 ``/boot/firmware`` 目录下的 ``vmlinuz`` ，而不是 ``/boot/vminuz`` ，否则从USB移动硬盘启动会报错::

      ...
      sdhci_send_command: MMC: 1 busy timeout.
      starting USB...
      No working controllers found
      USB is stopped. Please issue 'usb start' first.
      starting USB...
      No working controllers found
      No ethernet found.
      missing environment variable: pxeuuid
      missing environment variable: bootfile
      Retrieving file: pxelinux.cfg/00000000
      No ethernet found.
      ...
      Config file not found
      starting USB...
      No working controllers found
      No ethernet found.
      No ethernet found.
      U-Boot>

   然后停止响应。

- 使用 ``dd`` 命令展开数据然后用 ``zcat`` 解压缩到一个文件::

   dd if=vmlinuz bs=1 skip=0000000 | zcat > vmlinux

更新启动config.txt
===================

- 配置 ``config.txt`` 文件告知树莓派如何启动::

   vi /mnt/boot/firmware/config.txt

注释掉所有 ``[pi*]`` 段落，然后添加 ``kernel=vmlinux`` 和 ``initramfs initrd.img followkernel`` 到 ``[all]`` 段落::

   #[pi4]
   #kernel=uboot_rpi_4.bin
   #max_framebuffers=2
   
   #[pi2]
   #kernel=uboot_rpi_2.bin
   
   #[pi3]
   #kernel=uboot_rpi_3.bin
   
   [all]
   arm_64bit=1
   device_tree_address=0x03000000
   kernel=vmlinux
   initramfs initrd.img followkernel

更新 .dat 和 .elf 文件
============================

- 下载最新的raspberry pi的firmware，但是这个库非常巨大(10G+)，所以不建议直接clone，而是采用chrome插件 `GitZip <https://gitzip.org/>`_ 来指定只下载部分文件。

.. note::

   GitZip插件刚开始使用有点让我疑惑，实际上这个插件使用有两步：

   - 点击GitZip插件按钮，在弹出浮动窗口点 ``Get Token:Normal/Private`` 的 ``Normal`` 链接，转到GitHub授权页面给这个插件授权(即获得Github API Access Token)

   .. figure:: ../../../_static/arm/raspberry_pi/storage/gitzip_token.png
      :scale: 75

   - 然后在GitHub的文件中，选择文件或者目录，不要直接点文件或目录的url(这样还是转跳)而是在这一行中点空白处，并且连点2下。此时在这行的开头就会浮现一个勾选符号，并且页面右下角会浮现出下载按钮

.. figure:: ../../../_static/arm/raspberry_pi/storage/gitzip_download.png
   :scale: 75

- 将下载的最新Raspberry pi firmware 的 ``boot`` 目录下 ``.dat`` 和 ``.elf`` 文件到Ubuntu的 ``/boot`` 分区::

   sudo cp ~/Downloads/boot/*.dat /mnt/boot/firmware
   sudo cp ~/Downloads/boot/*.elf /mnt/boot/firmware

启动
==========

关机，将TF卡拔出，只连接USB外接的SSD移动硬盘，然后重启系统，观察Raspberry Pi从USB移动硬盘启动。

启动报错
----------

按照上述操作步骤，启动页面显示::

   lba: 2048 oem: 'mkfs.fat' volume: ' system-boot'
   rsc 32 fat-sectors 4033 c-count 516190 c-size 1 r-dir 2 r-sec 0
   Read config.txt bytes     1173 hnd 0x0001eb9c hash 'fafd37aa6348be46'
   recovery4.elf not found (6)
   recovery.elf not found

然后就是彩虹页面

这个报错看起来和我之前在做tar备份恢复的报错相同。

我仔细核对了一下 `USB Boot Ubuntu Server 20.04 on Raspberry Pi 4 <https://eugenegrechko.com/blog/USB-Boot-Ubuntu-Server-20.04-on-Raspberry-Pi-4>`_

我发现这个文档中就没有挂载过 ``/dev/sda2`` ，只是挂载 ``/dev/sda1`` 到 ``/mnt/ssdboot`` 目录下，然后所有操作都是在 ``/mnt/ssdboot`` 下进行的。我最初以为文章中所指的 ``vmlinuz`` 是指 ``/boot`` 目录下的 ``vmlinuz`` ( ``/dev/sda2`` 磁盘中的 ``/boot`` 目录)，但是核对以后发现实际操作的是SSD磁盘 ``/dev/sda1`` 对应的 ``/boot/firmware`` 目录下的 ``vmlinuz`` 。

原因是Ubuntu for Raspberry实际上在 ``/boot`` 和 ``/boot/firmware`` 目录下各有一个 ``vmlinuz`` 文件。看来是我操作错误了。

重新回到 ``/mnt/boot`` 目录，将这个目录下的 ``vmlinuz`` 解压的 ``vmlinux`` 复制到子目录 ``/mnt/boot/firmware`` ，并相应复制 ``initrd.img`` 到 ``/mnt/boot/firmware`` 。再次重启系统，就能够正常启动了。

Pi 4 Bootloader Configuration
-------------------------------

参考 `Raspberry Pi 4 boot EEPROM <https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md>`_ 指出 `Pi 4 Bootloader Configuration <https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711_bootloader_config.md>`_ 需要通过树莓派的官方镜像中工具 ``vcgencmd`` 来检查 eeprom 中配置的bootloader。

使用树莓派官方镜像启动，然后执行::

   vcgencmd bootloader_config

可以看到输出信息::

   [all]
   BOOT_UART=0
   WAKE_ON_GPIO=1
   POWER_OFF_ON_HALT=0
   DHCP_TIMEOUT=45000
   DHCP_REQ_TIMEOUT=4000
   TFTP_FILE_TIMEOUT=30000
   ENABLE_SELF_UPDATE=1
   DISABLE_HDMI=0
   BOOT_ORDER=0xf41

这里 ``BOOT_ORDER=0xf41`` 表示:

- ``0x1`` - SD CARD
- ``0x4`` - USB mass storage boot (since 2020-09-03)
- ``0xf`` - RESTART (loop) - start again with the first boot order field. (since 2020-09-03)

这里的组合 ``0xf41`` 顺序是从右到左，也就是先SD卡，然后USB存储，不断循环。

看起来我使用最新的eeprom没有问题，启动顺序是正确的。

修订eeprom
~~~~~~~~~~~

虽然最新的eeprom版本 (since 2020-09-03) 可以正确从USB外接存储启动(默认配置 ``BOOT_ORDER=0xf41`` )，但是我发现启动后树莓派4即使没有任何运行程序，也始终显示 Load Average 是1。使用 ``top`` 命令可以观察到::

   top - 22:54:18 up 1 day,  5:02,  2 users,  load average: 1.00, 1.00, 1.00
   Tasks: 129 total,   1 running, 128 sleeping,   0 stopped,   0 zombie
   %Cpu(s):  0.1 us,  0.1 sy,  0.0 ni, 99.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
   MiB Mem :   7810.3 total,   7246.5 free,    173.0 used,    390.8 buff/cache
   MiB Swap:      0.0 total,      0.0 free,      0.0 used.   7522.3 avail Mem
   
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
      4079 ubuntu    20   0   10700   3176   2720 R   0.7   0.0   0:00.15 top
      3852 root      20   0       0      0      0 I   0.3   0.0   0:00.10 [kworker/0:1-events]
         1 root      20   0  167624  10796   7336 S   0.0   0.1   0:06.50 /sbin/init fixrtc
         2 root      20   0       0      0      0 S   0.0   0.0   0:00.06 [kthreadd]
         3 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 [rcu_gp]
         4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 [rcu_par_gp]

为何系统没有任何运行进程，但是始终存在Laod Average = 1呢？

原因是系统始终有一个 ``D`` 住的进程(在等待IO)，通过以下命令可以检查系统所有 ``R`` 和 ``D`` 的进程::

   ps -e v | grep -E ' R | D ' | grep -v grep

输出显示D住的系统进程::

   7195 ?        D      0:01      0     0     0     0  0.0 [kworker/2:1+events_freezable]

检查这个D住进程的堆栈，可以看到在等待 ``mmc`` 存储设备(也就是SD卡)::

   [<0>] __switch_to+0x104/0x170
   [<0>] mmc_wait_for_req_done+0x30/0x170
   [<0>] mmc_wait_for_req+0xb0/0x108
   [<0>] mmc_wait_for_cmd+0x7c/0xb0
   [<0>] mmc_io_rw_direct_host+0xa0/0x138
   [<0>] sdio_reset+0x74/0x98
   [<0>] mmc_rescan+0x33c/0x3b8
   [<0>] process_one_work+0x1c0/0x458
   [<0>] worker_thread+0x50/0x428
   [<0>] kthread+0x104/0x130
   [<0>] ret_from_fork+0x10/0x1c

我反复重启了系统，情况相同，每次 ``kworker`` 系统进程都会D住。

联想到启动树莓派时，屏幕提示没有找到SD卡。所以怀疑虽然从USB存储启动，但是eeprom依然发起访问SD卡，由于SD卡缺失，导致IO等待。

解决的思路应该是尝试优先从USB存储启动，如果不行，再尝试只从USB存储启动(关闭从TF卡启动)。

**以下是我处理排查过程**

- 读取当前eeprom配置::

   vcgencmd bootloader_config

输出内容::

   [all]
   BOOT_UART=0
   WAKE_ON_GPIO=1
   POWER_OFF_ON_HALT=0
   DHCP_TIMEOUT=45000
   DHCP_REQ_TIMEOUT=4000
   TFTP_FILE_TIMEOUT=30000
   ENABLE_SELF_UPDATE=1
   DISABLE_HDMI=0
   BOOT_ORDER=0xf41

根据 ``BOOT_ORDER`` 配置，当前启动顺序是先SD卡然后USB存储，不断循环。

- 检查版本::

   vcgencmd bootloader_version

输出::

   Sep  3 2020 13:11:43
   version c305221a6d7e532693cc7ff57fddfc8649def167 (release)
   timestamp 1599135103

- 修改启动顺序 - 参考 `Pi 4 Bootloader Configuration <https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711_bootloader_config.md>`_

- 先将EEPROM镜像从 ``/lib/firmware/raspberrypi/bootloader/`` 目录下复制出来准备修改 ::

   cp /lib/firmware/raspberrypi/bootloader/stable/pieeprom-2020-09-03.bin ./pieeprom.bin

- 导出配置:: 

   rpi-eeprom-config pieeprom.bin > bootconf.txt

- 修改配置 ``bootconf.txt`` 将最后一行::

   BOOT_ORDER=0xf41

修改成(表示先外接USB存储再SD卡)::

   BOOT_ORDER=0xf14

- 将配置修改加入到EEPROM镜像文件::

   rpi-eeprom-config --out pieeprom-new.bin --config bootconf.txt pieeprom.bin

- 然后刷入bootloader EEPROM::

   sudo rpi-eeprom-update -d -f ./pieeprom-new.bin

- 拔掉SD卡，尝试从USB存储启动(优先)

但是，启动以后，发现依然是存在 ``[kworker/1:2+events_freezable]`` 进程D住（是的，启动时终端还是显示mmc没有响应)

我尝试了以下组合:

- 启动顺序 ``0xf14`` ，没有插入TF卡。测试结果：能够从USB存储启动，但是系统依然存在D住的 ``kworker`` 进程在等待 MMC卡返回，依然Load Average持续1。
- 将一块TF卡(可启动raspbian)插，但是我发现依然是优先从TF卡启动。这说明启动顺序 ``0xf14`` 没有效果，依然是 ``0xf41`` 优先从SD开启动。
- 修改成 ``0x14`` 也就是只做一次，先从USB存储启动，然后是TF卡，但不循环。问题依旧存在，然是存在 ``[kworker/1:2+events_freezable]`` 进程D住，Load Average持续1。
- 综上，只要启动顺序中有 ``0x1`` ，即启动顺序中有SD卡，即使从USB存储启动，只要SD卡不存在，就会导致系统进程 ``kworker`` D住等待 MMC 存储返回，系统始终存在 Load Average 1。

最终，我一狠心，将启动顺序改成只从USB存储启动::

   BOOT_ORDER=0x4
   
此时启动时发现，如果不插SD卡，启动自检不过，屏幕提示::

   Failed to open device: 'sdcard' (cmd 371a0010 status 1fff0001)
   Insert SD-CARD

等待一会超时后， 则系统顺利从USB存储启动，而且系统中不再出现 ``kworker`` 进程 ``D`` 住现象。

磁盘分区调整问题
===================

后续我在使用过程中遇到一个异常问题，偶然发现服务器无法登陆，就断电重启了一次。但是发现重启后无法ssh登陆树莓派主机，接上显示器以后发现，启动没有找到根文件系统::

   Begin: Loading essential drivers ... done.
   Begin: Running /scripts/init-premount ... done.
   Begin: Mounting root file system .. Begin: Running /script/local-top ... done
   Begin: Running /scripts/local-premount ...
   ...
   mdadm: No devices listed in conf file were found.
   mdadm: No devices listed in conf file were found.
   done.
   Gave up waiting for root file system device. Common problems:
    - Boot args (cat /proc/cmdline)
      - Check rootdelay= (did the system wait long enough?)
    - Missing modules (cat /proc/modules; ls /dev)
   ALERT! LABEL=writable does not exist.  Dropping to a shell!

   BusyBox v1.30.1 (Ubuntu 1:1.30.1-4ubuntu6.2) built-in shell (ash)
   Enter 'help' for a list of built-in commands.

   (initramfs)

从提示中可以看到，系统启动找不傲标记为 ``LABEL=writalbe`` 的根文件系统。我记得我在将Ubuntu操作系统从TF卡复制到USB外接SSD磁盘时，已经将文件系统中 ``/etc/fstab`` 以及启动 ``cmdline.txt`` 修订成使用 ``PARTUUID`` ，不应该出现查找上述标签的文件系统。实际上 ``LABEL=writalbe`` 是树莓派上安装Ubuntu默认的文件系统分区命名，我已经做过修订为何还会出现。

由于这个SSD磁盘是通过 ``dd`` 命令从TF卡完整复制的，所以分区的label和原先TF卡完全一致。例如，使用 ``lsblk`` 命令可以看到::

   sudo lsblk -o name,mountpoint,label,size,uuid

显示输出::

   NAME        MOUNTPOINT     LABEL         SIZE UUID
   sda                                    953.9G
   ├─sda1                     system-boot   256M B726-57E2
   └─sda2                     writable    953.6G 483efb12-d682-4daf-9b34-6e2f774b56f7
   mmcblk0                                119.1G
   ├─mmcblk0p1 /boot/firmware system-boot   256M B726-57E2
   └─mmcblk0p2 /              writable    118.9G 483efb12-d682-4daf-9b34-6e2f774b56f7

我不知道为何文件系统 ``/dev/sda2`` 文件系统从 128G 扩展到整个磁盘就导致启动时无法读取。

我想到的一个修复方式是重建文件系统，之前通过 ``tar`` 命令没能把系统成功启动，并不是操作系统不能通过 ``tar`` 命令备份和恢复，而是我最初实践时候尚未完全了解树莓派eeprom启动设置导致的。既然我已经通过了eeprom正确设置成功从USB启动，我相信再次通过tar方式完成系统重建也是可行的。

.. note::

   这个重启后无法进入系统的问题，我后来回想了一下，应该是操作系统升级了内核，我没有注意到升级内核以后必须重新用 ``zcat`` 命令将压缩内核解压成 ``vmlinux`` 导致的，所以我再次挑战从tar包clone系统。`

通过tar命令clone系统
======================

.. note::

   操作步骤中有一步有所调整，就是我对磁盘分区的label设置了和默认配置相同的参数，这样，可以免去修改分区相关的配置。

- 对USB外接移动SSD硬盘分区::

   # parted -a optimal /dev/sda
   GNU Parted 3.3
   Using /dev/sda
   Welcome to GNU Parted! Type 'help' to view a list of commands.
   (parted) mklabel gpt
   Warning: The existing disk label on /dev/sda will be destroyed and all data on
   this disk will be lost. Do you want to continue?
   Yes/No? yes
   (parted) print
   Model: WD My Passport 25F3 (scsi)
   Disk /dev/sda: 1024GB
   Sector size (logical/physical): 512B/4096B
   Partition Table: gpt
   Disk Flags:
   
   Number  Start  End  Size  File system  Name  Flags
   
   (parted) mkpart primary fat32 2048s 256M
   (parted) align-check optimal 1
   1 aligned
   (parted) unit s
   (parted) print
   Model: WD My Passport 25F3 (scsi)
   Disk /dev/sda: 2000343040s
   Sector size (logical/physical): 512B/4096B
   Partition Table: gpt
   Disk Flags:
   
   Number  Start  End      Size     File system  Name     Flags
    1      2048s  499711s  497664s  fat32        primary
   
   (parted) mkpart primary ext4 499712 30G
   (parted) print
   Model: WD My Passport 25F3 (scsi)
   Disk /dev/sda: 2000343040s
   Sector size (logical/physical): 512B/4096B
   Partition Table: gpt
   Disk Flags:
   
   Number  Start    End        Size       File system  Name     Flags
    1      2048s    499711s    497664s    fat32        primary
    2      499712s  58593279s  58093568s  ext4         primary
   
   (parted) align-check optimal 2
   2 aligned
   (parted) unit MB
   (parted) set 1 boot on
   (parted) print
   Model: WD My Passport 25F3 (scsi)
   Disk /dev/sda: 1024176MB
   Sector size (logical/physical): 512B/4096B
   Partition Table: gpt
   Disk Flags:
   
   Number  Start   End      Size     File system  Name     Flags
    1      1.05MB  256MB    255MB    fat32        primary  boot, esp
    2      256MB   30000MB  29744MB  ext4         primary
   
   (parted) q
   Information: You may need to update /etc/fstab.

- 格式化磁盘，注意，我这里格式化对分区进行了label，采用的label和原先树莓派默认的label完全一样，以便重建系统后不需要修订分区信息(不需要修改label或PARTUUID)::

   mkfs.vfat /dev/sda1
   fatlabel /dev/sda1 "system-boot"
   mkfs.ext4 /dev/sda2 -L "writable"

- 然后通过 ``lsblk`` 命令检查，确保label和TF卡(mmcblk0)完全一致::

   sudo lsblk -o name,mountpoint,label,size,uuid

输出显示::

   NAME        MOUNTPOINT     LABEL         SIZE UUID
   sda                                    953.9G 
   ├─sda1                     system-boot   243M 85F3-6F6C
   └─sda2                     writable     27.7G 3991189f-1bda-4f0f-b81a-bf46fd05ddfa
   mmcblk0                                119.1G 
   ├─mmcblk0p1 /boot/firmware system-boot   256M B726-57E2
   └─mmcblk0p2 /              writable    118.9G 483efb12-d682-4daf-9b34-6e2f774b56f7

.. note::

   由于SSD移动硬盘所有分区和原先TF卡的对应分区label完全一致，就避免了需要修订磁盘挂载和标识的麻烦。

- 通过tar复制整个系统::

   cd /
   #tar打包系统不包含跨磁盘目录，所以/boot/firmware需要单独复制
   tar -cpzf pi.tar.gz --exclude=/pi.tar.gz --one-file-system /

   mount /dev/sda2 /mnt
   sudo tar -xpzf /pi.tar.gz -C /mnt --numeric-owner
   mount /dev/sda1 /mnt/boot/firmware
   (cd /boot/firmware && tar cf - .)|(cd /mnt/boot/firmware && tar xf -)

- 解压缩内核::

   cd /mnt/boot/firmware
   od -A d -t x1 vmlinuz | grep '1f 8b 08 00'

输出类似::

   0000000 1f 8b 08 00 00 00 00 00 02 03 ec 5c 0d 74 14 d7

使用 ``dd`` 和 ``zcat`` 解压缩内核::

   dd if=vmlinuz bs=1 skip=0000000 | zcat > vmlinux

- 更新 ``config.txt`` 配置设置从解压后内核启动::

   #[pi4]
   #kernel=uboot_rpi_4.bin
   #max_framebuffers=2
   
   #[pi2]
   #kernel=uboot_rpi_2.bin
   
   #[pi3]
   #kernel=uboot_rpi_3.bin
   
   [all]
   arm_64bit=1
   device_tree_address=0x03000000
   kernel=vmlinux
   initramfs initrd.img followkernel

- 下载最新raspberry pi的firmware，将 ``boot`` 目录下 ``.dat`` 和 ``.elf`` 文件复制到 ``/boot/firmware`` 对应目录::

   sudo cp ~/Downloads/boot/*.dat /mnt/boot/firmware
   sudo cp ~/Downloads/boot/*.elf /mnt/boot/firmware 

- 将USB外接SSD移动硬盘连接到树莓派，启动系统，观察Raspberry Pi从USB移动硬盘启动。

**成功**

验证成功:

- 树莓派存储磁盘可以使用GPT分区表
- 不需要使用dd来复制磁盘，使用tar命令也可以复制系统，而且灵活调整磁盘分区大小

参考
======

- `USB Boot Ubuntu Server 20.04 on Raspberry Pi 4 <https://eugenegrechko.com/blog/USB-Boot-Ubuntu-Server-20.04-on-Raspberry-Pi-4>`_ - 这篇文章非常详尽解说了从外接USB存储启动Ubuntu Server for Raspberry Pi的方法，比通过工具无脑操作要更有技术性
- `How to Boot Raspberry Pi 4 From a USB SSD or Flash Drive <https://www.tomshardware.com/how-to/boot-raspberry-pi-4-usb>`_ 采用了 raspi-config 工具来设置Raspberry Pi OS，是树莓派官方解决方案，比较简单傻瓜化，不过只能用于树莓派官方操作系统
- 有关树莓派分区：

  - `booting from a GPT mass storage device <https://www.raspberrypi.org/forums/viewtopic.php?t=205418>`_
  - `Does the Pi support booting from GPT drives? <https://www.raspberrypi.org/forums/viewtopic.php?t=241914>`_
  - `Hybrid MBRs: The Good, the Bad, and the So Ugly You'll Tear Your Eyes Out <https://www.rodsbooks.com/gdisk/hybrid.html>`_ - 详细的Hybrid MBR原理和操作
  - `Gentoo Hybrid partition table <https://wiki.gentoo.org/wiki/Hybrid_partition_table>`_
- 有关磁盘文件系统label参考:
  - `List partition labels from the command line <https://unix.stackexchange.com/questions/14165/list-partition-labels-from-the-command-line>`
  - `How to change the volume name of a FAT32 filesystem? <https://unix.stackexchange.com/questions/44095/how-to-change-the-volume-name-of-a-fat32-filesystem>`
  - `How to name/label a partition or volume on Linux <https://linuxconfig.org/how-to-name-label-a-partition-or-volume-on-linux>`_
