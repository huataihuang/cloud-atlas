.. _noobs:

================================
NOOBS (New Out of Box Software)
================================

Raspberry Pi为了方便初学者安装操作系统，提供了一个名为 NOOBS 的工具。NOOBS提供了方便的选择，可以用来安装可以用于树莓派的不同操作系统，例如官方版本 ``Raspbian`` (基于debian的Raspberry Pi官方操作系统)或者Windows 10 IoT Core操作系统等。

.. figure:: ../../_static/arm/raspberry_pi/noobs.png
   :scale: 75

- 首先 `下载最新版本的NOOBS <http://downloads.raspberrypi.org/NOOBS_latest>`_
- 将SD卡格式化成FAT格式(SD卡至少需要16G才能安装完整版Raspberry Pi OS，其他版本至少需要8G)
- 将下载的NOOBS zip文件解压缩
- 将解压缩以后的文件复制到SD卡的根目录下，注意所有文件都要在根目录下
- 首次启动，"RECOVERY" FAT分区会自动调整到最小，然后可安装的OS列表就提供选择安装

.. note::

   NOOBS有两个版本，一个是offline安装版本，一个是network安装版本。offline安装版本提供了一个完整的Raspberry Pi OS，而NOOBS Lite则是通过网路安装，其他不同操作系统也是通过网络安装。

参考
======

- `NOOBS (New Out of Box Software) <https://github.com/raspberrypi/noobs/blob/master/README.md>`_
