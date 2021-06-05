.. _openconnect_vpn:

===================
OpenConnect VPN
===================

Kubernetes是Google开发的容器编排系统，当你开始学习和测试Kubernetes时候，你会发现，很多基于Google的软件仓库无法访问，会给你的学习和工作带来极大的困扰。

OpenConnect VPN Server，也称为 ``ocserv`` ，采用OpenConnect SSL VPN协议，并且和Cisco AnyConnect SSL VPN协议的客户端兼容。目前不仅加密安全性好，而且客户端可以跨平台，主流操作系统以及手机操作系统都可以使用。

.. note::

   如果你使用Google的软件仓库来安装最新版本的Kubernetes，并按照Google的文档进行实践，需要一个科学上网的梯子来帮助你。

- 准备工作：

  - 需要购买一台海外VPS
  - 需要一个域名，在注册域名中添加一条记录指向新购买VPS的IP地址

.. note::

   使用Let's Encrypt签发的证书是针对域名的，所以不仅需要购买VPS，还需要提前准备好域名。

部署OpenConnect VPN Server
======================================

.. note::

   本文方案实践服务器和客户端都基于Ubuntu 18.10系统，其他发行版可能会有一些差异。

   详细操作步骤参考 `在Ubuntu部署OpenConnect VPN服务器 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/security/vpn/openconnect/deploy_ocserv_vpn_server_on_ubuntu.md>`_

- 安装ocserv::

   apt install ocserv

安装完成后，OpenConnect VPN服务自动启动，可以通过 ``systemctl status ocserv`` 检查。

- 安装Let's Encrypt客户端（Certbot）::

   sudo apt install software-properties-common
   sudo add-apt-repository ppa:certbot/certbot
   sudo apt update
   sudo apt install certbot

- 从Let's Encrypt获取一个TLS证书::

   sudo certbot certonly --standalone --preferred-challenges http --agree-tos --email your-email-address -d vpn.example.com

- 修改ocserv配置文件 ``/etc/ocserv/ocserv.conf`` ::

   # 以下行注释关闭使用系统账号登陆
   # auth = "pam[gid-min=1000]"
   
   # 添加以下行表示独立密码文件认证
   auth = "plain[passwd=/etc/ocserv/ocpasswd]"
   
   # 只开启TCP端口，关闭UDP端口，以便使用BBR加速
   tcp-port = 443
   # udp-port = 443
   
   # 修改证书，注释前两行，添加后两行，表示使用Let's Encrypt服务器证书
   # server-cert = /etc/ssl/certs/ssl-cert-snakeoil.pem
   # server-key = /etc/ssl/private/ssl-cert-snakeoil.key
   server-cert = /etc/letsencrypt/live/vpn.example.com/fullchain.pem
   server-key = /etc/letsencrypt/live/vpn.example.com/privkey.pem
   
   # 设置客户端最大连接数量，默认是16
   max-clients = 16
   # 每个用户并发设备数量
   max-same-clients = 2
   
   # 启用MTU discovery以提高性能
   try-mtu-discovery = false
   
   # 设置默认域名为vpn.example.com
   default-domain = vpn.example.com
   
   # 修改IPv4网段配置，注意不要和本地的IP网段重合
   ipv4-network = 10.10.10.0
   
   # 将所有DNS查询都通过VPN（防止受到DNS污染）
   tunnel-all-dns = true
   
   # 设置使用Google的公共DNS
   dns = 8.8.8.8
   
   # 注释掉所有路由参数
   # route = 10.10.10.0/255.255.255.0
   # route = 192.168.0.0/255.255.0.0
   # route = fef4:db8:1000:1001::/64
   # no-route = 192.168.5.0/255.255.255.0

- 重启ocserv::

   sudo systemctl restart ocserv

- 创建VPN账号::

   sudo ocpasswd -c /etc/ocserv/ocpasswd username

- 激活IP Forwarding （重要步骤）

修改 ``/etc/sysctl.conf`` 添加::

   net.ipv4.ip_forward = 1

然后执行::

   sudo sysctl -p

- 配置防火墙的IP Masquerading (这里加设网卡接口是 ``ens3`` ） ::

   sudo iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE

- 在防火墙上开启端口443::

   sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
   sudo iptables -I INPUT -p udp --dport 443 -j ACCEPT

保存防火墙配置::

   sudo iptables-save > /etc/iptables.rules

- 创建一个systemd服务来启动时恢复iptables规则，编辑 ``/etc/systemd/system/iptables-restore.service`` ::

   [Unit]
   Description=Packet Filtering Framework
   Before=network-pre.target
   Wants=network-pre.target
   
   [Service]
   Type=oneshot
   ExecStart=/sbin/iptables-restore /etc/iptables.rules
   ExecReload=/sbin/iptables-restore /etc/iptables.rules
   RemainAfterExit=yes
   
   [Install]
   WantedBy=multi-user.target

- 激活 ``iptables-restore`` 服务::

   sudo systemctl daemon-reload
   sudo systemctl enable iptables-restore

使用OpenConnect VPN Client
=============================

.. note::

   详细操作步骤参考 `使用OpenConnect客户端 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/security/vpn/openconnect/openconnect.md>`_

- 安装 OpenConnect::

   sudo apt install openconnect

- 连接服务器::

   sudo openconnect <VPN服务器域名>

连接建立以后，就可以正常使用apt安装Google软件仓库中的软件。

Cisco AnyConnect VPN Client
=============================

`Cisco AnyConnnect VPN Client <https://software.cisco.com/download/home/286281283/type/282364313/release/4.8.02045>`_ 和OpenConnect VPN Server (ocserv) 兼容，所以可以从Cisco官方网站下载客户端。

修改ocserv端口
================

如果在同一台主机上部署ocserv vpn server和WEB服务，例如 :ref:`deploy_ghost_cms` ，则会遇到端口冲突问题：因为VPN也同样使用了https端口443。

解决的方法是：调整VPN Server的端口，修订成 ``404`` 端口：

- 修改  ``/etc/ocserv/ocserv.conf`` ::

   tcp-port = 404
   udp-port = 404

- 修改 ``/lib/systemd/system/ocserv.socket`` Socket端口对应监听::

   [Socket]
   ListenStream=404
   ListenDatagram=404

- 重新加载配置::

   systemctl reload-daemon

- 重启服务::

   systemctl restart ocserv

参考
=======

- `Set up OpenConnect VPN Server (ocserv) on Ubuntu 16.04/18.04 with Let’s Encrypt <https://www.linuxbabe.com/ubuntu/openconnect-vpn-server-ocserv-ubuntu-16-04-17-10-lets-encrypt>`_
- `How to Set up an OpenConnect VPN Server <https://www.alibabacloud.com/blog/how-to-set-up-an-openconnect-vpn-server_595185>`_
