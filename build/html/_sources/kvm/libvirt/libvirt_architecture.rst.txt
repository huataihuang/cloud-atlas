.. _libvirt_architecture:

======================
libvirt 架构
======================

.. note::

   Arch Linux的运行和管理对于技术要求较高，需要比较深入地了解软件运行原理和关系，所以相对CentOS / Ubuntu难度高很多。不过，Arch Linux的文档撰写非常完善，可以通过社区文档对虚拟化技术深入学习。本文是学习实践的笔记。

Libvirt是一组用于提供管理虚拟机和虚拟化功能的软件，例如可以管理存储和网络接口。Libvirt软件集包括一系列稳定的C API，一个daemon服务(libvirtd)，以及命令行工具(virsh)。libvirt的主要目标是提供一个简单的方式来管理不同的虚拟化技术 / :ref:`hypervisor` ，例如KVM/QEMU，Xen, LXC, OpenVZ 或者 VirtualBox hypervisor等。

libvir主要功能包括:

- VM管理: domain的不同生命周期操作，例如，start, stop, pause, save, restore, migrate。很多设备类型，例如磁盘和网络借口，内存，CPU都支持热插拔操作。

- 远程主机管理: 所有的libvirt功能都可以在任何运行libvirt daemon的任何主机上实现，包括远程主机。通过简单使用SSH，不需要复杂的配置就可以支持远程连接。

- 存储管理: 运行libvirt daemon的主机可以管理不同的村粗：创建不同的镜像文件(qcow2, vmdk, raw ...)，挂载NFS共享存储，处理现存的LVM卷组，创建新的LVM卷组和逻辑卷，裸磁盘设备分区，挂载iSCSI共享，等等。

- 网络接口管理: 运行libvirt daemon的主机可以管理物理和逻辑网络接口，配置和创建借口，网桥，vlan以及bond设备。

- 虚拟NAT和基于路由的网络: 运行libvirt daemon的主机可以管理和创建虚拟网络，使用防火墙规则实现路由器，提供VM透明访问host主机网络。

安装
=========

.. note::

   Arch Linux将libvirt相关软件的安装拆分，所以你需要对相关组件的功能了解后按需安装。没有类似Red Hat和Ubuntu这样一股脑全部安装。请仔细阅读社区文档，深入理解原理。

服务器
-------

服务器上安装 libvirt 软件包，以及至少一个 :ref:`hypervisor` ，通常KVM激活情况下，libvirt KVM/QEMU驱动会作为主要libvirt驱动。

为了能够使用网络，需要分别安装以下组件:

- ``ebtables`` 和 ``dnsmasq`` 是默认的 NAT/DHCP 网络所必须的
- ``bridge-utils`` 是网桥网络所必须的
- ``openbsd-netcat`` 是基于SSH远程管理所必须的

为了能够使用网络，需要分别安装以下组件:

- ``ebtables`` 和 ``dnsmasq`` 是默认的 NAT/DHCP 网络所必须的
- ``bridge-utils`` 是网桥网络所必须的
- ``openbsd-netcat`` 是基于SSH远程管理所必须的

为了能够使用网络，需要分别安装以下组件:

- ``ebtables`` 和 ``dnsmasq`` 是默认的 NAT/DHCP 网络所必须的
- ``bridge-utils`` 是网桥网络所必须的
- ``openbsd-netcat`` 是基于SSH远程管理所必须的

.. note::

   如果使用 ``firewalld`` ，则需要修改 ``/etc/firewalld/firewalld.conf`` 的 firewall backend 配置，从 ``nftables`` 修改成 ``iptables`` 。

安装::

   pacman -S libvirt ebtables dnsmasq bridge-utils openbsd-netcat

客户端
----------

libvirt客户端是用户接口，用于管理和访问虚拟机：

- ``virsh`` 命令行管理和配置domain工具 (软件包 ``libvirt`` )

- GNOME Boxes 是一个简单的Gnome 3应用程序，用于访问远程和虚拟机 (软件包 ``gnome-boxes`` )

- Libvirt Sandbox 应用程序沙盒toolkit (软件包 ``libvirt-sandbox`` ，需要使用 AUR 安装)

- Remote viewer - 简单的远程显示客户端 (软件包 ``virt-viewer`` )

- Qt VirtManager - 管理虚拟机的Qt应用程序 (软件包 ``qt-virt-manager`` ，需要使用 AUR 安装)

- Virtual Machine Manager - 通过libvirt管理KVM, Xen, LXC的图形化工具

.. note::

   实际我在使用中仅安装 ``libvirt`` 软件包，只使用 ``virsh`` 命令行工具。

配置libvirt
=============

在系统级别的系统管理，libvirt最少需要设置认证和启动daemon。

设置认证
---------

libvirt daemon允许系统管理员选择用于客户端每次网络socket链接的认证机制。这个控制是通过libvirt daemon的主配置文件 ``/etc/libvirt/libvirtd.conf`` 管理。每个libvirt socket可以配置独立的认证机制。当前可以选择的认证机制有: ``none`` ， ``polkit`` 和 ``sasl`` 。

由于libvirt安装过程安装了polkit作为以来，所以默认在 ``unix_sock_auth`` 参数配置的是 ``polkit`` 。而基于文件的授权则没有提供。

.. note::

   检查libvirt默认安装配置的 ``/etc/libvirt/libvirtd.conf`` 中实际上允许任何人链接socket，即没有限制::

      #auth_unix_ro = "none"
      #auth_unix_rw = "none"      

   TCP链接认证默认是sasl::

      #auth_tcp = "sasl"

待续

参考
=========

- `Arch Linux文档 - libvirt <https://wiki.archlinux.org/index.php/Libvirt>`_
- `rockstable libvirt文档 <https://wiki.rockstable.it/libvirt>`_ 这个文档有很多全面的知识点
