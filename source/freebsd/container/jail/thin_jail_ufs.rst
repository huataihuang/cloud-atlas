.. _thin_jail_ufs:

=================================
在UFS文件系统上构建Thin Jail
=================================

我因为 :ref:`zfs` 非常方便管理和使用，所以大多数FreeBSD和Linux部署时都会采用ZFS作为数据存储文件系统。在 :ref:`thin_jail` 甚至 :ref:`vnet_thin_jail` 也采用ZFS来实践构建。

不过，也有一些环境采用了传统的UFS文件系统，例如，我在阿里云租用的VM，阿里云默认提供的FreeBSD镜像就是采用UFS文件系统。我需要为 :ref:`freebsd_update` 构建一个反向代理缓存服务器，考虑在租用的VM中构建一个隔离的Thin Jail来运行 :ref:`nginx_reverse_proxy` 。这里记录准备工作，构建一个UFS上的Thin Jail。

- 准备环境变量(方便后续操作);

.. literalinclude:: thin_jail_ufs/jail_var
   :caption: 准备jail相关环境变量

- 创建RELEASE-base模版目录:

.. literalinclude:: thin_jail_ufs/jail_template
   :caption: 在UFS中创建模板数据集

- 和 :ref:`thick_jail` 一样下载用户空间:

.. literalinclude:: thin_jail_ufs/download
   :caption: 下载RELEASE-base

参考
============

- `FreeBSD Handbook: Chapter 17. Jails and Containers > 17.5. Thin Jails <https://docs.freebsd.org/en/books/handbook/jails/#thin-jail>`_
