.. _squid_ssh_proxy:

====================
Squid SSH代理
====================

通常我们都使用 Squid 作为HTTP/HTTPS代理，例如 :ref:`squid_startup` 可以很方便配置一个用于整个局域网代理的Squid，不仅节约了带宽也加速了软件包分发。我在 :ref:`priv_cloud_infra` 构建中，所有应用服务，包括用于 :ref:`kubernetes` 集群的节点IP地址，都采用 ``192.168.6.0/24`` 内网网段。这种内部IP地址(测试网段)可以避免和整个办公网络的IP地址冲突，但是也带来了难以直接访问的问题。类似于 :ref:`kubernetes` 的 :ref:`ingress`
概念，所有内部IP地址上的服务(SSH等)都可以通过一个反向代理来访问，而 :ref:`squid` 则是反向代理中最为常用的服务。

配置Squid SSH proxy
======================

- 首先和 :ref:`squid_startup` 一样，需要设置允许的代理客户端IP地址段，配置类似如下::

   acl localnet src 192.168.1.0/24

- 然后添加设置 SSH 端口作为 ``safe port`` (默认只有 ``443/80`` 等常规Internet服务)::

   acl Safe_ports port 22          # ssh

- 完成配置后，重启 ``squid`` 或者 ``reload`` 配置::

   sudo systemctl reload squid

ssh客户端proxy连接
=====================

要通过代理服务器访问服务器的ssh，需要使用 ``netcat`` 提供连接

例如，标准的ssh命令访问服务器::

   ssh huatai@192.168.6.253

而我现在客户端主机没有位于 ``192.168.6.0/24`` 网段，则通过以下代理命令::

   ssh huatai@192.168.6.253 -o "ProxyCommand nc --proxy 10.10.1.200:3128 %h %p"

  - ``ProxyCommand`` 告知ssh使用代理
  - ``nc`` 表明ssh将使用 ``nc`` 来建立和代理服务器之间的连接
  - ``%h`` 处理代理服务器的访问ssh服务器的主机名或IP地址，也就是会把 ``192.168.6.253`` 传递给squid代理服务器来代理访问后端SSH服务器
  - ``%p`` 处理代理服务器的访问ssh服务器的端口

如果想要简化命令参数，可以把代理配置添加到 ``~/.ssh.config`` 中::

   host * 
       ProxyCommand nc --proxy 10.10.1.200:3128 %h %p

``kex_exchange_identification`` 报错
---------------------------------------

我在 macOS上采用上述命令上述代理ssh连接遇到一个报错::

   kex_exchange_identification: Connection closed by remote host
   Connection closed by UNKNOWN port 65535

则在 ``ssh -v ...`` 可以看到 ``nc`` 不支持 ``--proxy`` 参数::

   .,.
   debug1: Local version string SSH-2.0-OpenSSH_8.6
   nc: unrecognized option `--proxy'
   Try `/usr/local/bin/nc --help' for more information.
   kex_exchange_identification: Connection closed by remote host
   Connection closed by UNKNOWN port 65535

不过， Linux上的 ``nc`` 命令有一个 ``-x`` 参数 ``[-x proxy_address[:port]] [hostname] [port[s]]`` ，所以修改命令::

   ssh huatai@192.168.6.253 -o "ProxyCommand nc -x 10.10.1.200:3218 %h %p"

很不幸，macOS的 ``nc`` 命令并不支持 ``-x`` 参数。

改到一个Linux虚拟机中，再次尝试::

   ssh -v huatai@192.168.6.253 -o "ProxyCommand nc -x 10.10.1.200:3218 %h:%p"

此时提示错误::

   debug1: Local version string SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.3
   kex_exchange_identification: Connection closed by remote host

看上去至少能够连接到后端的SSH服务器了

``kex_exchange_identification: Connection closed`` :时钟不同步
---------------------------------------------------------------

考虑到是SSH服务器拒绝连接，所以检查服务器端日志，同时下意识检查了以下服务器时间(太多教训了...)，果然发现了时钟不同步问题::

   # SSH服务器
   Thu Jan 20 03:22:00 PM CST 2022

   # SSH客户端
   Thu Jan 20 15:22:21 CST 2022

SSH服务器没有正确完成时钟同步，看来我部署 :ref:`priv_ntp` 还是存在纰漏，需要有个完善的 :ref:`priv_monitor` 来对基础服务进行全栈监控告警

- 检查 ``z-dev`` (SSH服务器)，发现实际上已经配置了 :ref:`systemd_timesyncd` ，但是由于疏漏，忘记配置默认启动::

   systemctl status systemd-timesyncd

检查输出当前没有启动::

   ○ systemd-timesyncd.service - Network Time Synchronization
        Loaded: loaded (/usr/lib/systemd/system/systemd-timesyncd.service; disable>
        Active: inactive (dead)
          Docs: man:systemd-timesyncd.service(8)

- 配置启动::

   sudo systemctl start systemd-timesyncd
   sudo systemctl enable systemd-timesyncd

启动后时钟同步，验证SSH客户端和SSH服务器时间一致。

然后再次测试SSH代理::

   ssh -v huatai@192.168.6.253 -o "ProxyCommand nc -x 192.168.6.200:3218 %h %p"

报错依旧::

   debug1: Local version string SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.3
   kex_exchange_identification: Connection closed by remote host

.. warning::

   暂时没有解决这个代理模式转内部SSH服务器的方法。不过，采用 ``nc`` 来建立通道的方法已经是非常 ``旧的方式`` ，最新的 ``openssh`` 已经不再需要 ``nc`` ，而可以直接内建功能实现 :ref:`ssh_proxycommand`

参考
=========

- `How to configure an SSH proxy server with Squid <https://fedoramagazine.org/configure-ssh-proxy-server/>`_
- `Use Squid as HTTP / HTTPS / SSH Proxy <https://www.squins.com/knowledge/squid-http-https-ssh-proxy/>`_
