.. _mavericks_mba11_late_2010:

=================================================================
在 MacBook Air 11" Late 2010 上运行Mac OS X 10.9.5 (Mavericks)
=================================================================

2026年8月底，在 :ref:`mba11_late_2010` 上市16年之际，我突发奇想，将这台古老的设备擦拭干净，重新安装系统体验经典的拟物桌面:

- 通过修订证书、安装社区反向移植的浏览器，实现能够浏览现代网站
- 通过安装开源软件，实现一个轻量级的移动桌面: 所有的大型软件在远端部署的服务器上运行

体验一种古老和现代混合的计算机工作环境，看看能否用最简单的硬件来完成最现代化的工作。

.. warning::

   实际上要复活16年前的设备比我想像更为折腾，很多软件已经不再支持古老的Mavericks，即使自己编译也是困难重重。

   在这里我汇总一下需要注意的要点

OS X Mavericks 10.9.5
========================

互联网档案 `OS X Mavericks 10.9.5 <https://archive.org/details/os-x-mavericks-10.9.5>`_

- 下载的 ``OS_X_Mavericks_10.9.5.iso`` 通过 ``dd`` 命令写入U盘(注意，在写U盘之前先卸载掉自动挂载的分区，并确保不要搞错磁盘)

.. literalinclude:: mavericks_mba11_late_2010/dd
   :caption: 制作启动U盘

启动U盘，进入安装时，会提示错误:

.. literalinclude:: mvericks_mba11_late_2010/verify_error
   :caption: 安装过程提示无法验证Install

这个报错原因是Apple官方安装包中的安全证书过期了，导致验证失败，并不是镜像损坏或被篡改。

解决的方法很简单：

- 断开网络(关键): 关闭Wi-Fi或拔掉网线，否则联网时修订系统时间会被NTP同步自动修正，修改就会失效。
- 启动菜单Utilities(实用工具)中的Terminal(终端)，在命令行输入如下命令修改时间:

.. literalinclude:: mavericks_mba11_late_2010/date
   :caption: 修改系统时间

命令格式是 ``MMddHHmmYY`` ，即02月01日00点00分2014年

然后返回OS X Mavericks安装界面继续安装。

上述修改时间的操作可能需要一进入安装过程就首先设置。

系统证书
==========

由于Mavericks已经非常古早，并且已经停止更新很长时间，所以系统缺乏很多现在互联网网站使用的证书，需要手工下载并导入:

- 

翻墙
======

这个步骤是我返回Mavericks老系统最头痛的事情，原因是现在 :ref:`shadowsocks` 的系列软件都已经面向新版本macOS开发，对于古早的OS X 10.9系列，已经没有二进制发行版，需要寻找兼容的版本从源代码编译。但是，实际上SS依赖的系列底层安全库都需要编译，带来极大的工作量:

- :ref:`build_shadowsocks-libev_on_mavericks` 非常折腾的编译过程，持续折腾中...

Microsoft Office 2011 for Mac 14.7.7 Final
============================================

互联网档案 `Microsoft Office 2011 for Mac 14.7.7 Final <https://archive.org/details/MicrosoftOffice2011forMac-14.7.7>`_ 

- 最后一个拟物桌面的的Office版本，面向 OS X 10.9开发

视频播放
===========

轻量级最节约资源 `mpv <https://mpv.io/>`_ 提供了各种平台编译二进制 `mpv installation <https://mpv.io/installation/>`_ 我采用了 `macOS builds by stolendata <https://laboratory.stolendata.net/~djinn/mpv_osx/>`_ 针对 10.9 编译的早期版本 `mpv 0.20.0 for OS X 10.9 (mavericks) <https://laboratory.stolendata.net/~djinn/mpv_osx/mpv-0.29.0-mavericks.tar.gz>`_
