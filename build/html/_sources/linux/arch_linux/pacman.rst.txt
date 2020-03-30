.. _pacman:

=============
Pacman
=============

pacman是arch linux的主要包管理工具。它包含了简单的二进制包格式和易于使用的编译体系。通过和主服务器同步pacman可以保持系统的软件包更新，其服务器/客户对模式允许用户下载和安装软件包以及所有依赖软件包。

pacman简明使用
================

* 安装软件包::

   pacman -S package_name1 package_name2 ...

* 使用正则方式安装一系列软件包::

   pacman -S $(pacman -Ssq package_regex)

* 如果有多个软件包位于不同仓库，例如extra仓库和testing仓库，则在软件包前加上仓库定义::

   pacman -S extra/package_name

* 支持简单的名字模式::

   pacman -S plasma-{desktop,mediacenter,nm}

* 甚至支持多级扩展::

   pacman -S plasma-{workspace{,-wallpapers}<Plug>PeepOpena}

* 一些软件包支持整组安装，例如gnome::

   pacman -S gnome

要检查这个组中包含的软件包::

   pacman -Sg gnome

* 删除单一软件包，但是保留已经安装的这个软件包的依赖::

   pacman -R package_name

* 删除软件包并且删除所有没有被其他软件包所使用的该软件包的依赖::

   pacman -Rs package_name

* 删除软件包，该软件包被其他软件包所使用，但是不删除依赖软件包::

   pacman -Rdd package_name

.. warning::

   上述命令会打破系统完整，所以需要避免

* 升级整个系统所有软件包::

   pacman -Syu

* 清理缓存::

   pacman -Sc

* 查询系统中安装的某个程序属于哪个软件包提供(这里举例查询netstat命令)::

   pacmsn -Qo /usr/bin/netstat

break dependency
=================

执行 ``pacman -Syu`` 时候遇到报错::

   looking for conflicting packages...
   error: failed to prepare transaction (could not satisfy dependencies)
   :: installing xorgproto (2019.2-2) breaks dependency 'xf86miscproto' required by libxxf86misc

参考 `xorgproto issues.. <https://bbs.archlinux.org/viewtopic.php?id=251517>`_ 处理::

   pacman -Rdd libxxf86misc && pacman -Syu

signature error
===================

执行 ``pacman -Syu`` 出现报错::

   error: pacman: signature from "Levente Polyak (anthraxx) <levente@leventepolyak.net>" is unknown trust
   :: File /var/cache/pacman/pkg/pacman-5.2.1-4-x86_64.pkg.tar.zst is corrupted (invalid or corrupted package (PGP signature)).

上述问题参考 `pacman/Package signing <https://wiki.archlinux.org/index.php/Pacman/Package_signing>`_ 和 `Signature is unknown trust [SOLVED] <https://bbs.archlinux.org/viewtopic.php?id=207957>`_ 原因是系统长时间没有更新，本地使用的key已经过期，需要重新刷新::

   pacman-key --refresh-keys

参考
=======

- `archlinux - pacman <https://wiki.archlinux.org/index.php/Pacman>`_
- `xorgproto issues.. <https://bbs.archlinux.org/viewtopic.php?id=251517>`_
