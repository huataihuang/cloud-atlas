.. _extfs:

=========================================
macOS平台使用extFS读写Linux的EXT文件系统
=========================================

对于安装macOS+Linux双操作系统启动，如果需要读写Linux的EXT4文件系统，有以下推荐方法:

- 购买 `Paragon's extFS for Mac <https://www.paragon-software.com/home/extfs-mac/>`_ ，通过支付宝购买大约129元
- 安装VirtualBox虚拟机，通过虚拟机挂载外接的U盘(能否直接访问内置磁盘分区？)，然后在Linux虚拟机中通过Samba输出给macOS访问

extFS安装
=============

安装比较曲折，因为需要加载一个内核模块，而macOS的安全性对加载内核模块操作比较复杂

参考
======

- `How can I mount an ext4 file system on OS X? <https://apple.stackexchange.com/questions/29842/how-can-i-mount-an-ext4-file-system-on-os-x>`_
