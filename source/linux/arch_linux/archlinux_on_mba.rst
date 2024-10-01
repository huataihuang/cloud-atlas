.. _archlinux_on_mba:

==============================
MacBook Air上运行Arch Linux
==============================

为了能够 :ref:`lfs_mba` ，我采用先在 :ref:`mba11_late_2010` 完成精简的 Arch Linux，以便能够温习 :ref:`arch_linux` 的运维。本次实践在原先 :ref:`archlinux_on_mbp` 和 :ref:`archlinux_on_thinkpad_x220` 综合改进，并参考最新 `archlinux Installation guide <https://wiki.archlinux.org/index.php/Installation_guide>`_

下载 arch linux iso 和制作启动U盘
===================================

- 从 `Arch Liux Downloads <https://archlinux.org/download/>`_ 页面找到合适的下载，我当前使用的是 ``archlinux-2024.09.01-x86_64.iso``

.. literalinclude:: archlinux_on_mba/sha256
   :caption: 对下载iso检查 sha256sum

- macOS平台制作启动U盘，执行如下命令创建安装U盘:

.. literalinclude:: archlinux_on_mba/udisk
   :caption: 在macOS平台执行iso转换并创建启动U盘

按住 ``option(alt)`` 键启动 :ref:`mba11_late_2010` ，即从U盘启动安装

网络连接
==========

.. note::

   安装步骤和 :ref:`archlinux_on_mbp` / :ref:`archlinux_on_thinkpad_x220` 类似，实践中罗帷调整

   Arch Linux安装需要网络，通常建议先通过有线网络连接Internet来完成安装过程

:ref:`mba11_late_2010` 无线网卡兼容性较好，能够直接被 Arch Linux 安装识别， :strike:`所以我这里采用无线配置网络后进行安装` 但是很不幸，和 :ref:`mba11_late_2010_win10` 经历一样，我发现初始时候， :ref:`mba11_late_2010` 键盘不能被安装程序正确识别，这导致了无法输入包含特定字符和数字的命令(实际上也就无法完成安装过程的命令输入)。不过，好在天无绝人之路，Arch Linux默认只要连接有线网络，就能够通过dhcp分配地址，加上默认启动了 :ref:`ssh` 服务，所以很快通过有线网络连接+ssh远程登陆就可以继续完成安装。

磁盘分区
===========

.. csv-table:: UEFI with GPT磁盘分区
   :file: archlinux_on_mba/partition.csv
   :widths: 20,20,20,20,20
   :header-rows: 1

使用 :ref:`parted` 划分分区:

.. literalinclude:: archlinux_on_mba/parted
   :language: bash
   :caption: 划分磁盘

最后执行 ``parted /dev/sda print`` 输入如下

.. literalinclude:: archlinux_on_mba/parted_print
   :caption: ``parted`` 显示分区
   :emphasize-lines: 8-11

挂载文件系统
===============

``root`` 卷需要挂载到 ``/mnt`` ，其他分区需要依次挂载到这个 ``/mnt`` 下子目录:

.. literalinclude:: archlinux_on_mba/mount
   :language: bash
   :caption: 挂载分区

安装
=======

- 为加快文件下载，修订 ``/etc/pacman.d/mirrorlist`` ，添加163镜像网站到第一行(越靠前优先级越高):

.. literalinclude:: archlinux_on_mba/mirrorlist
   :caption: 在 ``/etc/pacman.d/mirrorlist`` 添加163的镜像网站，加速文件下载

- 安装基本软件:

.. literalinclude:: archlinux_on_mba/pacstrap
   :caption: 安装基础软件包，Linux内核和firmware

参考
=========

- `archlinux Installation guide <https://wiki.archlinux.org/index.php/Installation_guide>`_
- `USB flash installation medium <https://wiki.archlinux.org/title/USB_flash_installation_medium>`_
