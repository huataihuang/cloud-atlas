.. _proxychains:

==================
proxychains
==================

:ref:`across_the_great_wall` 才能到达世界的每个角落: 

当我在国内各地旅行的时候，我意外地发现，每个省份的GFW屏蔽各不相同。例如，在上海，虽然访问 `世界最大同性交友网站 <https://github.com>`_ 非常困难，但是git pull/push 代码是畅通无阻的。然而，到了南方的深圳/广州，连GitHub代码仓库也无法访问了。

着对于软件开发者而言，是非常痛苦的，需要 ``浪费大量的时间`` 来构建VPN，有时候真不想这么折腾。那么有没有更为简洁的方法呢？

- 使用一条 :ref:`ssh` 命令来构建 :ref:`ssh_tunneling_dynamic_port_forwarding` ，这样就构建了本地Socks5代理
- 使用 ``proxychains`` 工具，将本机TCP访问转为通过Socks5代理，这样即使本地软件不支持代理，也能够 :ref:`across_the_great_wall`

.. note::

   另外一个简洁的方法(可以适用于任何Linux或类似系统，如Android手机)，是采用 :ref:`privoxy_android_ssh_tunneling` 

简介
======

``proxychains`` 可以强制任何tcp连接流向通过一个代理服务器(或代理链路)，这个工具通常用于加强internet连接安全性。

- 在gentoo中安装:

.. literalinclude:: proxychains/gentoo_install
   :caption: 在gentoo中安装proxychains

- 使用非常简便，就是在常规命令前面加上 ``proxychains`` 就能为应用带来代理引导。以我自己的实践案例，当GFW阻塞了GitHub导致 :ref:`gentoo_emerge` 无法完成源码下载 :ref:`upgrade_gentoo` 时，通过以下命令完成 :ref:`across_the_great_wall` :

.. literalinclude:: proxychains/emerge_upgrade
   :caption: 通过 ``proxychains`` 帮助 :ref:`gentoo_emerge` 完成代码下载

参考
=====

- `gentoo linux wiki: proxychains <https://wiki.gentoo.org/wiki/Proxychains>`_
