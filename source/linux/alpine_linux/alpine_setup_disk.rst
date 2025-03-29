.. _alpine_setup_disk:

========================
Alpine Linux配置磁盘
========================

Alpine Linux提供了 ``setup-alpine`` 来完成系统配置，不过，磁盘设置比较复杂，并没有完全覆盖在 ``setup-alpine`` 中，可以通过 ``setup-disk`` 工具来完成，以便传递一些特殊的分区参数。

Disk layouts
================

alpine linux使用了 ``extlinux`` 作为默认bootloader，这个bootloader不能处理LVM卷上的 ``/boot`` ，所以必须将 ``/boot`` 分区独立，不能位于加密或LVM卷(Grub2能够处理LVM卷的/boot)。通常我们会创建一个很小的分区作为 ``/boot`` ，然后将其余磁盘作为一个独立分区或者作为LVM卷，或者构建RAID。

典型的磁盘设置::

   One-disk system
   ---------------
     +------------------------------------------------+
     |  small partition (32--100M), holding           |
     |  only /boot, filesystem needn't be journaled   |
     +------------------------------------------------+
     |  rest of disk in second partition              |
     |  +------------------------------------------+  |
     |  | cryptsetup volume                        |  |
     |  |  +-------------------------------------+ |  |
     |  |  |  LVM PV, containing single VG,      | |  |
     |  |  |  containing multiple LVs, holding   | |  |
     |  |  |  /, /home, swap, etc                | |  |
     |  |  +-------------------------------------+ |  |
     |  +------------------------------------------+  |
     +------------------------------------------------+
   
   
   Two-disk system
   ---------------
     +------------------------------------------------+  +------------------------------------------------+
     |  small partition (32--100M), holding           |  |  small partition (32--100M), holding           | These 2 partitions might
     |  only /boot, filesystem needn't be journaled   |  |  only /boot, filesystem needn't be journaled   | form a mirrored (RAID1)
     +------------------------------------------------+  +------------------------------------------------+ volume
     |  rest of disk in second partition              |  |  rest of disk in second partition              |
     | T================================================================================================T | These 2 partitions form
     | T +--------------------------------------------------------------------------------------------+ T | a second mirrored
     | T | cryptsetup volume                                                                          | T | (RAID1) volume
     | T |  +---------------------------------------------------------------------------------------+ | T |
     | T |  | LVM PV, containing single VG,                                                         | | T |
     | T |  | containing multiple LVs, holding                                                      | | T |
     | T |  | /, /home, swap, etc                                                                   | | T |
     | T |  +---------------------------------------------------------------------------------------+ | T |
     | T +--------------------------------------------------------------------------------------------+ T |
     | T================================================================================================T |
     |                                                |  |                                                |
     +------------------------------------------------+  +------------------------------------------------+

手工分区
============

安装镜像值包含了一个非常基础的 ``busybox`` 内建的 ``fdisk`` 命令，这个命令和常规Linux发行版 ``fdisk`` 有比较大的差异，使用很不习惯。主要是显示参数采用 ``Cylinder`` 而不是 ``Sectors`` 。不过，可以安装常规的分区工具 ``sfdisk`` (scriptable fdisk), ``gptfdisk`` , ``parted`` , ``cfdisk`` (text menus) 甚至是 ``gparted`` (需要设置图形环境)

- 安装 :ref:`parted` ::

   apk add parted

.. warning::

   在使用分区前，需要 :ref:`alpine_local_backup`

参考
========

- `Alpine Linux: Setting up disks manually <https://wiki.alpinelinux.org/wiki/Setting_up_disks_manually>`_
