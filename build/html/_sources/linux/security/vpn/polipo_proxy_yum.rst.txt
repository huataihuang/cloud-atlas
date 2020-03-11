.. _polipo_proxy_yum:

========================
Polipo代理和YUM代理配置
========================

在部署 :ref:`kubernetes` 时我们需要使用 :ref:`openconnect_vpn` 来搭建翻墙的梯子，以便能够从Google仓库安装Kubernetes。这在最初 :ref:`kvm_docker_in_studio` 模拟构建使用 :ref:`libvirt_nat_network` 是可行的：

- 在物理主机上使用openconnect打通VPN
- 所有运行在libvirt的NAT网络中的KVM虚拟机通过物理主机的IP masquerade模式共享物理主机的VPN链路

但是，在物理主机上部署kubernetes时，如果同时物理机上启用了VPN接口会导致困扰，因为kubeadm初始化会使用 ``tun0`` VPN接口(包括了默认路由)进行配置，所以一旦关闭VPN会触发Kubernetes无法使用。详见 :ref:`prepare_for_k8s_install` 遇到的问题，解决的方法就是本文思路：

- 在局域网内部选择一台物理服务器部署openconnect VPN客户端，架好梯子
- 在这台物理服务器上部署polipo代理软件
- 配置所有部署Kubernetes的主机YUM使用polipo代理访问Internet进行软件包安装

Polipo
=========

`Polipo代理服务器 <http://www.pps.univ-paris-diderot.fr/~jch/software/polipo/>`_ 是一个非常小巧快速的缓存型web代理服务器。虽然Polipo被设计成个人或者小型团队私用，但是也可以用于大型组织。

Polipo具有以下一些特点：

- 如果确定远程服务器支持的话，Polipo就会使用HTTP/1.1 ``pipelining`` ，这样进入的请求将管道化或者再多个连接进入并行模式（这个比简单使用持久化连接的代理服务器，如Squid，要更高效）
- 如果一个下载被中断，Polipo会缓存这个会话的 ``initial segement`` ，这样后续如果需要，可以使用 ``Range`` 请求来继续完成
- Polipo可以在客户端发送HTTP/1.0请求转发给后端服务器时升级为HTTP/1.1请求，并且自动转换
- Polipo支持IPv6
- Polipo可选使用 ``Poor Man's Multiplexing`` 来减少进一步延迟。
- 由于支持SOCKS协议，Polipo可以和 ``tor`` 匿名网络一起使用
- Polipo支持简单的过滤，可以用来移除一些广告和增加私密性。

.. note::

   ``pipelining`` - 使用持久化连接时，有可能转换成管道化或流化请求，例如，在一个连接中发送多个请求而不用等待请求返回。这种技术使得服务器更快响应减少延迟。另外，由于多个请求在一个数据包中发送，管道化减少网络流量。管道化已经是一种常用技术，但是HTTP 1.0不支持管道化。HTTP 1.1在使用持久化连接的服务器实现要求管道化支持，但是有些存在bug的服务器虽然声称自己支持HTTP/1.1但却不支持管道化。Polipo会小心地侦测服务器是否支持管道化，如果确认服务器支持就会启用管道化。

   ``initial segement`` - 一个部分会话表示会话只有部分被缓存在本地缓存中。有三种方式会导致部分会话：客户端只请求会话的一部分（如Adobe Acrobat Reader插件），服务器端在传输中途丢弃连接（如服务器缺少资源，或者存在bug），客户端丢弃连接（例如用户点击停止）。当一个会话只有部分缓存，它仍然可以使用HTTP的称为 ``range`` 请求来请求缺失部分的数据。Polipo缓存部分会话在内存中，只存储部分会话的initial分片在磁盘缓存，然后会尝试使用 ``range`` 请求来获取缺失部分。

安装Polipo
=============

- 从Git软件仓库扩取源代码::

   git clone https://github.com/jech/polipo.git

- 然后编译::

   cd polipo
   make

编译之后，当前目录下就有一个可执行文件 ``polipo``

