.. _deploy_wireguard:

===================
部署WireGuard VPN
===================

.. note::

   `体验Wireguard的简单之美 <https://www.nixops.me/articles/wireguard-howtos.html>`_ 提到了WireGuard的优缺点。其中缺点(我未能验证，但至少目前我使用WG上网正常):

   - Wireguard专注实现简单可靠的加密，不关注流量混淆，容易被DPI检测到，同时由于特征明显，流量有可能被中继或在握手阶段阻断
   - wireguard配置简单且安全高效，适合服务器之间互联。由于国内udp限速及特征明显，不适合个人当梯子用。

安装
======

- 服务器端可以采用各种Linux发行版完成 `WireGuard Installation <https://www.wireguard.com/install/>`_ ，例如 Debian / Ubuntu ::

   apt install wireguard

对等加密隧道建立
=================

.. note::

   对等加密隧道连接给我们一个比较简单清晰的概览，不过我实际没有完整操作。我主要是通过后文的服务器、客户端配置来实现翻墙，所以本段仅整理记录。

- 每个加密通讯的双方都需要创建一个私钥和公钥的密钥对
- 实际上WireGuard的双方是完全互等的，输入命令可以完全相似，差别仅是将对端的公钥加入到连接，并指定对方IP地址为对端: 这样就能建立起加密通道

演示案例
-----------

物理主机IP:

- peerA: 192.168.1.1
- peerB: 192.168.1.2

建立的加密隧道 wg0 设备IP:

- peerA: 10.10.0.1
- peerB: 10.10.0.2

两边服务器执行密钥创建(完全一样的命令)
------------------------------------------

以下命令在 ``peerA`` 和 ``peerB`` 上执行，生成各自服务器的密钥对，命令完全一样:

- 创建一个私钥::

   (umask 0077; wg genkey > private)

.. note::

   建议只允许owner读写访问私钥，所以这里使用了 ``umask 0077`` 确保只有owner可以访问。不设置也行，就是提示一条信息::

      Warning: writing to world accessible file.
      Consider setting the umask to 077 and trying again.

- 创建公钥::

   wg pubkey < private > public

Peer建立连接
=============

点对点配置，双方将对方公钥加入

双方服务器启动wg0
-------------------

注意，双方服务器的 ``WG_IP`` 不同，命令的其他部分完全一致

- 在服务器端执行以下命令启动 ``wg0`` 设备::

   # peerA的 wg_ip 是 10.10.0.1 ，peerB的 wg_ip 是 10.10.0.2

在 peerA上执行::

   wg_ip=10.10.0.1
   ip link add wg0 type wireguard
   ip addr add ${wg_ip}/24 dev wg0
   wg set wg0 private-key ./private
   ip link set wg0 up

在 peerB上执行::

   wg_ip=10.10.0.2
   ip link add wg0 type wireguard
   ip addr add ${wg_ip}/24 dev wg0
   wg set wg0 private-key ./private
   ip link set wg0 up

- 启动连接，注意这个的公钥、 ``allowed-ips`` 和  ``endpoint`` 都是指对端的参数

在 peerA 上执行::

   wg set wg0 peer <peerB的公钥> allowed-ips 10.10.0.2/32 endpoint 192.168.1.2:51820

在 peerB 上执行::

   wg set wg0 peer <peerA的公钥> allowed-ips 10.10.0.1/32 endpoint 192.168.1.1:51820

此时加密网络就已经建立起来了，可以在各自服务器上ping对端的wg地址，中间的通讯都是加密的

服务器配置(强烈推荐)
=========================

前面我们建立了一个完全堆成配置的加密通讯，也就是我们需要知道对方的网络IP地址(公网地址)，才能配置 endpoint

现在我们部署一个internet上对外的服务器，等待客户端来连接(不知道客户端的公网IP)

在服务器上执行:

- 创建密钥对:

.. literalinclude:: deploy_wireguard/wg_genkey
   :language: bash
   :caption: 创建密钥对

- 配置 ``/etc/wireguard/wg0.conf`` :

.. literalinclude:: deploy_wireguard/wg0.conf
   :language: bash
   :caption: 服务端/etc/wireguard/wg0.conf

.. note::

   建议修订配置中端口，著名端口可能被屏蔽

.. note::

   这里客户端部分，也就是 ``[Peer]`` 部分不用手工配置，后面通过命令行添加后，重启一次 ``wg0`` 会自动刷新

- 启动服务端接口::

   sudo wg-quick up wg0

- 添加NAT流量:

.. literalinclude:: deploy_wireguard/sysctl
   :language: bash

客户端
---------

- 客户端也要像服务器端一样创建一个密钥对:

.. literalinclude:: deploy_wireguard/wg_genkey
   :language: bash
   :caption: 创建密钥对

- 回到服务器端，将刚才生成的客户端公钥以及IP添加到允许列表 ``peer`` 中::

   wg set wg0 peer <客户端的公钥> allowed-ips 10.10.0.2/32

此时在服务器端执行一次 ``wg0`` 重启就会看到客户端公钥和对应IP地址被刷入配置文件 ``/etc/wireguard/wg0.conf`` 中::

   wg-quick down wg0
   wg-quick up wg0

- 客户端也配置一个 ``/etc/wireguard/wg0.conf`` 

.. literalinclude:: deploy_wireguard/wg0.conf_client
   :language: bash
   :caption: 客户端/etc/wireguard/wg0.conf

- 启动::

   sudo wg-quick up wg0

此时在服务器上检查::

   sudo wg

可以看到类似::

   interface: wg0
     public key: <server public key>
     private key: (hidden)
     listening port: 46980
   
   peer: <client public key>
     endpoint: 183.192.17.131:9912
     allowed ips: 10.10.0.2/32
     latest handshake: 23 minutes, 12 seconds ago
     transfer: 23.13 KiB received, 12.62 KiB sent

并且，服务器上可以ping通客户端的IP地址 ``10.10.0.2``

.. note::

   注意，客户端要配置DNS，否则即使网络通如果没有解析则无法访问internet

参考
======

- `WireGuard Quick Start <https://www.wireguard.com/quickstart/>`_
- `arch linux: WireGuard <https://wiki.archlinux.org/title/WireGuard>`_ arch文档作为印证补充，但是该文档似乎没有按照WireGuard官网及时更新
- `如何配置wireguard服务端及客户端 <https://y2k38.github.io/posts/how-to-setup-wireguard-vpn-server/>`_ 非常好的配置说明，实践通过。官方qucickstart英文文档写得实在是不清晰，我还是参考这篇文档完成的
- `体验Wireguard的简单之美 <https://www.nixops.me/articles/wireguard-howtos.html>`_
- `WireGuard 教程：WireGuard 的搭建使用与配置详解 <https://icloudnative.io/posts/wireguard-docs-practice/>`_
- `如何在Ubuntu 20.04安装WireGuard VPN <https://www.myfreax.com/how-to-set-up-wireguard-vpn-on-ubuntu-20-04/>`_
