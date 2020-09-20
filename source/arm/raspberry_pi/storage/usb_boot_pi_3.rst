.. _usb_boot_pi_3:

===============================
USB移动存储启动和运行树莓派3
===============================

.. note::

   本文实践是在 :ref:`pi_3` 结合USB转接卡，使用 2.5寸 笔记本硬盘构建的。后续我准备再使用 :ref:`pi_4` 结合USB SSD移动硬盘来构建 :ref:`pi_cluster` 。 

   注意，最初我的实践是在树莓派官方32位raspbian系统上实践的，最近为了构建 :ref:`pi_cluster` 运行 :ref:`kubernetes` ，我改为使用64位Ubuntu系统。Ubuntu for Raspberry Pi和官方Raspbian在bootloader上有点差异，详见文章最后部分。

设置USB启动模式
================

在设置树莓派3能够从磁盘启动之前，它首先需要从SD卡启动并配置激活USB启动模式。这个过程是通过在树莓派SoC的OTP(One Time Programmable)内存设置一个激活从USB存储设备启动的。

.. note::

   一旦这个位设置，就不再需要SD卡。但是要注意：任何修改OTP都是永久的，不能撤销。

激活USB存储启动
=================

- 通过更新准备 ``/boot`` 目录::

   sudo apt update && sudo apt upgrade

- 使用以下命令激活USB启动模式::

   echo program_usb_boot_mode=1 | sudo tee -a /boot/config.txt

以上命令在 ``/boot/config.txt`` 中添加了 ``program_usb_boot_mode=1`` 。

使用 ``sudo reboot`` 命令重启树莓派，然后检查OTP是否已经设置成可编程::

   vcgencmd otp_dump | grep 17:

确保输出是 ``17:3020000a`` 。如果不是这个输出值，责表示OTP还没有成功设置为可编程。

- 然后就可以从 ``config.txt`` 最后删除掉 ``program_usb_boot_mode`` ，这样你把这个SD卡插到其他树莓派上不会导致其进入USB启动模式。

.. note::

   确保 ``config.txt`` 配置文件最后没有空白行。

USB存储设备
=============

从 ``2017-04-10`` 版本开始，可以通过复制方式将操作系统镜像直接安装到USB存储器。这种方式也可以针对一个SD卡。

由于我们已经在[树莓派快速起步](raspberry_pi_quick_start)过程中在SD卡上安装了Raspbian，现在我们可以从已经安装了系统的SD卡中直接复制到磁盘中，就可以保留原先所有做过的更改。

这个过程和从Raspbian镜像复制到SD卡相似，只是需要注意磁盘的命令，一定要确保是从SD卡复制到磁盘。

- ``/dev/mmcblk0``   SD卡
- ``/dev/sda``       USB接口的磁盘

.. note::

   目前我部署 :ref:`pi_cluster` 采用64位操作系统，设备是 :ref:`pi_4` 和 :ref:`pi_3` 。实际上Ubuntu提供的64位ARM操作系统是一个版本，可以同时用于树莓派3和4。

   我首次安装64位操作系统是在树莓派4上，完成后，我将采用本方案clone到树莓派3上组建集群。

- Raspberry Pi 4安装的64位Ubuntu分区如下::

   Disk /dev/mmcblk0: 119.9 GiB, 127865454592 bytes, 249737216 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: dos
   Disk identifier: 0xab86aefd
   
   Device         Boot  Start       End   Sectors   Size Id Type
   /dev/mmcblk0p1 *      2048    526335    524288   256M  c W95 FAT32 (LBA)
   /dev/mmcblk0p2      526336 249737182 249210847 118.9G 83 Linux

- 划分USB磁盘分区

对照TF卡上的当前树莓派操作系统分区，可以看到有2个分区，一个是FAT32分区，另一个是Linux分区，我们也需要对应在USB磁盘上完成这个划分。