如果想使用二进制执行代码，Debian系有直接发行包，RedHat软件包需要从第三方获取，Mac OS X可以使用  `DarwinPorts <http://www.macports.org/>`_

- 复制执行文件到系统目录::

   cp polipo /usr/local/sbin/

使用Polipo
==============

polipo默认启动只监听 ``127.0.0.1:8123`` ，这样可以防止被非法利用。如果要对外提供服务监听所有接口::

   polipo proxyAddress=0.0.0.0

设置systemd启动polipo
----------------------

参考 `How to create systemd service unit in Linux <https://linuxconfig.org/how-to-create-systemd-service-unit-in-linux>`_

- 配置 ``/usr/lib/systemd/system/polipo.service`` ::

   [Unit]
   Description=Polipo Proxy
   Requires=network.target
   After=network.target
   
   [Service]
   Type=oneshot
   RemainAfterExit=yes
   ExecStart=/usr/local/sbin/polipo -c /etc/polipo/config
   ExecStop=pkill polipo
   
   [Install]
   WantedBy=multi-user.target

- 创建配置文件 ``/etc/polipo/config`` ::

   proxyAddress = "0.0.0.0"    # IPv4 only
   daemonise = true
   logFile = /var/log/polipo
   pidFile = /var/run/polipo.pid
   
- 激活启动系统时启用服务::

   systemctl enable polipo

- 启动服务::

   systemctl start polipo

'Unit not found'错误排查
~~~~~~~~~~~~~~~~~~~~~~~~~~

最初我配置 ``/usr/lib/systemd/system/polipo.service`` ::

   [Unit]
   Description=Polipo Proxy
   Requires=Network.target
   After=Network.target
   
   [Service]
   Type=oneshot
   RemainAfterExit=yes
   ExecStart=/usr/local/sbin/polipo proxyAddress=0.0.0.0
   ExecStop=pkill polipo
   
   [Install]
   WantedBy=multi-user.target


此时执行 ``systemctl start polipo`` 出现一个报错::

   Failed to start polipo.service: Unit not found.

但是，这个systemd配置已经软链接到 ``/etc/systemd/system/multi-user.target.wants`` 目录::

   polipo.service -> /usr/lib/systemd/system/polipo.service

我尝试了修改::

   ExecStart=/bin/sh -c '/bin/nohup /usr/local/sbin/polipo proxyAddress=0.0.0.0 &'

但是报错依旧。

后来我发现，这个 ``Unit not found`` 实际上是我写错了 ``network.target`` ，我错误写成了 ``Network.target`` ，这个大写 ``N`` 没有匹配上 systemd 中的网络配置。

修正成正确 ``network.target`` 之后，则能够启动服务，但是 ``polipo`` 没有放到后台运行，导致 ``syatemdctl`` 命令不能返回。所以还需要修订::

   ExecStart=/bin/sh -c '/bin/nohup /usr/local/sbin/polipo proxyAddress=0.0.0.0 &'

这样脚本命令就可以在后台运行。不过，polipo支持daemon方式的，所以可以采用::

   ExecStart=/usr/local/sbin/polipo proxyAddress=0.0.0.0 daemonise=true

- 参考 `polipo config.sample <https://github.com/jech/polipo/blob/master/config.sample>`_ 创建配置文件 ``/etc/polipo/config`` ::

   proxyAddress = "0.0.0.0"    # IPv4 only
   daemonise = true
   logFile = /var/log/polipo
   pidFile = /var/run/polipo.pid

然后配置systemd::

   ExecStart=/usr/local/sbin/polipo -c /etc/polipo/config

YUM使用代理
=============

YUM可以通过通过设置环境变量来使用代理安装软件包::

   export http_proxy="http://PROXY_IP:8123"
   yum upgrade
   yum install XXXX

对于一直使用代理服务，则配置 ``/etc/yum.conf`` 添加::

   # The proxy server - proxy server:port number
   proxy=http://PROXY_IP:8123
   # The account details for yum connections
   proxy_username=yum-user
   proxy_password=qwerty

参考
======

- `The Polipo Manual <http://www.pps.univ-paris-diderot.fr/~jch/software/polipo/polipo.html>`_
