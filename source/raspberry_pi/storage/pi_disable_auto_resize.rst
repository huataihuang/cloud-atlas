.. _pi_disable_auto_resize:

==========================================
树莓派关闭自动resize根文件系统(首次启动)
==========================================

在使用 :ref:`raspberry_pi` 和 :ref:`ubuntu64bit_pi` 时，你会发现当系统启动时，会自动把根文件系统扩展成占用整个磁盘系统。

这对我部署 :ref:`gluster` 和 :ref:`ceph` 不利，因为我需要自定义文件系统，准备独立的存储卷给存储服务使用。

.. note::

   可能首次镜像安装以后，需要删除掉 ``/.first_boot`` 标记文件，避免第一次启动自动扩展文件系统。

在 Ubuntu for Raspbery Pi 系统中，采用 :ref:`disable_cloud_init` 方法禁止 :ref:`cloud_init` 就可以关闭自动扩展，或者修改 ``cloud-init`` 配置关闭自动扩展。

注意，本文实践是在 :ref:`pi_quick_start` 基础上完成，也就是说，我是将磁盘挂载到一个已经运行 :ref:`raspberry_pi_os` 的树莓派上，通过 ``chroot`` 实现切换到磁盘上操作系统进行修订的(以便能够修改磁盘的系统 :ref:`initramfs` ):

.. literalinclude:: ../startup/pi_quick_start/mount
   :caption: 挂载树莓派Linux分区

.. literalinclude:: ../startup/pi_quick_start/chroot
   :caption: 采用 chroot 方式切换到树莓派系统

resize逻辑
=============

.. note::

   树莓派的首次启动自动调整分区和文件系统大小的方法已经做过多次修改:

   - 早期的树莓派是通过 ``/boot/cmdline.txt`` 来调用 ``/usr/lib/raspi-config/init_resize.sh`` 脚本调整的
   - 现代树莓派基于Debian 12，采用了 :ref:`initramfs` 脚本调整分区(此时文件系统不挂载)，然后挂载文件系统后，通过 ``/etc/init.d/resize2fs_once`` 再完成 :ref:`expend_ext4_rootfs_online`

树莓派的resize步骤分为分区resize和文件系统resize，但是分布在不同的脚本中

resize分区
------------

- 分区resize是由 ``initramfs`` 调用脚本 ``/usr/share/initramfs-tools/scripts/local-premount/firstboot``

.. literalinclude:: pi_disable_auto_resize/firstboot
   :language: bash
   :caption: ``initramfs`` 调用 ``/usr/share/initramfs-tools/scripts/local-premount/firstboot`` 脚本实现分区resize
   :emphasize-lines: 27,34

所以修订 ``firstboot`` 脚本 ``TARGET_END`` 变量指定自己期望扩展的大小即可

注意，由于是 :ref:`initramfs` 调用脚本，所以需要通过 ``initramfs-tools`` 工具重新制作 initramfs 镜像

resize文件系统
----------------

- 文件系统resize是由 ``/etc/init.d/resize2fs_once`` 完成，如其文件名，这个脚本只在首次启动时调用一次，并且执行后会把自己从系统中删除(以确保不再执行):

.. literalinclude:: pi_disable_auto_resize/resize2fs_once
   :language: bash
   :emphasize-lines: 16-18

修改
======

我在 :ref:`edge_cloud_infra` 部署时，规划给树莓派工作节点1T存储空间:

- 128G空间用于操作系统
- 剩余空间(大约850G)用于构建 :ref:`ceph` 存储，并作为部署 :ref:`kubernetes` 的底层分布式存储

按照计划，修订分区调整脚本，将 ``TARGET_END`` 设定为固定值

那么这个固定值该设置为多少呢？

嘿嘿，我实际上是使用 :ref:`parted` 工具，实际为磁盘划分了一个大约128GB空间分区，然后记录下 ``/sys/block/sda/sda3/size`` 来获得这个数值的。

实践的脚本修改如下:

.. literalinclude:: pi_disable_auto_resize/firstboot_changed
   :caption: 修改分区调整大小为固定128GB
   :emphasize-lines: 6,8

- 执行 ``update-initramfs`` (系统默认没有安装 :ref:`dracut` ) :

.. literalinclude:: pi_disable_auto_resize/update-initramfs
   :caption: 执行 ``update-initramfs`` 创建新的 :ref:`initramfs`

.. note::

   参考 `How can I use an init ramdisk (initramfs) on boot up Raspberry Pi? <https://raspberrypi.stackexchange.com/questions/92557/how-can-i-use-an-init-ramdisk-initramfs-on-boot-up-raspberry-pi>`_ ，我使用 ``update-initramfs`` 生成新的 :ref:`initramfs` 。

   此外， `Using an initramfs on the RPi <https://forums.raspberrypi.com/viewtopic.php?t=100609&sid=cdf34ea188594e4510d859b0205699e3>`_ 也可以采用 ``mkinitramfs`` ::

      mkinitramfs -o /boot/initramfs-$(uname -r)

参考
======

- `prevent auto resize <https://forums.raspberrypi.com/viewtopic.php?t=364801>`_ 2024年的讨论，主要参考
- `Temporarily disable expand filesystem during first boot <https://raspberrypi.stackexchange.com/questions/56621/temporarily-disable-expand-filesystem-during-first-boot>`_ 这个文档有点古老，不过有些内容还是可以的，例如 ``/etc/init.d/resize2fs_onece`` 脚本依然是目前自动调整分区大小的执行脚本
- `Disable auto file system expansion in new Jessie image 2016-05-10 <https://raspberrypi.stackexchange.com/questions/47773/disable-auto-file-system-expansion-in-new-jessie-image-2016-05-10>`_
- `Option to disable automatic "expand File System"? #335 <https://github.com/guysoft/OctoPi/issues/335>`_
- `How to resize root partition in 16.04? <https://forum.odroid.com/viewtopic.php?f=95&t=24592>`_
