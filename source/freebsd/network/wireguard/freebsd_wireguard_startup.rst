.. _freebsd_wireguard_startup:

==========================
FreeBSD WireGuard快速起步
==========================

.. warning::

   :ref:`wireguard` 是VPN协议，只是用来提供加密隧道，但是没有实现伪装。这意味着WireGuard设计时就没有考虑混淆，UDP协议特征明显，导致防火墙非常容易精准识别和阻断。

   也就是说 **安装部署WireGuard只提供加密通讯，但是无法** :ref:`across_the_great_wall`

:ref:`wireguard` 是一个易于部署和配置加密网络通道的VPN技术，在很多VPN应用中，WireGuard已经逐步取代了IPSec或OpenVPN。

WireGuard同时提供内核和用户空间实现。第一个WireGuard内核实现是在Linux内核提供的，现在也移植到FreeBSD以及其他BSD版本。

在FreeBSD中，WireGuard的内核模式部分通过 ``wireguard-kmod`` 软件包获得，而 WireGuard的主要用户空间实现则是一个golang应用，通过 ``wireguard-go`` 软件包获得。

.. note::

   在 :ref:`macos` 环境通过 :ref:`homebrew` 也可以安装 ``WireGuard`` ，其中客户端名称也是 ``wireguard-go`` ，服务端也是 ``wireguard-tools``

WireGuard网络配置由接口(interfaces)和对等点(peers)组成。每个interface由其私钥定义，peers则由公钥和允许使用的地址定义。这样就形成了一个使用加密密钥路由的网络(cryptokey routing)。

安装
=======

- 服务器端只需要安装 ``wireguard-tools`` ，这个软件包包含了 ``wireguard`` 软件包以及必要的管理WireGuard接口的 ``wg`` , ``wg-quick`` :

.. literalinclude:: freebsd_wireguard_startup/install_wireguard
   :caption: 在服务器端安装 ``wireguard-tools``

配置
========

WireGuard服务器
-----------------

.. note::

   这里配置工作执行前， :ref:`freebsd_init` 工作已经完成(创建了具有 ``sudo`` 权限的admin账号)，以下操作使用 ``admin`` 账号完成。

- 修改 WireGuard ``/usr/local/etc/wireguard`` 目录权限，以便 ``admin`` 用户(属于 ``wheel`` 组)能够读写该目录(该目录属于 ``root`` 和组 ``wheel`` )

.. literalinclude:: freebsd_wireguard_startup/chmod
   :caption: 修订 ``/usr/local/etc/wireguard`` 目录权限，允许 ``admin`` 用户读写

- 在 ``/usr/local/etc/wireguard`` 目录中创建私钥，然后再根据生成的私钥创建公钥

.. literalinclude:: freebsd_wireguard_startup/server.key
   :caption: 创建服务器私钥以及对应公钥

- 创建WireGuard服务器配置 ``/usr/local/etc/wireguard/wg0.conf``

.. literalinclude:: freebsd_wireguard_startup/wg0.conf
   :caption: WireGuard服务器配置 ``/usr/local/etc/wireguard/wg0.conf``

参数解释:

  - ``Address`` 是使用 ``10.10.0.0/24`` 网段的WireGuard接口，使用的服务器地址是 ``10.10.0.1``
  - ``SaveConfig`` 设置接口shutdown时候保存WireGuard的运行时配置
  - ``ListenPort`` 设置WireGuard接口监听端口
  - ``PrivateKey`` 设置WireGuard服务器的私有密钥

WireGuard客户端
-------------------

- 配置WireGuard Client:

WireGuard客户端配置激活使用WireGuard服务器接口的公钥和公开IP地址信息来连接WireGuard服务器: 每个WireGuard客户端使用非服务器允许的唯一的公钥来创建tunnel

.. literalinclude:: freebsd_wireguard_startup/client.key
   :caption: 生成WireGuard Client密钥对，创建的方法和Server密钥对是一样的

如果使用macOS上的 ``WireGuard`` 图形客户端(可以从App Store安装)，则客户端GUI提供了一个自动生成客户端密钥对的功能:

.. figure:: ../../../_static/freebsd/network/wireguard/wireguard_client.png

   点击 ``Add Empty tunnel...`` 按钮

``WireGuard`` 图形客户端会自动生成一个客户端密钥对(也就省却了前述的命令行生成)

.. figure:: ../../../_static/freebsd/network/wireguard/wireguard_client-1.png

   ``WireGuard`` 图形客户端添加Tunnels会自动生成客户端密钥对

- 配置客户端 ``/usr/local/etc/wireguard/wg_client.conf`` 

