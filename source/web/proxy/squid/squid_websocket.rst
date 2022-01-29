.. _squid_websocket:

=======================
Squid支持WebSocket配置
=======================

:ref:`websocket` 是最新的双向交互HTML5标准，对于低延迟双向交互有非常重要的意义。

我在学习 :ref:`patternfly_develop` 需要参考 Red Hat Developer 网站的 `Developing with PatternFly React教程 <https://developers.redhat.com/courses/patternfly-react>`_ 。但是，交互教程(KataCoda)需要使用WebSocket实现双向交互，通过Squid代理就会出现报错::

   This is potentially due to a HTTP Proxy blocking Websockets.
   Websocket Error - Connection Failed.

对于 :ref:`websocket` 实际上是HTTP协议连接 ``upgrade`` (升级)成 WebSocket 连接，所以，要解决代理服务器兼容WebSocket，需要配置代理服务器允许协议升级( ``HTTP upgrade request`` )。

Squid从 v5 版本开始，支持 ``http_upgrade_request_protocols`` 配置参数，允许客户端发起的控制和服务器确认机制通过使用HTTP/1.1 Upgrade机制转换成其他协议。

- 配置 ``/etc/squid/squid.conf`` 添加::

   http_upgrade_request_protocols WebSocket allow all

需要注意，版本低于 squid v5 无法解析上述配置。例如 Ubuntu 20.04.3 LTS 发行版提供的是 ``4.10`` 版本Squid 会出现报错。解决方法是 :ref:`build_squid5_ubuntu`

参考
======

- `Squid configuration directive http_upgrade_request_protocols <http://www.squid-cache.org/Doc/config/http_upgrade_request_protocols/>`_
