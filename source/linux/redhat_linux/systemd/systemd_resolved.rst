.. _systemd_resolved:

=====================
systemd-resolved
=====================

systemd-resolved 是通过D-Bus接口向本地应用程序提供网络名字解析的systemd服务，包括解析(resolve) NSS服务(nss-resolve)和一个在127.0.0.53上监听的本地DNS stub监听器。不需要单独安装systemd-resolved，因为当前Linux主流发行版默认使用的systemd已经包含了这个组件，并且默认启用。

.. note::

   在我部署 :ref:`priv_cloud_infra` 中，采用 :ref:`ubuntu_linux` 20.04 LTS Server 发行版，默认采用 ``systemd-resolved`` 提供本地域名解析。我在 :ref:`priv_dnsmasq_ics` 部署即结合 :ref:`dnsmasq` 和 ``systemd-resolved`` 提供局域网DNS解析。

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

检查 ``/run/systemd/resolve/resolv.conf`` 可以看到包含了上级DNS服务器配置(也就是你安装操作系统时候填写的网络配置中DNS记录)，以及默认搜索域名::

   nameserver 192.168.6.200
   search huatai.me

检查 ``/run/systemd/resolve/stub-resolv.conf`` 可以看到内容包含了指示客户端连接本地回环地址请求DNS(也就是 ``systemd-resolved`` 服务)，以及默认搜索域名::

   nameserver 127.0.0.53
   options edns0 trust-ad
   search huatai.me

.. note::

   上述配置是我部署 :ref:`zdata_ceph_rbd_libvirt` ，安装过程配置的结果。由于我需要部署 :ref:`priv_dnsmasq_ics` 来提供局域网DNS解析，并且默认域名调整为 ``staging.huatai.me`` ，所以还需要做进一步调整配置。

- 保护resolv.conf模式

在保护模式下 ``/etc/resolv.conf`` 则依然存在，而且可以由其他软件包管理，此时systemd-resolved仅仅是这个文件的客户端。

- 要检查DNS当前由systemd-resolved管理状态，执行以下命令::

   resolvectl status

也可以执行::

   systemd-resolve --status

输出信息类似::

   Global
          LLMNR setting: no
   MulticastDNS setting: no
     DNSOverTLS setting: no
         DNSSEC setting: no
       DNSSEC supported: no
             DNSSEC NTA: 10.in-addr.arpa
                         16.172.in-addr.arpa
                         168.192.in-addr.arpa
                         17.172.in-addr.arpa
   ...
   Link 2 (enp1s0)
         Current Scopes: DNS
   DefaultRoute setting: yes
          LLMNR setting: yes
   MulticastDNS setting: no
     DNSOverTLS setting: no
         DNSSEC setting: no
       DNSSEC supported: no
            DNS Servers: 192.168.6.200
             DNS Domain: huatai.me 

自动管理DNS
------------

systemd-resolved默认就可以和 :ref:`networkmanager` 协作管理 ``/etc/resolv.conf`` ，不需要单独配置。不过，如果使用DHCP和VPN客户端，则会使用 ``resolvconf`` 程序设置DNS和search domains，则需要安装一个 ``systemd-resolvconf`` 软件包来提供 ``/usr/bin/resolvconf`` 软链接，以便和VPN客户端和DHCP一起协作。(默认未安装)

手工配置DNS
-------------

在local DNS stub模式，要定制DNS服务器，需要设置 ``/etc/systemd/resolved.conf.d/dns_servers.conf`` 配置::

   [Resolve]
   DNS=192.168.35.1 fd7b:d0bd:7a6e::1
   Domains=~.

另外可以配置 ``/etc/systemd/resolved.conf`` 也能起到同样作用::

   #DNS=
   DNS=192.168.6.200
   #FallbackDNS=
   #Domains=
   Domains=dev.cloud-atlas.io

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

结合网络配置工具netplan
==========================

实际上在发行版中， ``systemd-resolvd`` 通常不需要手工配置，因为默认系统会同时安装 ``network configuration abstraction renderer`` (网络配置抽象渲染器)，例如 :ref:`netplan` 。通过网络配置工具的简单设置就可以完成指定DNS。

参考
=====

- `archlinux - systemd-resolved <https://wiki.archlinux.org/index.php/Systemd-resolved>`_
- `systemd-resolved.service <https://www.freedesktop.org/software/systemd/man/systemd-resolved.service.html>`_
