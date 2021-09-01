.. _alpine_extended:

=====================
U盘运行Alpine Linux
=====================

我的运行模式
==============

我是在 MacBook Pro 15" 2013 late笔记本上使用Alpine Linux，采用外接U盘方式，所以我准备采用 ``diskless`` 模式。不过，内置的硬盘也不能浪费，原装SSD硬盘512G，虽然已经在macOS install过程中爆SMART错误，不过还能废物利用，我准备作为本地数据盘使用。

目前我对 :ref:`btrfs` 发展比较看好，所以会在内置磁盘上启用btrfs来构建一些虚拟机和容器的性能测试。不过，重要数据还是采用 :ref:`ceph` 和 :ref:`gluster` 分布式存储保存的到ARM集群运行的存储中。

U盘我选择 Sandisk 酷豆CZ430 ，非常小巧USB3.1， 32G 容量，价格约38元:

.. figure:: ../../_static/linux/alpine_linux/sandisk_udisk_32g.png
   :scale: 60

安装
==========

- `下载 Alpine Linux <https://www.alpinelinux.org/downloads/>`_ Extended版本，然后 ``dd`` 到U盘::

   sudo dd if=alpine-extended-3.14.2-x86_64.iso of=/dev/sda bs=100MB

完成以后U盘的磁盘分区如下::

   Disk /dev/sda: 28.67 GiB, 30765219840 bytes, 60088320 sectors
   Disk model:  SanDisk 3.2Gen1
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: dos
   Disk identifier: 0x65428faa
   
   Device     Boot Start     End Sectors  Size Id Type
   /dev/sda1  *        0 1224703 1224704  598M  0 Empty
   /dev/sda2         460    3339    2880  1.4M ef EFI (FAT-12/16/32

可以看到 Alpine Linux的扩展模式镜像实际上占用磁盘空间不大，仅 600M ，剩余空间可以用来作为数据存储。

执行初始化
==============

- 参考 :ref:`alpine_install` 执行 ``setup-alpine`` 对系统进行初始化
