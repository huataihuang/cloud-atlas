.. _freebsd_update:

=====================
FreeBSD系统更新
=====================

FreeBSD提供了两种更新系统方式:

- ``freebsd-update`` 命令用于更新核心系统: :ref:`freebsd_update_upgrade` 详细记录 ``freebsd-update`` 工具完成系统更新步骤
- 包管理器或ports系统( :ref:`freebsd_ports` ) 用于更新第三方软件

更新FreeBSD Core OS
=======================

更新FreeBSD Core OS有两个步骤:

- 获取完整的Core OS软件系统索引:

.. literalinclude:: freebsd_update/fetch
   :caption: 获取完整的Core OS软件系统索引

- 更新系统已经安装的软件::

   freebsd-update install

以上命令也可以合并为一个命令::

   freebsd-update fetch install

``freebsd-update`` 结合反向代理
----------------------------------

对于局域网中有多个FreeBSD服务器需要更新，则建议在内部部署 :ref:`nginx_reverse_proxy` (见 `FreeBSD Update (freebsd-update) <https://wiki.freebsd.org/FreeBSD_Update>`_ 案例配置):

- 配置内部域名 ``freebsd-update.cloud-atlas.dev`` 反向代理访问 ``http://update.freebsd.org``
- 修订 ``/etc/freebsd-update.conf`` 使用内部服务器 ``freebsd-update.cloud-atlas.dev`` 来更新

这样只要有一次服务器更新，后续其他FreeBSD更新都能够通过反向代理的缓存进行更新，大大加快速度节约公网带宽

.. note::

   其实最大的困扰是在墙内访问 ``http://update.freebsd.org`` 速度太慢了，经常出现网络断开问题。我测试了一下，发现在阿里云上租用的虚拟机访问速度还可以，所以采用如下策略:

   - 在阿里云FreeBSD虚拟机内部构建一个 :ref:`thin_jail` (底层文件系统是UFS)
   - jail中部署一个 :ref:`nginx_reverse_proxy` 实现对 ``http://update.freebsd.org`` 反向代理
   - 通过 :ref:`ssh_tunneling` 允许本地FreeBSD服务器能够访问映射到本地的远程阿里云FreeBSD容器中的nginx 80端口，实现动过缓存服务器更新系统，加速更新

使用pkg更新FreeBSD软件
=========================

所有使用 ``pkg`` 安装的软件包也是通过 ``pkg`` 进行更新::

   pkg update && pkg upgrade

使用ports更新
=============

在ports安装的软件可以通过两种方式管理:

- portmaster
- portsnap

以下是使用 ``portsnap`` 更新所有ports tree::

   portsnap auto

重启系统
==========

完成更新后，需要重启系统::

   reboot

或者::

   shutdown -r now

重启后检查版本::

   freebsd-version

检查uname::

   uname -a

显示::

   FreeBSD liberty-dev 13.1-RELEASE FreeBSD 13.1-RELEASE releng/13.1-n250148-fc952ac2212 GENERIC amd64

参考
======

- `FreeBSD update packages and apply security upgrades using pkg/freebsd-update <https://www.cyberciti.biz/faq/freebsd-applying-security-updates-using-pkg-freebsd-update/>`_
- `FreeBSD How to Update All Packages <https://linuxhint.com/update_freebsd_packages/>`_
- `FreeBSD Update (freebsd-update) <https://wiki.freebsd.org/FreeBSD_Update>`_