使用 ``parted`` 划分分区::

   # parted -a optimal /dev/sda
   GNU Parted 3.3
   Using /dev/sda
   Welcome to GNU Parted! Type 'help' to view a list of commands.
   (parted) rm 2
   (parted) rm 1
   (parted) mkpart primary fat32 2048s 256M
   (parted) align-check optimal 1
   1 aligned
   (parted) unit s
   (parted) print
   Model: External USB3.0 (scsi)
   Disk /dev/sda: 976773168s
   Sector size (logical/physical): 512B/4096B
   Partition Table: msdos
   Disk Flags:
   
   Number  Start  End      Size     Type     File system  Flags
    1      2048s  499711s  497664s  primary  fat32        lba
   
   (parted) mkpart primary ext4 499712 30G
   (parted) print
   Model: External USB3.0 (scsi)
   Disk /dev/sda: 976773168s
   Sector size (logical/physical): 512B/4096B
   Partition Table: msdos
   Disk Flags:
   
   Number  Start    End        Size       Type     File system  Flags
    1      2048s    499711s    497664s    primary  fat32        lba
    2      499712s  58593279s  58093568s  primary  ext4         lba
   
   (parted) align-check optimal 2
   2 aligned
   (parted) unit MB
   (parted) print
   Model: External USB3.0 (scsi)
   Disk /dev/sda: 500108MB
   Sector size (logical/physical): 512B/4096B
   Partition Table: msdos
   Disk Flags:
   
   Number  Start   End      Size     Type     File system  Flags
    1      1.05MB  256MB    255MB    primary  fat32        lba
    2      256MB   30000MB  29744MB  primary  ext4         lba
   
   (parted) q
   Information: You may need to update /etc/fstab.

.. note::

   4k对齐参考 `How to align partitions for best performance using parted <https://rainbow.chard.org/2013/01/30/how-to-align-partitions-for-best-performance-using-parted/>`_ ，其中参数查看 ``/dev/sda`` ，所以第一个分区起始扇区选择 ``2048s`` ::

      # cat /sys/block/sda/queue/optimal_io_size
      0
      # cat /sys/block/sda/queue/minimum_io_size
      512
      # cat /sys/block/sda/alignment_offset
      0
      # cat /sys/block/sda/queue/physical_block_size
      512

   注意：这里划分 ``/dev/sda2`` 只分配30G给操作系统使用，因为我准备把剩余的空间作为存储空间，将在后续使用卷管理来维护，并构建Ceph和GlusterFS存储。

- 退出 ``parted`` 检查存储的 ``PARTUUID`` ::

   # blkid /dev/sda
   /dev/sda: PTUUID="5e878358" PTTYPE="dos"
   # blkid /dev/sda1
   /dev/sda1: SEC_TYPE="msdos" UUID="1E2C-FFAE" TYPE="vfat" PARTUUID="5e878358-01"
   # blkid /dev/sda2
   /dev/sda2: PARTUUID="5e878358-02"


注意，此时看不到 ``UUID`` ， ``UUID``  在 ``mkfs.ext4 /dev/sda2`` 之后就会标记上。

和普通的PC不同，树莓派会默认尝试搜索可以启动的分区（默认会从SD卡启动，15秒之后将尝试从USB存储启动，即前面修改的配置）。

.. note::

   一定要有一个fat分区用于存放 ``/boot`` 分区内容，因为UEFI启动默认会寻找vfat分区内容来启动。

.. note::

   - 如果使用 ``dd`` 命令复制磁盘分区，所以要确保 ``/dev/sda2`` 磁盘分区大于源SD卡分区 ``/dev/mmcblk0p2`` 
   - 如果使用 ``tar`` 方式复制磁盘文件系统，则目标分区只要能够容纳源 ``/dev/mmcblk0p2`` 文件就可以 - 我采用的是这个方法

通过 dd 复制磁盘（我没有采用这个方法）
---------------------------------------

如果使用 ``dd`` 复制磁盘，责执行操作系统复制命令如下（不需要区分磁盘分区）::

   dd if=/dev/mmcblk0 of=/dev/sda conv=fsync

