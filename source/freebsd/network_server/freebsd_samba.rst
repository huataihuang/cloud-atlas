.. _freebsd_samba:

=========================
FreeBSD Samba
=========================

Samba是使用SMB/CIFS协议提供文件和打印服务共享的开源软件。Samba实现了Windows系统的SMB/CIFS协议，能够在网络中提供一个像本地硬盘和本地打印机一样共享服务。

在FreeBSD上，Samba客户端使用过 :strike:`net/samba416` 软件包安装的，安装以后就可以作为客户端访问Windows网络的SMB/CIFS共享。在同一个samba软件包中，也提供了一个Samba服务，这样FreeBSD也能向网络提供SMB/CIFS共享服务。

.. note::

   根据 ``pkg search samba`` 可以找到当前发行版提供了3个版本的Samba，我选择安装最新的 ``net/samba420``

.. note::

   根据 `OpenZFS: System Administration <https://openzfs.org/wiki/System_Administration>`_ 说明，目前只有 ``Illumos`` (也就是Solaris 11)在ZFS上完整实现了 ``iSCSI/NFS/SMB`` :

   - Linux平台OpenZFS同时实现了 NFS 和 SMB
   - FreeBSD凭爱OpenZFS只实现了 NFS

   由于我是在FreeBSD上部署ZFS，所以Samba是单独安装软件包进行配置

安装
=========

.. literalinclude:: freebsd_samba/install
   :caption: 安装Samba

服务器配置
==============

Samba配置文件是 ``/usr/local/etc/smb4.conf``

.. literalinclude:: freebsd_samba/smb4.conf
   :caption: ``/usr/local/etc/smb4.conf``

- 设置用户密码(这里案例是 ``admin`` 用户):

.. literalinclude:: freebsd_samba/pdbedit
   :caption: 设置 ``admin`` 用户密码

- 修订 ``/etc/rc.conf`` 配置启动操作系统时启动Samba:

.. literalinclude:: freebsd_samba/rc.conf
   :caption: 配置系统启动时启动Samba

- 启动 samba:

.. literalinclude:: freebsd_samba/start
   :caption: 启动Samba

输出提示:

.. literalinclude:: freebsd_samba/start_output
   :caption: 启动Samba提示信息

.. note::

   默认只启动 ``nmbd`` 和 ``smbd`` 服务。

   如果要启动 ``winbindd`` 服务，则配置 ``/etc/rc.conf`` 添加:

   .. literalinclude:: freebsd_samba/rc.conf_winbindd
      :caption: 添加 ``winbindd`` 服务启动

参考
========

- `32.11. File and Print Services for Microsoft® Windows® Clients (Samba) <https://docs.freebsd.org/en/books/handbook/network-servers/#network-samba>`_
