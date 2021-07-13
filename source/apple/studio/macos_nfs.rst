.. _macos_nfs:

========================
macOS系统NFS服务
========================

我在构建macOS系统中 :ref:`docker_studio` ，想要在物理主机(macOS)上能够直接存储容器的数据，以避免容器销毁导致开发环境的数据丢失。例如，我可以运行数据库，代码存储。

将容器中的数据通过卷存储到远程NFS服务器上，也就是macOS物理主机上，能够方便进行数据备份和同步。需要注意，macOS上运行的Docker服务器实际上是运行在 :ref:`xhyve` 运行的一个轻量级的 :ref:`alpine_linux` 。所以，如果通过容器内部挂载NFS的方式来访问macOS物理服务器的共享存储，可以通过 :ref:`macos_docker_shell` 在虚拟机上实现对远程存储的挂载，然后映射到容器内部提供使用。

通过NFS输出macOS上目录
=======================

- 首先在macOS主机上启动NFS服务::

   sudo nfsd enable

如果系统已经启用过nfsd，则可能提示::

   The nfsd service is already enabled.

- 可以检查nfs服务::

   sudo rpcinfo -p

输出显示::

   program vers proto   port
    ...
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs

- 和标准的Unix/Linux系统相似，macOS也是通过 ``/etc/exports`` 文件配置NFS输出::

   /Users/huatai/home_admin/dev -rw

- 重启一次服务::

   nfsd restart

NFS客户端访问
================

.. note::

   在macOS上我曾经想 :ref:`macos_docker_shell` 在Docker VM上使用NFS来挂载macOS上的共享NFS卷，但是实践没有找到方法(难点在于 :ref:`alpine_linux` 软件包管理以及访问macOS的IP地址 )，有待探索。所以，我这里客户端改为在局域网上一台Linux


防火墙
==========

macOS提供了一个防火墙，需要检查确认一下默认是否启用了防火墙（可能和版本相关，不同版本默认有可能开启也可能关闭了防火墙，目前最新的macOS都是默认关闭防火墙）。对于启用了防火墙的macOS系统，需要配置 ``System Preferences => Secuirty & Privancy => Firewall`` ，设置允许TCP端口 ``2049, 111`` 。

.. note::

   macOS的防火墙配置我还没有具体实践，

参考
======

- `NFS server support in OS X 10.15.x Catalina? <https://apple.stackexchange.com/questions/384806/nfs-server-support-in-os-x-10-15-x-catalina>`_
- `How to get nfsd to serve NFSv4 on High Sierra? <https://apple.stackexchange.com/questions/322229/how-to-get-nfsd-to-serve-nfsv4-on-high-sierra>`_
- `How to create an NFS share on MAC OS X (Snow Leopard) and mount (automatically during startup) from another MAC <https://community.spiceworks.com/how_to/61136-how-to-create-an-nfs-share-on-mac-os-x-snow-leopard-and-mount-automatically-during-startup-from-another-mac>`_
- `How to configure an NFS share from Mac OSX to Linux <https://www.williamrobertson.net/documents/nfs-mac-linux-setup.html>`_
- `macOS X Mount NFS Share / Set an NFS Client <https://www.cyberciti.biz/faq/apple-mac-osx-nfs-mount-command-tutorial>`_
- `Exporting Directories with NFS <https://docstore.mik.ua/orelly/unix3/mac/ch03_10.htm>`_