.. literalinclude:: freebsd_wireguard_startup/wg_client.conf
   :caption: WireGuard客户端配置 ``/usr/local/etc/wireguard/wg_client.conf``

.. note::

   FreeBSD客户端配置我还没有验证，目前使用的客户端是 macOS 上 ``WireGuard`` 图形客户端

如果使用macOS上的 ``WireGuard`` 图形客户端，则在填写客户端配置类似如下( ``图形客户端能够校验配置语法`` 非常方便):

.. literalinclude:: freebsd_wireguard_startup/wireguard_client.conf
   :caption: WireGuard图形客户端配置

参数解释:

  - ``PrivateKey`` : WireGuard客户端私钥
  - ``Address`` : 设置客户端使用的私有IP地址和子网，也就是WireGuard Tunnel中使用的地址
  - ``PublicKey`` : 设置为 ``服务器`` 的公钥
  - ``AllowedIPs`` : 指定允许链接到WireGuard VPN连接的IP地址和子网。这个值 ``0.0.0.0/0`` 所有IP地址和允许网络接口访问VPN连接
  - ``Endpoint`` : 设置为 WireGuard 服务器的公网(Internet) IP地址，也就是客户端将要连接的服务器IP
  - ``PersistentKvipalive`` : 每 ``30秒`` 发送数据包给WireGuard服务器来保持连接活跃

配置服务器
============

- 将上文生成的客户端公钥配置添加到服务器的 ``/usr/local/etc/wireguard/wg0.conf``

.. literalinclude:: freebsd_wireguard_startup/wg0_add_client.conf
   :caption: ``/usr/local/etc/wireguard/wg0.conf`` 添加客户端的公钥配置
   :emphasize-lines: 8,10,11

这里的配置修订也可以通过命令行动态添加:

.. literalinclude:: freebsd_wireguard_startup/wg0_add_client
   :caption: 动态添加客户端

启动服务器
============

- 执行以下命令激活 ``wg0`` 以及配置服务器启动时启动 ``WireGuard`` :

.. literalinclude:: freebsd_wireguard_startup/start_wireguard
   :caption: 启动WireGuard

启动后检查状态输出类似:

.. literalinclude:: freebsd_wireguard_startup/wireguard_status_output
   :caption: ``wireguard`` 服务状态
   :emphasize-lines: 6,7

启动客户端
===========

- 启动客户端命令行:

.. literalinclude:: freebsd_wireguard_startup/start_wireguard_client
   :caption: 启动WireGuard客户端

此时客户端就会链接到服务器上

检查
=======

- 在服务器上再次执行 ``service wireguard status`` 就会看到状态更新: 显示出客户端的更新状态

.. literalinclude:: freebsd_wireguard_startup/wireguard_client_connected_status_output
   :caption: ``wireguard`` 客户端连接以后的状态变化
   :emphasize-lines: 7,9,10

这表明VPN连接已经建立

此时在客户端 ``ping 10.10.0.1`` (也就是ping Tunnel的另一端地址)，就会看到正常的echo返回，表明VPN工作正常。

.. warning::

   现在客户端还不能通过VPN访问Internet，还需要服务器上设置防火墙路由

设置防火墙
============

- 修订 ``sysctl.conf`` 配置，激活IP forwarding:

.. literalinclude:: freebsd_wireguard_startup/ip_forwarding
   :caption: 启用IP forwarding

- 激活 :ref:`pfsense` 包过滤防火墙:

.. literalinclude:: freebsd_wireguard_startup/pf
   :caption: 激活包过滤防火墙

- 检查网络接口，执行 ``ifconfig`` ，可以看到如下输出:

.. literalinclude:: freebsd_wireguard_startup/ifconfig_output
   :caption: ``ifconfig`` 输出
   :emphasize-lines: 1,17

这里可以看到两个接口，一个是服务器的网卡接口，另一个就是WireGuard接口

- 配置 ``/etc/pf.conf`` :

.. literalinclude:: freebsd_wireguard_startup/pf.conf
   :caption: 配置 ``/etc/pf.conf``

- 启动pf:

.. literalinclude:: freebsd_wireguard_startup/start_pf
   :caption: 启动pf

参考
======

- `How to Install Wireguard VPN on FreeBSD 14.0 <https://docs.vultr.com/how-to-install-wireguard-vpn-on-freebsd-14-0>`_ 主要参考，因为我主要就是通过客户端访问服务器的VPN建立
- `Simple and Secure VPN in FreeBSD – Introducing WireGuard <https://klarasystems.com/articles/simple-and-secure-vpn-in-freebsd/>`_
