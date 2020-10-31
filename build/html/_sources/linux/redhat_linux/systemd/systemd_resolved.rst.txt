.. _systemd_resolved:

=====================
systemd-resolved
=====================

systemd-resolved 是通过D-Bus接口向本地应用程序提供网络名字解析的systemd服务，包括解析(resolve) NSS服务(nss-resolve)和一个在127.0.0.53上监听的本地DNS stub监听器。不需要单独安装systemd-resolved，因为当前Linux主流发行版默认使用的systemd已经包含了这个组件，并且默认启用。

配置
======

systemd-resolved为域名系统(Domain Name System, DNS)(包括DNSSEC和DNS over TLS)，多播DNS(Multicast DNS, mDNS) 以及链接本地多播域名解析(Link-Local Multicast Name Resolution, LLMNR)提供解析服务。

这个解析起可以通过编辑 ``/etc/systemd/resolved.conf`` 或者 添加/删除 位于 ``/etc/systemd/resolved.conf.d/`` 目录下 ``.conf`` 配置文件来管理。注意，需要启动并激活 ``systemd-resolved.service`` 。

DNS
-----

systemd-resolved有4种不同方式来处理DNS解析，其中有2中是主要使用模式：

- local DNS stub模式

使用systemd DNS stub文件 ``/run/systemd/resolve/stub-resolv.conf`` ，这个文件只包含local stub ``127.0.0.53`` 作为唯一DNS服务器，以及一系列search domains。这是 **建议使用** 的操作模式：原先传统的 ``/etc/resolv.conf`` 已经由systemd-resolved管理改成为软链接到systemd DNS stub文件::

   lrwxrwxrwx 1 root root 39 Jul 31 16:37 /etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf

而且，在 ``/run/systemd/resolve/`` 目录下还有一个 ``resolv.conf`` 配置，则是 ``systemd-resolved`` 使用的上级DNS服务器，也就是转发(forward)DNS解析请求给上级DNS。

- 保护resolv.conf模式

在保护模式下 ``/etc/resolv.conf`` 则依然存在，而且可以由其他软件包管理，此时systemd-resolved仅仅是这个文件的客户端。

要检查DNS当前由systemd-resolved管理状态，执行以下命令::

   resolvectl status

自动管理DNS
------------

systemd-resolved默认就可以和 :ref:`networkmanager` 协作管理 ``/etc/resolv.conf`` ，不需要单独配置。不过，如果使用DHCP和VPN客户端，则会使用 ``resolvconf`` 程序设置DNS和search domains，则需要安装一个 ``systemd-resolvconf`` 软件包来提供 ``/usr/bin/resolvconf`` 软链接，以便和VPN客户端和DHCP一起协作。

手工配置DNS
-------------

在local DNS stub模式，要定制DNS服务器，需要设置 ``/etc/systemd/resolved.conf.d/dns_servers.conf`` 配置::

   [Resolve]
   DNS=192.168.35.1 fd7b:d0bd:7a6e::1
   Domains=~.

Fallback
---------

如果systemd-resolved没有从 :ref:`networkmanager` 收到DNS服务器地址，并且没有手工配置 ``dns_servers.conf`` ，那么systemd-resolved将fall back回fallback DNS地址以确保DNS解析可以工作。

这个fallback dns地址在 ``/etc/systemd/resolved.conf.d/fallback_dns.conf`` 配置::

   [Resolve]
   FallbackDNS=127.0.0.1 ::1

如果要禁止fallback DNS功能，则将 ``FallbackDNS`` 参数是设置为空::

   [Resolve]
   FallbackDNS=

.. note::

   systemd-resolved还有支持 DNSSEC, DNS over TLS, mDNS 等功能，有待后续在研究DNS服务 :ref:`bind` 时候学习实践。

参考
=====

- `archlinux - systemd-resolved <https://wiki.archlinux.org/index.php/Systemd-resolved>`_
- `systemd-resolved.service <https://www.freedesktop.org/software/systemd/man/systemd-resolved.service.html>`_
