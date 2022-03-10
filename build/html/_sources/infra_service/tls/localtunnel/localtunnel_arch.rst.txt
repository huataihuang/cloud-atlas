.. _localtunnel_arch:

====================
localtunnel架构
====================

不知道你有没有想到过，当我们在家里使用 :ref:`raspberry_pi` 构建起 :ref:`web` 或者 :ref:`k3s` ( :ref:`kubernetes` 轻量级实现 )，但是仅仅因为家用网络没有Internet公网IP地址，无法对外提供服务或演示。那么我们有什么方法能够把这个NAT内部网络服务输出到外界，实现一个个人的 :ref:`priv_cloud` 呢？

对于我个人的云计算实践，我想实现:

- 构建 :ref:`edge_cloud` ，采用 :ref:`k3s` 实现一个边缘云计算，并且将个人的开发和部署架构向外提供服务
- 所有的数据和架构都由自己掌握，不依赖于公有云服务商(仅使用公有云提供代理入口)

我的思路
===========

我最初考虑是使用 :ref:`linux_vpn` :

- 使用一个互联网VPS构建对外出口
- 在Home网路中部署 :ref:`raspberry_pi` 的 :ref:`k3s` ，通过 :ref:`openconnect_vpn` 建立起内部网络到互联网桥头堡VPS的加密连接
- 在VPS上启用 :ref:`squid` 或 :ref:`nginx` 反向代理访问通过VPN连接对外提供服务

localtunnel
===============

实际上早在十几年前(2010年)，有一个开源工具 `progrium/localtunnel <https://github.com/progrium/localtunnel>`_ 巧妙地实现了tunnel方式，将NAT局域网中地服务器输出到因特网上。并且，这个开源项目实现了多个语言版本:

- `prototype版本 <https://github.com/progrium/localtunnel/tree/prototype>`_ 2010年早期，采用Python Twisted实现整个系统
- `v1版本 <https://github.com/progrium/localtunnel/tree/v1>`_ 2010年中期，采用OpenSS包装方式，客户端使用Ruby，服务端使用Python Twisted
- `v2版本 <https://github.com/progrium/localtunnel/tree/v2>`_ 2011年到2013年，尝试项目化和服务化，客户端和服务器端使用Python gevent并解决了v1版本很多问题
- `v3版本 <https://github.com/progrium/localtunnel>`_ 使用 :ref:`golang` 重写了客户端和服务器端

``localtunnel`` 现在已经不再开发，但是这个开源项目继续影响着世界，还有其他人开发了 :ref:`nodejs` 版本 `localtunnel.me <https://theboroer.github.io/localtunnel-www/>`_ ( :ref:`expose_local_nodejs_to_world` )，并且产生了商业化公司 `ngrok.com <https://ngrok.com/>`_ 提供快速简便的方法将个人无公网IP的服务器输出到因特网上。

商业服务
----------

`ngrok.com <https://ngrok.com/>`_ 是最流行的tunnel服务公司，使用Go开发，提供不同平台架构的客户端，可以快速把本地服务通过它的站点向外输出。价格大约和VPS或者租用小型虚拟机差不多。

localtunnel原理
=================

待续...

参考
=====

- `progrium/localtunnel <https://github.com/progrium/localtunnel>`_ 最早实现的开源解决方案，提供了python,go语言实现，并且启发了其他语言实现以及商业模式的形成
