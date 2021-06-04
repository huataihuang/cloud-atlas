.. _multipass:

================
Multipass
================

Multipass是Canonical公司(Ubuntu)开发的基于不同操作系统内建原生Hypervisor实现的工作站(Workstation) mini-cloud。由于Windows(Hyper-V)，macOS( :ref:`hyperkit`  )和Linux( :ref:`kvm` )都原生支持 :ref:`hypervisor` ，这样通过 ``multipass shell`` 命令就能够在一个shell中实现创建运行Ubuntu虚拟机。

这是一种快速部署Ubuntu开发测试环境的便捷方法，并且和其他云上运行一样，支持通过 :ref:`cloud_init` 进行实例初始化 ( ``multipass launch --cloud-init`` )。

Multipass还支持卷挂载( ``multipass mount`` )，以便在host主机和虚拟机实例之间复制数据( ``multipass transfer`` )

安装Multipass
===============

macOS
--------

在macOS平台，默认的后端是 :ref:`hyperkit` ，需要 macOS Yosemite (10.10.3)以上版本并且需要安装在2010以后生产的Mac设备。如果硬件和软件条件不满足，则可以使用VirtualBox作为虚拟化。

安装的方法有两种：

- 从 `Multipass GitHub Releases <https://github.com/canonical/multipass/releases>`_ 下载安装包
- 使用 ``brew`` 进行安装::

   brew cask install multipass

通过 ``brew`` 安装也可以卸载::

   $ brew cask uninstall multipass
   # or
   $ brew cask zap multipass # to destroy all data, too

启动Multipass
=================

- 启动新实例

``multipass launch`` 命令没有renew参数就会启动一个基于默认镜像的运行实例，使用一个随机生成的名字::

   multipass launch

可以指定启动实例名字( ``-n, --name <name>`` )，分配cpu数量( ``-c, --cpus <cpus>`` 默认是1)，设置磁盘容量( ``-d, --disk <disk>`` 默认5G，最小512M)，设置内存分配( ``-m, --mem <mem>`` 最小128M，默认1G)，并且可以指定 :ref:`cloud_init` ::

   multipass launch -c 2 -d 12G -m 2G -n devstack

.. note::

   ``multipass launch`` 命令会从Ubuntu网站下载镜像，但是ubuntu的官方服务器在国内访问很慢(移动固网)，经常会报错::

      launch failed: failed to download from 'http://cloud-images.ubuntu.com/releases/server/releases/bionic/release-20200129.1/ubuntu-18.04-server-cloudimg-amd64.img': Network timeout

   `Ubuntu cloud-image网站 <https://cloud-images.ubuntu.com>`_ 提供了Ubuntu官方镜像下载，对于难以直接launch的镜像(由于网络原因)，可以通过海外虚拟机预先下载再传回自己的服务器。

- 进入新实例shell::

   multipass shell



参考
======

- `Multipass Guide <https://multipass.run/docs>`_
