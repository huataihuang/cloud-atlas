.. _freebsd_samba:

=========================
FreeBSD Samba
=========================

Samba是使用SMB/CIFS协议提供文件和打印服务共享的开源软件。Samba实现了Windows系统的SMB/CIFS协议，能够在网络中提供一个像本地硬盘和本地打印机一样共享服务。

在FreeBSD上，Samba客户端使用过 ``net/samba416`` 软件包安装的，安装以后就可以作为客户端访问Windows网络的SMB/CIFS共享。在同一个samba软件包中，也提供了一个Samba服务，这样FreeBSD也能向网络提供SMB/CIFS共享服务。

.. note::

   根据 ``pkg search samba`` 可以找到当前发行版提供了3个版本的Samba，我最初选择安装最新的 ``net/samba420`` ，但是实践发现macos客户端访问时 ``smbd`` 会crash。网上查到的资料显示，当前FreeBSD整个系统编译都是围绕 ``net/samba416`` 完成的，所以我回退到 ``net/samba416`` 之后就能正常工作了。果然，按照官方手册是正确。 

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

SMB/CIFS协议端口和iptables端口转发
======================================

在我的局域网实验环境中，提供Samba服务的FreeBSD(192.168.7.200)和桌面电脑(192.168.1.x)不是一个网段，所以需要通过一个Linux网关实现端口转发。

Samba所实现的SMB/CIFS协议端口可以通过 ``/etc/services`` 查到( ``grep -i NETBIOS /etc/services`` 以及 ``grep -i microsoft-ds /etc/services`` ):

.. literalinclude:: freebsd_samba/samba_ports
   :caption: Samba使用的服务端口

以上述端口 ``138`` 为例配置端口转发:

.. literalinclude:: freebsd_samba/iptables
   :caption: iptables端口转发案例

为了能够快速完成设置，使用如下脚本:

.. literalinclude:: freebsd_samba/iptables_script
   :caption: iptables端口转发脚本
   :language: bash

异常排查
=============

我在使用macOS连接访问FreeBSD的samba服务，遇到非常奇怪的问题，提示连接，但是仅显示第一层目录之后就一直转菊花。观察后台

.. literalinclude:: freebsd_samba/smbd.log
   :caption: ``smbd.log`` 日志显示服务crash

我之前看到网上有人询问安装 ``net/samba419`` 为何会提示有软件包冲突，有人答复是因为当前整个FreeBSD系统是围绕 ``net/samba416``  编译的依赖。果然，我回退到 ``net/samba416`` 之后就能够正常工作了。

参考
========

- `32.11. File and Print Services for Microsoft® Windows® Clients (Samba) <https://docs.freebsd.org/en/books/handbook/network-servers/#network-samba>`_
