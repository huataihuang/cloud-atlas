.. _deploy_wireguard:

===================
部署WireGuard VPN
===================

WireGuard的配置力求精简

安装
======

- 服务器端可以采用各种Linux发行版完成 `WireGuard Installation <https://www.wireguard.com/install/>`_ ，例如 Debian / Ubuntu ::

   apt install wireguard

生成密钥
=========

每个加密通讯的双方都需要创建一个私钥和公钥的密钥对

- 创建一个私钥::

   (umask 0077; wg genkey > peer_A.key)

.. note::

   建议只允许owner读写访问私钥，所以这里使用了 ``umask 0077`` 确保只有owner可以访问

- 创建公钥::

   wg pubkey < peer_A.key > peer_A.pub

以上两条命令也和可以合并成::

   wg genkey | (umask 0077 && tee peer_A.key) | wg pubkey > peer_A.pub

对于每个连接对(peer pair)，如A,B和C，应该创建3个独立的预共享密钥，每个peer pair使用一个::

   wg genpsk > peer_A-peer_B.psk
   wg genpsk > peer_A-peer_C.psk
   wg genpsk > peer_B-peer_C.psk

修饰密钥(Vanity Keys)
======================

目前WireGuard不支持注释或者将易于记忆的名称附加到key上面，这使得识别密钥的所有者变得困难。一种解决方法是生成一个包含易于理解名字的公钥(例如包含所有人姓名或者主机名)。对于企业用户，通常每个员工会分配一个企业邮箱，这是唯一标识的名字，所以可以用来作为公钥名字的一部分。

Wireguard VPN 使用 Curve25519 密钥对，并在状态显示中显示 Base64 编码的公钥。

`wireguard-vanity-address <https://github.com/warner/wireguard-vanity-address>`_ 提供搜索公钥字符串的便利，可以快速在大量公钥找定位找到匹配的公钥

Peer配置
=============

参考
======

- `WireGuard Quick Start <https://www.wireguard.com/quickstart/>`_
- `arch linux: WireGuard <https://wiki.archlinux.org/title/WireGuard>`_ arch文档作为印证补充，但是该文档似乎没有按照WireGuard官网及时更新
