.. _intro_websocket:

===================
WebSocket技术简介
===================

低延迟双向交互
==================

HTTP的请求/响应模式是客户端控制，需要用户互动或者定期轮询，以便从服务器加载新数据。以往为了实现数据从服务器立即推送到客户端，会采用所谓 ``推送`` ( ``Comet`` ) 技术:

- 长轮询: 打开一条连接以后保持，直到服务器推送来数据以后再关闭连接。服务器只要实际拥有新数据，就会发送响应。
- iframe流: 在页面中插入一个隐藏的iframe，利用其src属性在服务器和客户端之间建立一条长链接，服务器向iframe传输数据（通常是HTML，内有负责插入信息的javascript），来实时更新页面。 iframe流方式的优点是浏览器兼容好，Google公司在一些产品中使用了iframe流，如Google Talk。

上述 ``推送`` 解决方案虽然非常好用，但是存在一个共同的问题：带有HTTP的开销，导致他们不能适用于低延迟应用。

WebSocket: 将套接字引入网络
============================

WebSocket 规范定义了一种 API，可在网络浏览器和服务器之间建立“套接字”连接。简单地说：客户端和服务器之间存在持久的连接，而且双方都可以随时开始发送数据。

在HTML5标准中，定义了客户端和服务器通讯的WebSocket方式，在得到浏览器支持以后，WebSocket将会取代Comet成为服务器推送的方法，目前Google Chrome、Firefox、Opera、Safari等主流版本均支持，Internet Explorer从10开始支持。

使用场景:

- 多人在线游戏
- 聊天应用
- 体育赛况直播
- 即时更新社交信息流

WebSocket服务器端实现
=======================

目前，很多著名的WEB框架都支持WebSocket，可以按照自己项目使用的开发语言进行选择:

- :ref:`nodejs` :

  - `Socket.IO <https://socket.io>`_
  - WebSocket-Node
  - ws

- Java

  - Jetty

- Ruby

  - EventMachine

- Python
  
  - pywebsocket
  - Tornado

- Erlang

  - Shirasu

- C++
  
  - libwebsockets

- .NET

  - SuperWebSocket

代理服务器
=============

WebSocket 协议 ``ws://`` 和 ``wss://`` 使用 HTTP 升级系统（通常用于 HTTP/SSL）将 HTTP 连接“升级”为 WebSocket 连接。某些代理服务器不支持这种升级，并会断开连接。因此，即使指定的客户端使用了 WebSocket 协议，可能也无法建立连接。

:ref:`squid_websocket` (需要Squid v5及以上版本)可以提供解决，此外， :ref:`nginx` 很早就实现了WebSocket支持以及代理和负载均衡，可以做相应尝试。

参考
======

- `Introducing WebSockets: Bringing Sockets to the Web <https://www.html5rocks.com/en/tutorials/websockets/basics/>`_ (网站有中文版，非常方便学习)