.. note::

   ``dd`` 复制命令参考了在Linux中制作镜像到SD卡的命令 `INSTALLING OPERATING SYSTEM IMAGES ON LINUX <https://www.raspberrypi.org/documentation/installation/installing-images/linux.md>`_

通过 tar 复制磁盘
-------------------

- 使用 ``tar`` 方式复制磁盘文件::

   cd /
   tar -cpzf pi.tar.gz --exclude=/pi.tar.gz --one-file-system /

   mkfs.ext4 /dev/sda2
   mount /dev/sda2 /mnt

   sudo tar -xpzf /pi.tar.gz -C /mnt --numeric-owner

.. note::

   上述备份的 ``/pi.tar.gz`` 没有包含 ``/boot`` 分区内容，所以后面我们还有一步单独复制 ``/boot`` 分区的操作。

.. note::

   在执行了 ``mkfs.ext4 /dev/sda2`` 之后，再使用 ``blkid /dev/sda2`` 就能够看到 ``UUID`` ，这个 ``UUID`` 是文件系统UUID::

      blkid /dev/sda2

   显示输出::

      /dev/sda2: UUID="b2e461e7-5a68-434d-bda1-c7c137e8c38e" TYPE="ext4" PARTUUID="1a99ca08-02"

- 格式化 ``/dev/sda1`` 作为vfat32 分区::

   # mkfs.vfat /dev/sda1  <= 这里没有指定FAT32文件系统，默认格式化是FAT16
   # 检查发现`fdisk`虽然可以通过`c`这个type来标记分区为FAT32，但是如果`mkfs.fat`不指定`-F32`参数
   # 会导致文件系统还是`fat16`文件系统，虽然用`fdisk -l`看不出，但是`parted`则能够看到是`fat16`
   mkfs.fat -F32 /dev/sda1

- 早期的32位系统可以通过以下命令复制 ``/boot`` 分区::

   mount /dev/sda1 /mnt/boot
   (cd /boot && tar cf - .)|(cd /mnt/boot && tar xf -)

- 但是现在64位操作系统 ``/dev/sda1`` 已经不是直接挂载为 ``/boot`` 目录，检查对比TF卡中操作系统可以看到::

   # df -h
   Filesystem      Size  Used Avail Use% Mounted on
   ...
   /dev/mmcblk0p2  117G  3.5G  109G   4% /
   ...
   /dev/mmcblk0p1  253M   97M  156M  39% /boot/firmware

所以对应挂载目录不同，我们采用以下命令::

   mount /dev/sda1 /mnt/boot/firmware
   (cd /boot/firmware && tar cf - .)|(cd /mnt/boot/firmware && tar xf -)

.. note::

   要避免包含目录，使用 ``--exclude`` 参数。参考 `Exclude Multiple Directories When Creating A tar Archive <https://www.question-defense.com/2012/06/13/exclude-multiple-directories-when-creating-a-tar-archive>`_ 。但是我使用如下命令依然包含了不需要的目录（ **失败** ），最后还是采用 :ref:`recover_system_by_tar` 来完成::

      (cd / && tar cf - --exclude "/mnt" --exclude "/sys" --exclude "/proc" --exclude "/lost+found" --exclude "/tmp" .)|(cd /mnt && tar xf -)

配置修改
===========

.. note::

   注意：除非使用 ``dd`` 来复制SD卡到HDD才能保持原有的 ``PARTUUID`` ，否则使用 ``parted`` 划分分区以及使用 ``mkfs`` 创建文件系统，都会使得目标磁盘的 ``UUID`` 和 ``PARTUUID`` 变化。则需要修改启动配置文件反映分区标识的变化。

- 检查当前SD卡的分区UUID，例如如下::

   $ sudo blkid /dev/mmcblk0p1
   /dev/mmcblk0p1: LABEL="boot" UUID="CDD4-B453" TYPE="vfat" PARTUUID="5e878358-01"
   
   $ sudo blkid /dev/mmcblk0p2
   /dev/mmcblk0p2: LABEL="rootfs" UUID="72bfc10d-73ec-4d9e-a54a-1cc507ee7ed2" TYPE="ext4" PARTUUID="5e878358-02"

   $ sudo blkid /dev/mmcblk0
   /dev/mmcblk0: PTUUID="5e878358" PTTYPE="dos"

