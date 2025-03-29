.. _openconnect_vpn_arch_linux:

===================================
在Arch Linux上部署OpenConnect VPN
===================================

OpenConnect VPN Server，也称为 ``ocserv`` ，采用OpenConnect SSL VPN协议，并且和Cisco AnyConnect SSL VPN协议的客户端兼容。目前不仅加密安全性好，而且客户端可以跨平台，主流操作系统以及手机操作系统都可以使用。

选择OpenConnect VPN Server( ``ocserv`` )的主要原因如下:

- SSL VPN协议安全性较好，被GFW干扰的可能性较低(GFW不太可能完全屏蔽SSL流量，毕竟HTTPS是现代互联网的主流)
- 跨平台通用客户端，这样我可以在Linux,macOS,Windows以及Android,iOS平台使用

.. note::

   由于我将VPS服务器从 :ref:`ubuntu_linux` 更改到 :ref:`arch_linux` ，所以重新部署Ocserv服务(OpenConnect VPN)

   我力求在 :ref:`openconnect_vpn` 基础上整合近期的部署改进，以实现完善的个人VPN部署 :ref:`across_the_great_wall`

准备工作
=========

- 需要购买一台海外VPS
- 需要一个域名，在注册域名中添加一条记录指向新购买VPS的IP地址( ``vpn.example.com`` 解析到将要部署的服务器IP地址)

.. note::

   使用Let’s Encrypt签发的证书是针对域名的:

   - 使用 ``certbot`` 生成证书时候，Let's Encrypt会通过你签发证书的域名访问该域名对应IP的80端口进行验证，所以必须准备好部署服务器的域名解析
   - 如果暂时无法准备好域名解析，那么可以自己手工签发一个证书临时使用

安装ocserv
===========

:ref:`arch_linux` 发行版只包括了 ``openconnect`` 客户端，但是没有直接提供 ``ocserv`` 服务端。在 Arch Linux上安装 ``ocserv`` 是通过 :ref:`archlinux_aur` 部署的。

- 首先完成 :ref:`archlinux_aur` 管理工具 ``yay`` 安装:

.. literalinclude:: ../../../arch_linux/archlinux_aur/install_yay
   :caption: 编译安装yay

- 使用 ``yay`` 安装 ``ocserv`` :

.. literalinclude:: openconnect_vpn_arch_linux/yay_install_ocserv
   :caption: 使用 ``yay`` 安装 ``ocserv``

Let's Encrpyt Certbot生成证书(推荐)
======================================

Arch linux官方提供了Let's Encrypt客户端Certbot，所以安装非常简单:

.. literalinclude:: openconnect_vpn_arch_linux/pacman_certbot
   :caption: 安装certbot

- 确保80端口没有使用中，然后从Let’s Encrypt获取一个TLS证书:

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

手工生成临时使用自签名证书(可选)
=================================

由于我暂时没有搞定域名注册，所以我也临时使用了以下命令生成证书(正式使用还是要采用上文Let's Encrypt证书):

.. literalinclude:: openconnect_vpn_arch_linux/generate_cert
   :caption: 使用 ``openssl`` 创建自签名证书

配置ocserv
============

:ref:`archlinux_aur` 提供的 ``ocserv`` 软件包提供了配置文件 ``/etc/ocserv.conf`` 和 ``/etc/ocserv-passwd`` ，但是我发现实际上没有使用( ``systemctl start ocserv`` 显示使用 ``/etc/ocserv/ocserv.conf`` )

.. literalinclude:: openconnect_vpn_arch_linux/prepare
   :caption: 准备ocserv目录及配置文件

修订ocserv配置文件 ``/etc/ocserv/ocserv.config``

- 如果使用自签名证书，配置如下:

.. literalinclude:: openconnect_vpn_arch_linux/ocserv_self.config
   :caption: 自签名证书配置

- 创建VPN账号:



启动ocserv
===========

- 启动ocserv:

.. literalinclude:: openconnect_vpn_arch_linux/start_ocserv
   :caption: 使用systemd启动ocserv

IP转发和MASQUERADE
===================

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

错误排查
===================

客户端连接错误排查
------------------

使用Cisco Secure Client连接认证后失败，检查日志:

.. literalinclude:: openconnect_vpn_arch_linux/journalctl_ocserv
   :caption: 使用 :ref:`journalctl` 检查ocserv

日志显示找不到 tun 设备:

.. literalinclude:: openconnect_vpn_arch_linux/journalctl_ocserv_output
   :caption: ocserv日志显示找不到tun设备

但是实际上 ``/dev/net/tun`` 设备文件存在，我参考 `OpenVPN 2.3.1 - ERROR: Cannot open TUN/TAP dev /dev/net/tun <https://bbs.archlinux.org/viewtopic.php?id=163377>`_ ，看起来是我最近做了一次系统升级，但是升级后没有重启系统导致的。重启系统之后，该问题消失

客户端连接后无法访问internet
------------------------------

我使用Cisco Secure Client连接VPN之后，发现无法访问Internet

- 已经确认服务器开启了 ``net.ipv4.ip_forward = 1``

**乌龙了** 忘记配置防火墙IP Masquerading，执行以下命令开启(上文步骤已经补充):

.. literalinclude:: openconnect_vpn_arch_linux/ip_masquerade
   :caption: 启用IP Masquerade

.. note::

   实际需要参考上文，通过 :ref:`systemd` 自动回复防火墙IP Masquerading

参考
=======

- `archlinux wiki: OpenConnect <https://wiki.archlinux.org/title/OpenConnect>`_
- `Setting up OpenConnect Server on ArchLinux: VPN Connection <https://usercomp.com/news/1143932/openconnect-server-setup-on-archlinux>`_
