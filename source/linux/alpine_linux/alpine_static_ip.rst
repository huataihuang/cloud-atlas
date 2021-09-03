.. _alpine_static_ip:

============================
配置Alpine Linux静态IP地址
============================

我在 :ref:`alpine_extended` 中使用U盘启动，配置一个简单的静态IP地址来实现访问，目标是实现快速服务启动，运行 :ref:`kvm` 虚拟化和 :ref:`docker` 容器化，实现一个小型移动工作室。

Alpine Linux的网络配置和Debian的配置相似，在 ``/etc/network/interfaces`` 中设置IP地址:

.. literalinclude:: alpine_static_ip/interfaces
   :language: bash
   :linenos:
   :caption:

- 修订 ``/etc/resolv.conf`` 配置:

.. literalinclude:: alpine_static_ip/resolv.conf
   :language: bash
   :linenos:
   :caption:

- 重启网络服务使配置生效::

   /etc/init.d/networking restart

- 然后检查::

   ip addr

就可以看到配置的静态IP::

   ...
   2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
       link/ether 7c:c3:a1:87:2c:5c brd ff:ff:ff:ff:ff:ff
       inet 192.168.6.111/24 scope global eth0
          valid_lft forever preferred_lft forever
       inet6 fe80::7ec3:a1ff:fe87:2c5c/64 scope link
          valid_lft forever preferred_lft forever

- 通过 ``setup-alpine`` 交互设置的代理服务器配置实际上是环境变量::

   https_proxy=http://192.168.6.11:3128
   http_proxy=http://192.168.6.11:3128
   ftp_proxy=http://192.168.6.11:3128

参考
==========

- `How to configure static IP address on Alpine Linux <https://www.cyberciti.biz/faq/how-to-configure-static-ip-address-on-alpine-linux/>`_