note::

   ``/dev/mmcblk0`` 使用 ``parted`` 检查显示是 ``msdos`` 分区表，但是使用 ``blkid`` 检查可以看到具有 ``PARTUUID`` 。参考 `Persistent block device naming <https://wiki.archlinux.org/index.php/persistent_block_device_naming>`_ ，原文介绍 ``GPT`` 分区表支持 ``PARTUUID`` 。不过，我实践发现树莓派默认安装的系统使用的是 ``msdos`` 分区表，但是也具有 ``PARTUUID`` 。测试验证发现，通过使用 ``parted`` 划分磁盘分区就会有 ``PARTUUID`` 。

以下是 ``/dev/mmcblk0`` 在 ``parted`` 中 ``print`` 输出::

   GNU Parted 3.3
   Using /dev/mmcblk0
   Welcome to GNU Parted! Type 'help' to view a list of commands.
   (parted) print
   Model: SD SN128 (sd/mmc)
   Disk /dev/mmcblk0: 128GB
   Sector size (logical/physical): 512B/512B
   Partition Table: msdos
   Disk Flags:
   
   Number  Start   End    Size   Type     File system  Flags
    1      1049kB  269MB  268MB  primary  fat32        boot, lba
    2      269MB   128GB  128GB  primary  ext4

上述可以看到

| 分区 | PARTUUID |
| `/dev/mmcblk0p1` | `5e878358-01` |
| `/dev/mmcblk0p2` | `5e878358-02` |

如果使用 ``dd`` 命令来复制磁盘分区，则HDD磁盘的 ``/dev/sda1`` 和 ``/dev/sda2`` 的 ``PARTUUID`` 会和原先的TF卡完全相同，即依然保持 ``5e878358-01`` 和 ``5e878358-02`` 。这样就不用修改HDD文件系统中的配置。

但是通过磁盘 ``parted`` 和 ``mkfs.ext4`` 创建的HDD文件系统，然后再通过 ``tar`` 恢复操作系统。此时磁盘 ``PARTUUID`` 和 ``UUID`` 不同，则要修改对应配置 ``/boot/cmdline.txt`` 和 ``/etc/fstab`` ::

   # blkid /dev/sda1
   /dev/sda1: UUID="CB15-2042" TYPE="vfat" PARTUUID="5e878358-01"
   # blkid /dev/sda2
   /dev/sda2: UUID="d11f9da5-aeee-477f-9d95-d290c6f56267" TYPE="ext4" PARTUUID="5e878358-02"

32位操作系统启动配置
---------------------

.. note::

   以下32位操作系统配置方法是我之前的记录整理，当前实践是64位操作系统，方法不同。

- 检查 ``/boot/cmdline.txt`` 配置文件，可以看到原先配置内容如下::

   $ cat cmdline.txt
   dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=PARTUUID=5e878358-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait

这里可以看到 ``root=PARTUUID=5e878358-02`` 就是SD卡的分区 ``/dev/mmcblk0p2`` 对应的 ``PARTUUID="5e878358-02"``

- 根据前述检查USB磁盘的分区 ``UUID`` ，即 ``e3f5b3fb-297c-44fe-b763-566b51b87524`` ，注意，我们要将启动指向分区 ``/dev/sda2`` ，因为这个分区就是从 ``/dev/mmcblk0p2`` 通过 ``tar`` 方式复制出来的。修改 ``/mnt/boot/cmdline.txt`` （该文件位于 ``/dev/sda2`` 这个HDD分区文件系统中）::

   dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=PARTUUID=1a99ca08-02 rootfstype=ext4 elevator=cfq fsck.repair=yes rootwait

.. note::

   这里修改了2个地方：
   
   - ``root=PARTUUID=e3f5b3fb-297c-44fe-b763-566b51b87524`` 指向HDD磁盘分区 ``/dev/sda2`` 表示从USB外接的硬盘启动
   - ``evevator=cfq`` 是修改原先针对SSD/SDCARD/TFCARD这类固态硬盘优化参数 ``deadline`` ，由于使用机械硬盘针对HDD硬盘优化参数修改成 ``cfq`` 

