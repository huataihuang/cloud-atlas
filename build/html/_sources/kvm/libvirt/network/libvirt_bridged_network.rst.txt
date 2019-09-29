.. _libvirt_bridged_network:

======================
libvirt 网桥型网络
======================

libvirt的网桥型网络(bridged network)是物理主机和虚拟机共享一个真实的以太网设备，每个虚拟机可以绑定局域网的任何可用的IPv4或IPv6地址，就好像一个物理主机。Bridge网络提供了最好的性能以及最易于配置的libvirt网络类型。

Bridge网络限制
================

libvirt服务器必须通过以太网有线网络连接，如果是无线网络，则只能使用 :ref:`libvirt_routed_network` 或者 :ref:`libvirt_nat_network` 。

初始步骤
==========

实践案例：

- 主机的以太网设备名 ``enp0s25``
- 虚拟机共享以太网设备 ``enp0s25``，并连接到网桥设备 ``br0``
- 主机提供2个地址网段
  - 对外IPv4地址段(203.0.113.160/29)
  - 对外IPv6地址段(2001:db8::/64)
- 主机静态绑定到 203.0.113.116 和 2001:db8::1
- 虚拟机可以绑定到分配地址段任何IPv4和IPv6

- 检查物理主机以太网设备::

   ip address show dev enp0s25

输出显示::

   2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
       link/ether 94:eb:cd:8e:eb:3f brd ff:ff:ff:ff:ff:ff
       inet 30.17.201.3/24 brd 30.17.201.255 scope global dynamic noprefixroute enp0s25
          valid_lft 11803sec preferred_lft 11803sec
       inet6 fe80::d9ef:58a4:a664:6d7c/64 scope link noprefixroute 
          valid_lft forever preferred_lft forever   

- 由于 `ntefilter的bridge性能和安全原因 <https://bugzilla.redhat.com/show_bug.cgi?id=512206#c0>`_ ，禁止bridge设备的netfilter，所以创建 ``/etc/sysctl.d/bridge.conf`` 以下设置::

   net.bridge.bridge-nf-call-ip6tables=0
   net.bridge.bridge-nf-call-iptables=0
   net.bridge.bridge-nf-call-arptables=0

- 创建 ``/etc/udev/rules.d/99-bridge.rules`` ，这个udev规则将在sysctl设置上述bridge模块时加载。注意，对于Kernel 3.18之前的版本， ``KERNEL=="br_netfilter"`` 需要修改成 ``KERNEL=="bridge"`` ::

   ACTION=="add", SUBSYSTEM=="module", KERNEL=="bridge", RUN+="/sbin/sysctl -p /etc/sysctl.d/bridge.conf"

.. note::

   实践发现在RHEL的系统中，存在 ``/proc/sys/net/bridge/bridge-nf-call-*tables`` 内核配置入口，上述配置在CentOS 7上可以完成。但是在Arch Linux平台没有上述内核配置，所以没有执行。

配置网桥
=========

.. note::

   有多种方法可以用来创建网桥，本文案例实践在arch linux上完成

使用iproute2
-------------

使用 ``iproute2`` 软件包的 ``ip`` 工具可以管理网桥

- 创建新网桥并启动::

   ip link add name br0 type bridge

这里 ``br0`` 是网桥名字

- 设置网卡 ``enp0s25`` 启动状态(up) ::

   ip link set enp0s25 up

- 将网络接口(这里是 ``enp0s25`` )添加到网桥 ``br0`` ::

   ip link set enp0s25 master br0

- 检查网桥及相应接口::

   bridge link

.. note::

   这里如果 ``enp0s25`` 是已经激活并获取了DHCP地址，添加到 br0 网桥上，可能会导致网络断开。

- 要从网桥移除一个接口::

   ip link set enp0s25 nomaster

此时接口还是up的，所以需要将接口down::

   ip link set enp0s25 down

- 删除网桥::

   ip link delete br0 type bridge

使用bridge-utils
------------------


参考
========

- `libvirt Networking Handbook - Bridged network <https://jamielinux.com/docs/libvirt-networking-handbook/bridged-network.html>`_
- `Arch Linux社区文档 - Network bridge <https://wiki.archlinux.org/index.php/Network_bridge>`_
