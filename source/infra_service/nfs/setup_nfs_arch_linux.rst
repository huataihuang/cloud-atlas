.. _setup_nfs_arch_linux:

=======================
arch linux配置NFS服务
=======================

Network File System (NFS)是1984年Sun Microsystems公司(唏嘘)开发的一种分布式文件系统协议，允许客户端用户访问在远程网络上共享的文件，就好像本地文件访问。

.. note::

   - NFS本身不提供加密，但可以采用 ``Kerberos`` 和 :ref:`linux_vpn` 加密协议来Tunnnel NFS
   - 和 :ref:`samba` 不同，NFS默认没有任何用户认证，客户端访问是通过IP地址和主机名限制来提供一定安全性
   - NFS在客户端和服务端采用相同的user/user group
   - NFS不支持POSIX ACLs

安装NFS
========

- 在 :ref:`arch_linux` 上安装NFS支持软件包:

.. literalinclude:: setup_nfs_arch_linux/pacman_install_nfs-utils
   :language: bash
   :caption: 在arch linux上安装nfs-utils支持NFS

参考
======

- `arch linux: NFS <https://wiki.archlinux.org/title/NFS>`_