- 修改 ``/mnt/etc/fstab`` 配置文件，修改 ``/`` 行中 ``PARTUUID`` 内容::

   proc            /proc           proc    defaults          0       0
   PARTUUID=5e878358-01  /boot           vfat    defaults          0       2
   PARTUUID=5e878358-02  /               ext4    defaults,noatime  0       1

- 关机，然后取出TF卡，再次加电，此时树莓派将从外接USB的HDD磁盘启动

.. note::

   测试下来，如果再次使用TF卡，依然能够优先从TF卡启动树莓派。只有TF卡不可用时候，才会从USB HDD启动。

64位Ubuntu启动修改
----------------------

Ubuntu镜像使用 u-boot 作为bootloader，而树莓派内建的bootloader可以使用在 ``system-boot`` 分区的config.txt文件的一些修改。

64位Ubuntu操作系统 ``/boot`` 目录并没有独立建立分区，而是在 ``/boot/firmware`` 目录单独建立vfat32分区，并且这个分区是可启动分区。

对于2017年4月以后的系统，必须具备bootloader文件，所以需要获得最新的 bootcode.bin, fixup.dat 和 start.elf 并复制到 ``system-boot`` 分区。另外，Ubuntu的u-boot脚本硬编码了使用SD卡启动，所以需要修改bootloader，采用树莓派的bootloader才能够从USB磁盘启动。

解压缩内核
~~~~~~~~~~~~~

.. warning::

   每次Ubuntu升级内核都需要重复这个步骤。

首先我们需要把 ``vmlinuz`` 解压缩成 ``vmlinux`` ，这是因为当前还不支持从压缩的 64位 arm 内核启动

- 找出内核镜像的gziped内容位置::

   od -A d -t x1 vmlinuz | grep '1f 8b 08 00'

输出内容::

   0000000 1f 8b 08 00 00 00 00 00 02 03 ec 5c 0f 74 54 e

这里第一个 ``0000000`` 数字就是我们查找的位置，在这个位置右边就是镜像起点。

- 使用 ``dd`` 命令输出数据并使用 ``zcat`` 解压缩。如果你看到的数字不是 ``0000000`` ，就用你看到的数字作为 ``skip=`` 参数::

   dd if=vmlinuz bs=1 skip=0000000 | zcat > vmlinux

修改bootloader
~~~~~~~~~~~~~~~~~

- 查看 ``/mnt/boot/firmware/config.txt`` (也就是USB硬盘分区 ``/dev/sda1`` 挂载后的配置文件) ，默认内容是针对不同树莓派的启动配置。注意，在配置文件开头说明建议不要直接修改 ``config.txt`` ，而是应该修改 ``usercfg.txt`` 来包含用户修改::

   [pi4]
   kernel=uboot_rpi_4.bin
   max_framebuffers=2

   [pi2]
   kernel=uboot_rpi_2.bin

   [pi3]
   kernel=uboot_rpi_3.bin

   [all]
   arm_64bit=1
   device_tree_address=0x03000000

   enable_uart=1
   cmdline=cmdline.txt

   include syscfg.txt
   include usercfg.txt

按照Ubuntu文档，需要将修改成::

   kernel=vmlinuz
   initramfs initrd.img followkernel
   #device_tree_address=0x03000000

所以我实际修改 ``config.txt`` 内容如下::

   [pi4]
   #kernel=uboot_rpi_4.bin
   #max_framebuffers=2

   [pi2]
   #kernel=uboot_rpi_2.bin

   [pi3]
   #kernel=uboot_rpi_3.bin

   [all]
   arm_64bit=1
   device_tree_address=0x03000000
   kernel=vmlinux
   initramfs initrd.img followkernel

更新.dat和.elf文件
~~~~~~~~~~~~~~~~~~~~

