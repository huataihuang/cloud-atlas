.. _firewalld:

=====================
firewalld防护墙服务
=====================

firewalld概念
===============

- ``firewalld`` 是Red Hat开发的firewall daemon，默认使用了nftables(取代iptables的netfilter实现)。
 
- ``firewalld`` 提供了动态管理的基于主机的防火墙，带有 D-Bus 接口，支持网络/防火墙区域(zones)概念以便定义网络连接或网络接口的信任级别。
 
- ``firewalld`` 支持IPv4, IPv6防火墙设置，以太网网桥以及IP sets。
 
- ``firewalld`` 提供了运行时配置和永久性配置的区分，也提供了面向服务或应用程序来添加防火墙规则的接口。

- ``firewalld`` 阻止未明确设置为打开的端口上的所有流量。默认情况下，某些区域(例如受信任区域)允许所有流量。

安装firewalld
================

arch linux::

   pacman -S firewalld

rhel/CentOS::

   dnf install firewalld

使用firewalld
==================

激活和启动firewalld.service::

   systemctl start firewalld
   systemctl enable firewalld

通过 ``firewall-cmd`` 控制台工具可以管理防火墙规则。

配置
===========

.. note::

   大多数命令是运行时配置，但是不是持久化配置，也就是重启操作系统会清除。要永久化配置有两个选项:

   - 使用 ``--permanent`` 选项，这个命令选项 ``不会`` 修改运行时配置，除非重启firewall服务或者重新加载 ``--reload`` 
   - 将运行时配置转换成永久配置

Zones
-------

zone是汇集规则并应用到指定接口。

检查当前zone和关联到接口，使用命令::

   firewall-cmd --get-active-zones

例如，显示输出::

   libvirt
     interfaces: virbr0
   public
     interfaces: wlp3s0

通过传递 ``--zone=zone_name`` 参数可以向指定zone传递

zone信息
---------

可以列出所有zone的配置::

   firewall-cmd --list-all-zones

或只列出指定zone::

   firewall-cmd --info-zone=zone_name

举例::

   firewall-cmd --info-zone=public

显示输出::

   public (active)
     target: default
     icmp-block-inversion: no
     interfaces: wlp3s0
     sources:
     services: dhcpv6-client ssh
     ports:
     protocols:
     masquerade: no
     forward-ports:
     source-ports:
     icmp-blocks:
     rich rules:

- 修改zone的接口::

   firewall-cmd --zone=zone --change-interface=interface_name

默认zone
-----------

- 检查默认zone的接口::

   firewall-cmd --get-default-zone

显示输出::

   public

可以修改默认zone，注意这个修改是永久的::

   firewall-cmd --set-default-zone=XXXX

服务
========

服务(service)是预先制定的针对特定daemon的预定规则。例如 ``ssh`` service对应的就是SSH服务和开放端口22到指定zone。

- 列出所有可用的预定服务::

   firewall-cmd --get-services

- 可以进一步检查特定服务信息::

   firewall-cmd --info-service service_name

举例，查看 ``samba`` 需要开放端口有4个::

   firewall-cmd --info-service samba

输出显示::

   samba
     ports: 137/udp 138/udp 139/tcp 445/tcp
     protocols:
     source-ports:
     modules: netbios-ns
     destination:
     includes:

在zone上添加或移除服务
-----------------------

- 将服务添加到zone，就可以一次设置好需要的所有端口::

   firewall-cmd --zone=zone_name --add-service service_name

举例，在libvirt zone上添加samba服务，以便能够让虚拟机访问物理主机上的samba共享存储卷，方便虚拟机交换数据::

   firewall-cmd --zone=libvirt --add-service samba

- 反之，也可以删除服务::

   firewall-cmd --zone=zone_name --remove-service service_name

端口添加或删除
----------------

也可以在指定zone上添加端口或删除端口::

   firewall-cmd --zone=zone_name --add-port port_num/protocol

这里protocol可以是tcp或udp。删除端口使用 ``--remove-port`` 参数。

端口和服务时限
================

firewalld还支持一种有时间限制的服务和端口添加，时间单位可以是秒(无需单位表示)，或者分钟(m)或者小时(h)。举例，添加3小时有效的SSH服务::

   firewall-cmd --add-service ssh --timeout=3h

运行时配置持久化
=================

可以将当前配置持久化::

   firewall-cmd --runtime-to-permanent

惨痛的教训
=============

我在 :ref:`debug_ceph_authenticate_time_out` 犯了一个低级错误，简单查看了 ``iptables -L`` 输出为空就以为主机没有启动防火墙。没想到 :ref:`fedora` 默认启用了 ``firewalld`` 服务。所以后来检查:

.. literalinclude:: firewalld/firewall_cmd_list
   :language: bash
   :caption: 检查主机所有firewalld配置概要

可以看到 ``firewalld`` 屏蔽了 :ref:`ceph` 服务访问:

.. literalinclude:: ../../../ceph/deploy/install_mobile_cloud_ceph/debug_ceph_authenticate_time_out/firewall_cmd_list_output
   :language: bash
   :caption: 检查firewalld配置输出
   :emphasize-lines: 6

停止 ``firewalld`` :

.. literalinclude:: firewalld/stop_firewalld
   :language: bash
   :caption: 停止firewalld服务

参考
=======

- `Arch Linux 社区文档 - Firewalld <https://wiki.archlinux.org/index.php/Firewalld>`_
- `Introduction to FirewallD on CentOS <https://www.linode.com/docs/security/firewalls/introduction-to-firewalld-on-centos/>`_
- `How To Set Up a Firewall Using firewalld on CentOS 8 <https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-8>`_
- `Fedora docs: Using firewalld <ttps://docs.fedoraproject.org/en-US/quick-docs/firewalld/>`_
