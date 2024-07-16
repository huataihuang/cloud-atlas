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

   本文方案实践服务器和客户端都基于Ubuntu 18.10系统，其他发行版(例如 :ref:`openconnect_vpn_arch_linux` )可能会有一些差异。此外，我也在 :ref:`redhat_linux` 系的AlmaLinux上部署，其中的一些安装差异在本文注明

   详细操作步骤参考 `在Ubuntu部署OpenConnect VPN服务器 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/security/vpn/openconnect/deploy_ocserv_vpn_server_on_ubuntu.md>`_

- Debian/Ubuntu 安装ocserv::

   apt install ocserv

- RedHat/AlmaLinux 需要通过 EPEL 仓库来安装ocserv:

.. literalinclude:: openconnect_vpn/redhat_install_ocserv
   :caption: :ref:`redhat_linux` 通过EPEL安装ocserv

安装完成后，OpenConnect VPN服务自动启动，可以通过 ``systemctl status ocserv`` 检查。

源代码编译
------------

在 :ref:`arch_linux` 上安装 ``ocserv`` 比较麻烦一些，需要通过 :ref:`archlinux_aur` 编译安装，也就是先安装 ``yay`` ，然后执行 ``yay -S ocserv`` ，不过在2023年11月的尝试安装失败，原因是 ocserv 依赖的 ``freeradius-client`` (AUR) 引用了一个已经不再维护的 ``libpcl`` ，所以直接安装会失败。所以我实际安装是通过源代码编译安装的:

.. literalinclude:: openconnect_vpn/build_ocserv
   :caption: 源代码编译安装 ocserv

服务起停配置文件我采用了 :ref:`ubuntu_linux` 提供的 :ref:`systemd` 配置:

- ``/lib/systemd/system/ocserv.service`` :

.. literalinclude:: openconnect_vpn/ocserv.service
   :caption: :ref:`ubuntu_linux` 提供的ocserv启动systemd配置

- 创建 ``/etc/ocserv/ocserv.conf`` (从 :ref:`ubuntu_linux` 发行版默认配置提取):

.. literalinclude:: openconnect_vpn/ocserv.conf
   :caption: :ref:`ubuntu_linux` 提供的ocserv默认配置

.. note::

   :ref:`arch_linux` 仓库提供软件包上述配置文件可能已经就绪(不过我尚未实践 :ref:`archlinux_aur` 安装成功)

