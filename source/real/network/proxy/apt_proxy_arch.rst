.. _apt_proxy_arch:

====================
APT无阻碍代理架构
====================

在我们维护Ubuntu/Debian系统时，我们都是使用apt 仓库进行软件更新。但是，由于所谓"主权"原因，我们无法访问很多互联网资源，特别是部署 :ref:`kubernetes` 集群，无法访问Google软件仓库带来极大的阻碍。我经过一些尝试:

- :ref:`openconnect_vpn`

  - 优点: 完整的通用型SSL VPN解决方案，不仅适合打通墙内墙外网络实现APT无阻碍升级，也适合其他企业网络数据通许
  - 缺点:

    - 部署步骤繁杂，对于本文解决Ubuntu/Debian软件安装升级的需求过于沉重
    - 客户端vpn连接后可能破坏本地网络路由

- :ref:`polipo_proxy_yum`

  - 优点: 部署简便，只需要在墙外启动服务提供代理，加上一些简单的客户端IP限制就能够提供软件包安装代理
  - 缺点: 

    - 软件已经停止开发维护
    - 缺少安全机制(可以通过 SSH tunnel加密来弥补)
    - 每个升级客户端都要连接代理服务器，重复的互联网下载(可以本地局域网代理改进)

- :ref:`squid_socks_peer`

  - 优点: 

    - squid作为著名的开源代理软件，经过了长期和广泛的验证
    - 性能优异稳定可靠，可以支持海量客户端
    - 通过多级代理部署，可以实现本地局域网和墙外代理的多层多源加速
    
  - 缺点:

    - 大型软件，需要持续学习和实践

适合apt软件仓库的代理方案
==========================

综合我的几次实践，目前我选择 :ref:`squid_socks_peer` 作为基础，结合 SSH tunnel 来实现无阻碍网络:

- 在 :ref:`pi_cluster` 上部署了 :ref:`kubernetes_arm` ，其中管控服务器节点 ``pi-master1`` 运行 squid 本地代理服务器

- 租用海外云计算厂商的VPS，采用  :ref:`squid_socks_peer` 架构，在服务器端运行一个只监听本地回环地址 ``127.0.0.1`` 的squid代理服务器：这样代理服务器不能被外部用户直接访问，只能通过ssh方式建立Tunnel之后才能通过端口映射方式被客户端访问到，这就提供了极强的安全加密

.. figure:: ../../../_static/web/proxy/squid/peering_basics.png
   :scale: 70

- 本地树莓派主机 ``pi-master1`` 通过 SSH Tunnel 和海外VPS构建安全加密通道，然后本地 squid 代理服务器将VPS上监听在回环地址的squid作为父级代理，通过两跳方式，所有在本地局域网已树莓派主机 ``pi-master1`` 为代理的客户端，都能再通过海外squid代理访问整个互联网:

  - 本地树莓派主机 ``pi-master1`` 的squid配置ACL规则，可以只将部分被GFW屏蔽的网站请求转发给父级squid，这样可以节约大量的海外流量
  - squid具备的本地代理缓存可以大大加速本地局域网相同的软件安装下载

.. figure:: ../../../_static/web/proxy/squid/squid-parent-proxy-server.png
   :scale: 70


实施步骤
==========

海外VPS运行squid配置
----------------------

- VPS运行Debian/Ubuntu系统，通过apt安装squid::

   sudo apt install squid

- 修改 ``/etc/squid/squid.conf`` 配置，添加以下配置::

   # 仅提供本地回环地址服务，避免安全隐患
   http_port 127.0.0.1:3128

- 启动squid服务::

   sudo systemctl start squid

- 检查日志::

   sudo systemctl status squid

本地树莓派squid
------------------

- 本地 :ref:`ubuntu64bit_pi` ，所以同样使用apt安装squid::

   sudo apt install squid

- 由于我们后面会使用 SSH Tunnel 将本地 ``4128`` 端口转发到远程VPS上回环地址 ``3128`` ，所以我们这里需要配置我们本地squid的父级squid监听是 ``127.0.0.1:4128`` ，完整配置如下

.. literalinclude:: apt_proxy_arch/squid_internal.conf
   :language: bash
   :linenos:
   :caption:

解析:

SSH Tunnel
------------

在本地树莓派(client squid)和墙外VPS(partent squid)上运行了squid服务之后，我们使用SSH Stunnel来打通连接：

- 在本地树莓派 ``pi-master1`` 上配置 ``~/.ssh/config`` :

.. literalinclude:: apt_proxy_arch/ssh_config
   :language: bash
   :linenos:
   :caption:

解析:

  - ``ServerAliveInterval 60`` 每60秒保持ssh服务连接1次，确保不被服务器断开
  - ``ControlMaster`` ``ControlPath`` ``ControlPersist`` 可以复用SSH通道，这样即使ssh客户端结束运行，ssh tunnel也保持
  - ``Compression yes`` 启用ssh的gzip压缩，这样可以节约网络流量(不过对于软件包下载都是已经压缩过文件，理论上该参数无实际效果反而会增大开销)
  - 在 ``Host`` 段落，``HostName`` 是连接墙外VPS服务器的域名，请按照你自己的服务器配置
  - ``LocalForward 4128 127.0.0.1:3128`` 将本地树莓派回环地址上的 ``4128`` 转发到远程VPS的回环地址 ``3128`` 上，这样client squid访问级联本级 ``4128`` 就相当于访问远程VPS的 ``3128`` ，就能够将远程VPS上运行的squid作为自己的 ``parent squid``

- 执行SSH Tunnel命令::

   ssh parent-squid

- 完成ssh连接后，退出，再次访问应该不再需要ssh密码，这表明ssh tunnel的连接始终保持

APT代理配置
--------------

- :ref:`apt` 程序支持代理，由于 ``pi-master1`` 上运行的本地squid允许局域网网段 ``192.168.x.x`` 访问，所以配置整个局域网使用代理作为APT访问方式，即 ``/etc/apt/apt.conf.d/proxy.conf`` 配置:

.. literalinclude:: apt_proxy_arch/proxy.conf
   :language: bash
   :linenos:
   :caption:

- 在本地任意一台Ubuntu主机上执行更新apt更新::

   sudo apt update
   sudo apt upgrade

如果一切正常，则会通过二级代理自由访问因特网。
