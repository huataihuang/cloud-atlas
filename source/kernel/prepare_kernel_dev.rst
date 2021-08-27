.. _prepare_kernel_dev:

=======================
内核开发学习准备工作
=======================

内核版本
===========

`Linux Kernel Development <https://www.amazon.com/Linux-Kernel-Development-Developers-Library-ebook-dp-B003V4ATI0/dp/B003V4ATI0/>`_ (2.6.34)和 `Professional Linux Kernel Architecture <https://www.amazon.com/Professional-Kernel-Architecture-Wolfgang-Mauerer/dp/0470343435/>`_ (2.6.24) 解析Linux版本采用的是稳定内核系列 2.6.x ，大约相当于 RHEL/CentOS 6.x 时代主流Linux发行版采用的内核版本。这个系列内核具备了现代Linux系统的特性，同时代码量尚未急剧膨胀。

我采用 CentOS 6.10 系统，然后安装 `kernel v2.6 <https://kernel.org/pub/linux/kernel/v2.6/>`_ 内核

开发环境准备
===============

- 在 :ref:`vmware_fusion` 安装 CentOS 6.10，采用最小化安装

- 注意，由于CentOS已经停止CentOS 6的更新，所以原先软件仓库配置已经不能使用。需要 :ref:`fix_centos6_repo`

- 操作系统安装完成后，采用 :ref:`init_centos` 中相似方法安装必要开发工具::

   yum install vim sysstat nfs-utils gcc gcc-c++ make \
     flex autoconf automake ncurses-devel zlib-devel git

