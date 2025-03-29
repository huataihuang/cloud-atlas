.. _archlinux_vultr:

==============================
在Vultr VPS中运行Arch Linux
==============================

最近把购买的Vultr VPS转到硅谷机房，发现Vultr提供了多种操作系统可选，甚至还提供了自己上传iso镜像( 试试 :ref:`gentoo_linux` ? )。我考虑尝试更新的技术，所以将使用了4年的Ubuntu VPS改成Arch Linux。这里记录在云厂商Vultr上部署Arch Linux的过程。

选购和访问
============

家里使用的是移动提供的宽带，我经过对比发现Vultr的 **硅谷机房** 访问最稳定，速度也最快。购买Vultr最便宜的5美刀VPS，作为翻墙和简单WEB网站已经足够。启动新创建的Arch Linux VPS，登陆后检查可以看到 24GB 的 ``/dev/vda2`` 已经用去了 4.5G:

.. literalinclude:: archlinux_vultr/df
   :caption: Vultr的arch linux初始使用容量
   :emphasize-lines: 4

系统配置
========

- 完整升级一次系统:

.. literalinclude:: pacman/upgrade_system
   :caption: 升级整个arch linux系统

- 默认时区修订成中国:

.. literalinclude:: ../../infra_service/ntp/host_time_init/local_timezone.sh
   :language: bash
   :caption: 配置上海本地时区

- 安装基础软件(不断补充跟新):

.. literalinclude:: archlinux_vultr/install_base_packages
   :caption: 在Vultr虚拟机的arch linux安装必要基础软件

安装配置squid
================

依然采用 :ref:`squid_socks_peer` 方案翻墙，所以在VPS上安装部署 :ref:`squid` :

.. literalinclude:: ../../web/proxy/squid/squid_startup/pacman_install_squid
   :caption: 安装 squid

- 在墙外squid ( vultr虚拟机上运行的 ``EXTERNAL PROXY`` ) 配置 ``/etc/squid/squid.conf`` 修改:

.. literalinclude:: ../../web/proxy/squid/squid_socks_peer/squid_limit_localhost
   :caption: 限制squid仅监听本地回环地址，避免外部滥用

- 重启并配置squid在操作系统启动时启动:

.. literalinclude:: ../../web/proxy/squid/squid_startup/restart_enable_squid
   :caption: 重启并激活squid服务器(在操作系统启动时启动)

部署VPN
=========

我最初想采用 :ref:`openconnect_vpn` 部署，但是目前 Arch Linux 发行版不包含 ``ocserv`` ，而第三方 :ref:`archlinux_aur` 安装还存在问题。所以，再次 :ref:`deploy_wireguard` (已完成部署，非常丝滑)
