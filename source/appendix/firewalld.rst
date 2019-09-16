.. _firewalld:

=====================
firewalld防护墙服务
=====================

firewalld是Red Hat开发的firewall aemon，默认使用了nftables(取代iptables的netfilter实现)。firewalld提供了动态管理防火墙，支持网络/防火墙区域(zones)概念以便定义网络连接或网络接口的信任级别。firewalld支持IPv4, IPv6防火墙设置，以太网网桥以及IP sets。并且，firewalld提供了运行时配置和永久性配置的区分，也提供了面向服务或应用程序来添加防火墙规则的接口。

- 安装::

   pacman -S firewalld

- 使用

激活和启动firewalld.service::

   systemctl start firewalld
   systemctl enable firewalld

通过 ``firewall-cmd`` 控制台工具可以管理防火墙规则。

参考
=======

- `Arch Linux 社区文档 - Firewalld <https://wiki.archlinux.org/index.php/Firewalld>`_