- 检查 ``/mnt/boot`` 目录下内容，可以看到 ``dtbs`` 目录因为我最初是安装的树莓派4系统，所以 ``dtb`` 软链接都是只想树莓派4，这部分需要手工修改。

不过我发现使用树莓派4的TF卡插入到树莓派3上能够正常启动

以下是当前 ``/mnt/boot`` 下内容，如果有必要我准备手工修改 ``dtb`` 软链接::

   # ls -lh
   total 81M
   -rw------- 1 root root 4.0M Jul 10 05:18 System.map-5.4.0-1015-raspi
   -rw------- 1 root root 4.0M Sep  5 01:03 System.map-5.4.0-1018-raspi
   -rw-r--r-- 1 root root 216K Jul 10 05:18 config-5.4.0-1015-raspi
   -rw-r--r-- 1 root root 216K Sep  5 01:03 config-5.4.0-1018-raspi
   lrwxrwxrwx 1 root root   43 Sep 18 12:53 dtb -> dtbs/5.4.0-1018-raspi/./bcm2711-rpi-4-b.dtb
   lrwxrwxrwx 1 root root   43 Sep 12 06:07 dtb-5.4.0-1015-raspi -> dtbs/5.4.0-1015-raspi/./bcm2711-rpi-4-b.dtb
   lrwxrwxrwx 1 root root   43 Sep 18 12:53 dtb-5.4.0-1018-raspi -> dtbs/5.4.0-1018-raspi/./bcm2711-rpi-4-b.dtb
   drwxr-xr-x 4 root root 4.0K Sep 12 06:08 dtbs
   drwxr-xr-x 5 root root 5.0K Jan  1  1970 firmware
   lrwxrwxrwx 1 root root   27 Sep 12 06:06 initrd.img -> initrd.img-5.4.0-1018-raspi
   -rw-r--r-- 1 root root  29M Sep 12 06:07 initrd.img-5.4.0-1015-raspi
   -rw-r--r-- 1 root root  29M Sep 18 12:53 initrd.img-5.4.0-1018-raspi
   lrwxrwxrwx 1 root root   27 Jul 31 16:44 initrd.img.old -> initrd.img-5.4.0-1015-raspi
   lrwxrwxrwx 1 root root   24 Sep 12 06:06 vmlinuz -> vmlinuz-5.4.0-1018-raspi
   -rw------- 1 root root 8.1M Jul 10 05:18 vmlinuz-5.4.0-1015-raspi
   -rw------- 1 root root 8.1M Sep  5 01:03 vmlinuz-5.4.0-1018-raspi
   lrwxrwxrwx 1 root root   24 Jul 31 16:44 vmlinuz.old -> vmlinuz-5.4.0-1015-raspi

以下是复制树莓派3的dtb文件并建立软链接步骤::

   cd /mnt/boot/dtbs/5.4.0-1018-raspi
   cp /lib/firmware/5.4.0-1018-raspi/device-tree/broadcom/bcm2837-rpi-3-b.dtb ./
   cd /mnt/boot/dtbs/5.4.0-1015-raspi
   cp /lib/firmware/5.4.0-1015-raspi/device-tree/broadcom/bcm2837-rpi-3-b.dtb ./

   cd /mnt/boot
   unlink dtb
   ln -s dtbs/5.4.0-1018-raspi/./bcm2837-rpi-3-b.dtb ./dtb
   unlink dtb-5.4.0-1015-raspi
   ln -s dtbs/5.4.0-1015-raspi/./bcm2837-rpi-3-b.dtb ./dtb-5.4.0-1015-raspi
   unlink dtb-5.4.0-1018-raspi
   ln -s dtbs/5.4.0-1018-raspi/./bcm2837-rpi-3-b.dtb ./dtb-5.4.0-1018-raspi

.. note::

   不过我执行了上述软链接修正，在树莓派3上依然不能从USB磁盘启动。从 `USB Boot Ubuntu Server 20.04 on Raspberry Pi 4 <https://eugenegrechko.com/blog/USB-Boot-Ubuntu-Server-20.04-on-Raspberry-Pi-4>`_ 来看，可能需要更新最新的 `raspberrypi/firmware <https://github.com/raspberrypi/firmware/tree/master/boot>`_