配置(Let's Encrypt证书)
============================

- 安装Let's Encrypt客户端（Certbot）::

   sudo apt install software-properties-common
   sudo add-apt-repository ppa:certbot/certbot
   sudo apt update
   sudo apt install certbot

.. warning::

   本文使用了 ``example.com`` 作为案例域名，实际操作时，请使用你自己的正确域名

- 确保80端口nginx服务暂停，然后从Let's Encrypt获取一个TLS证书:

.. literalinclude:: openconnect_vpn/certboot_get_cert
   :language: bash
   :caption: 使用certbot获取letsencrypt证书

.. note::

   在执行上述 ``certbot`` 命令获取证书前，需要暂停80端口的nginx服务，因为 ``certbot`` 会监听该端口来迎接Let's Encrypt验证域名 ``vpn.example.com`` (也就是你执行生成证书的服务器): ``--preferred-challenges http ... -d vpn.exapmle.com``
 
   否则会报错:

   .. literalinclude:: openconnect_vpn/certboot_get_cert_err_output
      :language: bash
      :caption: 暂停80端口nginx，否则使用certbot获取letsencrypt证书时报错

一切正常的话，会收到如下正确获得并存储证书的信息:

.. literalinclude:: openconnect_vpn/certboot_get_cert_output
   :caption: 使用certbot获取letsencrypt证书正确完成时输出信息

.. warning::

   Let's Encrypt提供的证书有效期3个月，所以每3个月需要使用上述命令重新生成一次证书。建议 :ref:`cron_certbot_renew`

- 修改ocserv配置文件 ``/etc/ocserv/ocserv.conf`` :

.. literalinclude:: openconnect_vpn/ocserv.conf
   :language: bash
   :caption: 配置 /etc/ocserv/ocserv.conf 添加Let’s Encrypt证书
   :emphasize-lines: 13,14

配置(字签名证书)
==================

自签名证书需要使用 ``guntls`` 工具:

- Debian/Ubuntu安装 ``gnutils`` 工具:

.. literalinclude:: openconnect_vpn/apt_gnutils
   :caption: 使用 :ref:`apt` 安装 ``gnutls-bin``

- Red Hat Linux/CentOS/AlmaLinux 安装 ``gnutls`` 工具:

.. literalinclude:: openconnect_vpn/dnf_gnutils
   :caption: 使用 :ref:`dnf` 安装 ``gnutls-utils``

- 首先需要为签发证书准备一个私钥，执行以下命令生成 ``ca-privkey.pem`` 私钥:

.. literalinclude:: openconnect_vpn/generate_privkey
   :caption: 生成用于签发证书的私钥

- 然后创建一个模板证书文件 ``ca-cert.cfg`` :

.. literalinclude:: openconnect_vpn/ca-cert.cfg
   :caption: 证书模板文件 ``ca-cert.cfg``

- 结合上面的两个文件，即用私钥 ``ca-privkey.pem`` 和证书模板文件 ``ca-cert.cfg`` 生成字签名证书 ``ca-cert.pem``

.. literalinclude:: openconnect_vpn/generate_ca
   :caption: 生成服务器CA证书

部署运行
==============

- 重启ocserv::

   sudo systemctl restart ocserv

- 创建VPN账号::

   sudo ocpasswd -c /etc/ocserv/ocpasswd username

- 激活IP Forwarding （重要步骤）

修改 ``/etc/sysctl.conf`` 添加配置并激活:

.. literalinclude:: openconnect_vpn/ip_forwarding
   :caption: 激活IP Forwarding

- 配置防火墙的IP Masquerading (这里假设网卡接口是 ``ens3`` ）以及允许端口访问,配置好以后保存配置(以便后续通过 :ref:`systemd` 启动恢复 :

.. literalinclude:: openconnect_vpn/iptables
   :caption: iptables激活IP MASQUERATE

- 创建一个systemd服务来启动时恢复iptables规则，编辑 ``/etc/systemd/system/iptables-restore.service`` :

.. literalinclude:: openconnect_vpn/iptables_systemd
   :caption: 配置systemd服务在启动时恢复iptables规则

- 激活 ``iptables-restore`` 服务:

.. literalinclude:: openconnect_vpn/enable_iptables_systemd
   :caption: 激活systemd服务在启动时恢复iptables规则

使用OpenConnect VPN Client
=============================

.. note::

   详细操作步骤参考 `使用OpenConnect客户端 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/security/vpn/openconnect/openconnect.md>`_

- 安装 OpenConnect::

   sudo apt install openconnect

- 连接服务器::

   sudo openconnect <VPN服务器域名>

连接建立以后，就可以正常使用apt安装Google软件仓库中的软件。

OpenConnect VPN Client使用技巧
--------------------------------

我在使用 ``openconnect`` 遇到以下几个问题需要解决:

- 需要手工输入用户名和密码
- 服务器证书过期后每次都要手工接受服务器证书 (早期版本可以使用 ``--no-cert-check`` 参数绕过，但是现在不行，必须明确接受服务器证书)

``openconnect`` 提供了 ``-u`` 参数传递账号名，但是使用 ``-p`` 参数传递密码失败，所以改成 ``--passwd-on-stdin`` 从管道获取密码:

.. literalinclude:: openconnect_vpn/openconnect_passwd-on-stdin
   :caption: openconnect从标准输入(管道)获取登陆密码

对于接受服务器证书的问题，可以使用 ``--servercert`` 参数来传递服务器证书，这样就不需要每次都手工确认一次了，所以完整的命令

.. literalinclude:: openconnect_vpn/openconnect_passwd-on-stdin_servercert
   :caption: openconnect从标准输入(管道)获取登陆密码并且使用服务器证书

Cisco AnyConnect VPN Client
=============================

`Cisco AnyConnnect VPN Client <https://software.cisco.com/download/home/286281283/type/282364313/release/4.8.02045>`_ 和OpenConnect VPN Server (ocserv) 兼容，所以可以从Cisco官方网站下载客户端。

.. _change_ocserv_port:

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
- `Set up Certificate Authentication in OpenConnect VPN Server (ocserv) <https://www.linuxbabe.com/ubuntu/certificate-authentication-openconnect-vpn-server-ocserv>`_ 设置服务器自签名证书和客户端证书
- `How to Set up an OpenConnect VPN Server <https://www.alibabacloud.com/blog/how-to-set-up-an-openconnect-vpn-server_595185>`_
- `How to run openconnect with username and password in a line in the terminal? <https://askubuntu.com/questions/1043024/how-to-run-openconnect-with-username-and-password-in-a-line-in-the-terminal>`_
