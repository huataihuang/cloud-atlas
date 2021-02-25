.. _usb_boot_jetson:

=======================
使用USB存储启动Jetson
=======================

.. note::

   我现在尚未采购合适的USB外接存储，虽然可以使用普通的USB移动硬盘来提高Jetson的存储性能(SD卡的性能实在太差了)。但是，我依然推荐采用固态存储设备，例如SSD移动硬盘，不过，为了配合移动设备的高效小巧，我非常推荐采用 NVMe SSD 存储通过 M.2 转接 USB方式的U盘。

默认情况下，Jetston Nano和 :ref:`raspberry_pi` 一样，使用TF卡作为存储。但是由于SD/TF卡的读写性能很弱，使得系统性能无法充分发挥。所以，和 :ref:`usb_boot_ubuntu_pi_4` 相似，我也把Jetson Nano的操作系统迁移到移动硬盘上运行(通过USB 3.0接口)。

我的实践是采用USB移动HDD硬盘，虽然性能普通，但是比TF卡运行性能要好很多。 - 为了节约成本，我仅使用了非常普通的TF卡，所以读写性能极弱。

`Jetson Nano – Run From USB Drive <https://www.jetsonhacks.com/2019/09/17/jetson-nano-run-from-usb-drive/>`_ 在GitHub上开源了 `JetsonHacksNano / rootOnUSB <https://github.com/JetsonHacksNano/rootOnUSB>`_ 的脚本，可以方便我们将NVIDIA的Jetson Nano启动rootfs修改成USB设备。


和 :ref:`usb_boot_ubuntu_pi_4` 有所不同，Jetson Nano没有提供从外接存储启动的设置，启动分为两步:

- boot loader从所支持关键连接设备，也就是TF卡启动一个最小支持的内存镜像。这个步骤是通过 ``initrd`` (initial ramdisk) 实现，将一个临时文件系统加载到内存来启动Linux内核。这个步骤我们不做修改，所以我们通过USB存储启动Jetson依然需要TF卡，关键修改是第二步。
- 默认情况下，bootloader从TF卡加载好Linux内核以后，就会配置rootfs指向TF卡中的文件系统，这才是完整的文件系统，也就是我们平时使用操作系统最主要访问的文件系统，对运行性能影响极大。我们改造的就是这步，通过修改配置，将rootfs修改到USB外接磁盘设备上，通过外接磁盘设备来加速Linux文件系统性能。

需要注意的是，要在上述第二步中实现读写USB外接存储，不仅需要Linux内核内建USB驱动(默认已经build in)，而且需要USB设备的firmware。很不幸，USB设备的firmware默认没有加载，所以就无法在启动过程中挂载尚未初始化的USB控制器的外接存储设备上的root文件系统。我们需要重新编译Linux内核来把关键的USB firmware编译到内核中。在 `Jetson Nano Developer Forum帖子解析了构建initramfs方法
<https://forums.developer.nvidia.com/t/jetson-nano-r32-2-1-partuuid-not-working-while-booting-from-usb/81343/9>`_ ，实现将USB firmware添加到initramfs的步骤。

rootOnUSB脚本
================

JetsonHacks提供了 `JetsonHacksNano / rootOnUSB <https://github.com/JetsonHacksNano/rootOnUSB>`_ 脚本方便完成整个迁移过程。通过以下方式获取::

   git clone https://github.com/JetsonHacksNano/rootOnUSB

   cd rootOnUSB

.. note::

   为了能够完整系统掌握这个迁移过程，我的实践操作是通过分析rootOnUSB脚本，通过独立的命令行操作来完成整个步骤。所以本文看上去比较繁琐，但是更容易理解原理。如果你只是需要完成操作，则可以直接执行脚本即可。

构建支持USB的initramfs
=======================

.. note::

   这步可以通过脚本完成::

      ./addUSBToInitramfs.sh

- 创建一个名为 ``usb-firmware`` 脚本如下::

   if [ "$1" = "prereqs" ]; then exit 0; fi
   . /usr/share/initramfs-tools/hook-functions
   copy_file firmware /lib/firmware/tegra21x_xusb_firmware

这里 ``/usr/share/initramfs-tools/hook-functions`` 是initramfs-tools的hook功能脚本，由操作系统提供。这个 ``usb-firmware`` 脚本复制到 ``/etc/initramfs-tools/hooks`` 目录下，然后通过 ``/usr/share/initramfs-tools/hook-functions`` 提供的脚本函数 ``copy_file`` 来复制firmware，再通过 ``mkinitramfs`` 来构建镜像。

- 执行命令::

   cp usb-firmware /etc/initramfs-tools/hooks
   cd /etc/initramfs-tools/hooks
   mkinitramfs -o /boot/initrd-xusb.img

这里有3个报错::

   Warning: couldn't identify filesystem type for fsck hook, ignoring.
   /sbin/ldconfig.real: Warning: ignoring configuration file that cannot be opened: /etc/ld.so.conf.d/aarch64-linux-gnu_EGL.conf: No such file or directory
   /sbin/ldconfig.real: Warning: ignoring configuration file that cannot be opened: /etc/ld.so.conf.d/aarch64-linux-gnu_GL.conf: No such file or directory

