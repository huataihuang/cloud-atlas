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

- 获取完整的Core OS软件系统索引::

   freebsd-update fetch

- 更新系统已经安装的软件::

   freebsd-update install

以上命令也可以合并为一个命令::

   freebsd-update fetch install

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