- 重新开始，从 `raspberrypi/firmware <https://github.com/raspberrypi/firmware/tree/master/boot>`_ 下载最新版本的 .dat 和 .elf 文件

然后复制到 ``/mnt/boot/firmware`` 目录下覆盖原文件::

   cd /mnt/boot/firmware
   cp ~/Downloads/firmware-/boot/*.dat ./
   cp ~/Downloads/firmware-/boot/*.elf .

.. note::

   这步待验证

修改bootloader
~~~~~~~~~~~~~~~~

- 修改 ``/mnt/boot/firmware/cmdline.txt`` 

将 ``cmdline.txt`` ::

   net.ifnames=0 dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=LABEL=writable rootfstype=ext4 elevator=deadline rootwait fixrtc

原先记录是 ``root=LABEL=writable`` 实际上就是SD卡的原先的 ``/dev/mmcblk0p2`` (分区2) 的文件系统LABEL名字(我觉得其实格式化移动硬盘也加上这个标签，或许不需要再修订 ``cmdline.txt`` 配置) 。我现在修改成USB移动硬盘分区的PARTUUID。

另外还修改一个针对机械硬盘优化参数 ``elevator=cfq`` 。

完整修订如下::

   net.ifnames=0 dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=PARTUUID=5e878358-02 rootfstype=ext4 elevator=cfq rootwait fixrtc
   
分区
~~~~~~~~~~~~~~

参考原先SD卡的分区标记，在 ``/dev/sda1`` 上加上启动标记::

   # parted /dev/sda
   GNU Parted 3.3
   Using /dev/sda
   Welcome to GNU Parted! Type 'help' to view a list of commands.
   (parted) print
   Model: External USB3.0 (scsi)
   Disk /dev/sda: 500GB
   Sector size (logical/physical): 512B/4096B
   Partition Table: msdos
   Disk Flags:
   
   Number  Start   End     Size    Type     File system  Flags
    1      1049kB  256MB   255MB   primary  fat32        lba
    2      256MB   30.0GB  29.7GB  primary  ext4
   
   (parted) set 1 boot on
   (parted) print
   Model: External USB3.0 (scsi)
   Disk /dev/sda: 500GB
   Sector size (logical/physical): 512B/4096B
   Partition Table: msdos
   Disk Flags:
   
   Number  Start   End     Size    Type     File system  Flags
    1      1049kB  256MB   255MB   primary  fat32        boot, lba
    2      256MB   30.0GB  29.7GB  primary  ext4
   
   (parted) quit
   Information: You may need to update /etc/fstab.

- 修改 ``/mnt/etc/fstab`` 配置，对应磁盘分区的PARTID::

   PARTUUID="5e878358-02"  /        ext4   defaults        0 0
   PARTUUID="5e878358-01"  /boot/firmware  vfat    defaults        0       1

.. note::

   我现在暂时还没有解决Raspberry Pi 3从USB存储启动Ubuntu Server 64bit for Raspberry Pi系统，似乎是需要更新firmware来解决。

   不过这两天感觉有点瓶颈(疲倦)，先放下，等过两天解决 :ref:`usb_boot_ubuntu_pi_4` 之后再会过来处理。

参考
======

- `Raspberry Pi: Adding an SSD drive to the Pi-Desktop kit <http://www.zdnet.com/article/raspberry-pi-adding-an-ssd-drive-to-the-pi-desktop-kit/>`_
- `HOW TO BOOT FROM A USB MASS STORAGE DEVICE ON A RASPBERRY PI 3 <https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/msd.md>`_
- `Ubuntu wiki - RaspberryPi USB booting <https://wiki.ubuntu.com/ARM/RaspberryPi#USB_booting>`_
- `USB Boot Ubuntu Server 20.04 on Raspberry Pi 4 <https://eugenegrechko.com/blog/USB-Boot-Ubuntu-Server-20.04-on-Raspberry-Pi-4>`_