我检查了一下，实际上配置文件存在::

   /etc/ld.so.conf.d/aarch64-linux-gnu_EGL.conf -> /etc/alternatives/aarch64-linux-gnu_egl_conf
   /etc/ld.so.conf.d/aarch64-linux-gnu_GL.conf -> /etc/alternatives/aarch64-linux-gnu_gl_conf

不过都是软链接，最终分别链接到::

   /usr/lib/aarch64-linux-gnu/tegra-egl/ld.so.conf
   /usr/lib/aarch64-linux-gnu/tegra/ld.so.conf

所以通过以下命令先复制成实际文件，处理完以后再恢复之前的软链接::

   unlink /etc/ld.so.conf.d/aarch64-linux-gnu_EGL.conf
   cp /usr/lib/aarch64-linux-gnu/tegra-egl/ld.so.conf /etc/ld.so.conf.d/aarch64-linux-gnu_EGL.conf

   unlink /etc/ld.so.conf.d/aarch64-linux-gnu_GL.conf
   cp /usr/lib/aarch64-linux-gnu/tegra/ld.so.conf /etc/ld.so.conf.d/aarch64-linux-gnu_GL.conf

上述 ``Warning: couldn't identify filesystem type for fsck hook`` 是因为 ``mkinitramfs`` 是通过 ``/etc/fstab`` 来检测文件系统的。 参考 `UPDATE-INITRAMFS FAILS TO INCLUDE FSCK IN INITRD <https://isolated.site/2019/02/17/update-initramfs-fails-to-include-fsck-in-initrd/>`_ 我检查了 ``/etc/fstab`` 内容是::

   /dev/root            /                     ext4           defaults                                     0 1

实际上并没有设备 ``/dev/root`` ，Jetson Nano挂载根文件系统没有使用这个配置，通过 ``cat /proc/mounts`` 可以看到根挂载是::

   /dev/mmcblk0p1 / ext4 rw,relatime,data=ordered 0 0

所以我暂时修改 ``/etc/fstab`` 如下::

   /dev/mmcblk0p1        /                     ext4           defaults                                     0 1

再次执行就不再报错::

   mkinitramfs -o /boot/initrd-xusb.img

完成以后，恢复 ``/etc/fstab`` 配置，然后执行以下命令恢复文件软链接::

   rm -f /etc/ld.so.conf.d/aarch64-linux-gnu_EGL.conf
   ln -s /etc/alternatives/aarch64-linux-gnu_egl_conf /etc/ld.so.conf.d/aarch64-linux-gnu_EGL.conf

   rm -f /etc/ld.so.conf.d/aarch64-linux-gnu_GL.conf
   ln -s /etc/alternatives/aarch64-linux-gnu_gl_conf /etc/ld.so.conf.d/aarch64-linux-gnu_GL.conf

USB移动硬盘准备
=================

- 格式化移动硬盘

USB移动硬盘需要建立一个 ``ext4`` 分区，用于存储rootfs。注意，该分区必须是ext4文件系统。我的移动磁盘在Linux下识别名字是 ``/dev/sda`` ，你的设备名字可能不同::

   fdisk /dev/sda

我划分了 128G 给 ``/dev/sda1`` 用于操作系统::

   Disk /dev/sda: 465.8 GiB, 500107862016 bytes, 976773168 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
   Disklabel type: dos
   Disk identifier: 0x5e878358

   Device     Boot Start       End   Sectors  Size Id Type
   /dev/sda1        2048 268437503 268435456  128G 83 Linux

   Filesystem/RAID signature on partition 1 will be wiped.

创建ext4文件系统::

   mkfs.ext4 /dev/sda1

复制Jetson操作系统
======================

.. note::

   简单执行脚本::

      ./copyRootToUSB.sh -p /dev/sda1

   或者像我一样用命令行完成，见下文。

- 将移动硬盘连接到Jetson Nano上，然后执行命令::

   sudo mount /dev/sda1 /mnt

- 检查挂载::

   sudo findmnt -rno TARGET /dev/sda1

可以看到输出信息::

   /media/78961b21-c52a-4aa2-ac83-c5fc757f6666
   /mnt

- 同步数据::

   sudo rsync -axHAWX --numeric-ids --info=progress2 --exclude=/proc / /mnt

``rsync`` 参数解析:

  - ``-a``

.. note::

   注意，由于Jetson Nano当前只有一个TF卡，所以首次插入移动硬盘识别为 ``/dev/sda`` 设备，所以上述命令我的目标磁盘分区是 ``/dev/sda1``

修改启动配置
==============

Jetson Nano启动配置是 ``/boot/extlinux/extlinux.conf`` ，其中有一个入口就是指向 rootfs ，我们需要修改成移动硬盘::

   cp /boot/extlinux/extlinux.conf /boot/extlinux/extlinux.conf.bak

- 检查移动硬盘分区的UUID，这个UUID需要配置到启动配置中::

   find /dev/disk/by-uuid -lname '*/'sda1 -printf %f

输出类似::

   78961b21-c52a-4aa2-ac83-c5fc757f6666

也可以通过 

参考
======

- `Jetson Nano – Run From USB Drive <https://www.jetsonhacks.com/2019/09/17/jetson-nano-run-from-usb-drive/>`_
