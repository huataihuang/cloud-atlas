.. _ip_command:

===============
Linux ip命令
===============

现代Linux系统已经使用高级路由设置命令 ``ip`` 来完成网络配置，很多时候，默认都没有安装 ``ifconfig`` 这样的传统工具，所以有必要更新自己的知识体系，学习这个强大的工具。

- 语法::

   ip OBJECT COMMAND
   ip [options] OBJECT COMMAND
   ip OBJECT help

ip命令还支持对象语法缩写，例如 ``link`` 缩写成 ``l`` ， ``address`` 缩写成 ``a`` 或者 ``addr`` ， ``addrlabel`` 缩写成 ``addrl`` 。

可以通过 ``-4`` 表示 ``IPv4`` 或者 ``-6`` 表示 ``IPv6`` ::

   # 显示TCP/IP IPv4
   ip -4 a
   # 显示TCP/IP IPv6
   ip -6 a

- 检查网卡::

   ip link list

- 设置网卡IP::

   ip address add 192.168.2.2/24 dev enp0s25

缩写::

   ip a add 192.168.2.2/24 dev enp0s25

默认情况下ip命令不设置任何广播地址，除非明确要求，以下语法设置广播地址::

   ip addr add brd {ADDDRESS-HERE} dev {interface}
   ip addr add broadcast {ADDDRESS-HERE} dev {interface}
   ip addr add broadcast 172.20.10.255 dev dummy0

- 删除地址::

   ip a del {ipv6_addr_OR_ipv4_addr} dev {interface}

举例::

   ip a del 192.168.2.2/24 dev enp0s25

此外，还支持 ``flush`` 命令一次性将接口上所有地址或一段地址都移除，例如以下移除 192.168.2.0/24 网段地址::

   ip -s -s a f to 192.168.2.0/24

也可以把所有 ppp(Point-to-Point)接口上所有地址禁用::

   ip -4 addr flush label "ppp*"

或者所有以太网接口::

   ip -4 addr flush label "eth*"

- 启动网卡::

   ip link enp0s25 up

关闭网卡::

   ip link enp0s25 down

路由
=======

- 检查路由::

   ip route show
   ip route list
   ip r
   ip r list
   ip r list [options]
   ip route

- 设置默认路由::

   ip route add default via 192.168.2.1

- 添加静态路由::

   ip route add 192.168.3.0/24 via 192.168.2.1 dev eth0

类似语法可以使用::

   ip route add {NETWORK/MASK} via {GATEWAYIP}
   ip route add {NETWORK/MASK} dev {DEVICE}
   ip route add default {NETWORK/MASK} dev {DEVICE}
   ip route add default {NETWORK/MASK} via {GATEWAYIP}

- 删除路由::

   ip route delete 192.168.3.0/24 dev eth0

删除默认路由::

   ip route del default

.. note::

   Debian/Ubuntu 配置文件添加静态路由是 ``/etc/network/interfaces`` ::

      # The primary network interface
      auto eth0
      iface eth0 inet static
          address 192.168.2.24
          gateway 192.168.2.254

   CentOS/RHEL 添加静态路由是 ``/etc/sysconfig/network-scripts/route-eth0`` ::

      10.105.28.0/24 via 10.105.28.1 dev eth0

   然后重启网络服务::

      systemctl restart network

调整网卡参数
=============

- 修改网卡设备的tx队列长度::

   ip link set txqueuelen {NUMBER} dev {DEVICE}

通过 ``ip addr list {DEVICE}`` 可以查看设备的txquenelen队列长度::

   ip link set txqueuelen 10000 dev eth0
   ip addr list eth0

- 修改网络设备MTU::

   ip link set mtu {NUMBER} dev {DEVICE}

举例，修改eth0的MTU为9000::

   ip link set mtu 9000 dev eth0
   ip a list eth0

- 显示neighbour/arp表::

   ip n show
   ip neigh show

举例::

   ip n show

显示arp缓存如下(这里显示的是网关)::

   10.15.237.254 dev wlp3s0 lladdr 58:69:6c:31:a3:17 REACHABLE

- 添加ARP::

   ip neigh add {IP-HERE} lladdr {MAC/LLADDRESS} dev {DEVICE} nud {STATE}

举例::

   ip neigh add 192.168.1.5 lladdr 00:1a:30:38:a8:00 dev eth0 nud perm

删除ARP::

   ip neigh del {IPAddress} dev {DEVICE}
   ip neigh del 192.168.1.5 dev eth1

- 刷新ARP表::

   ip -s -s n f {IPAddress}

举例，刷新192.168.1.5::

   ip -s -s n f 192.168.1.5
   ip -s -s n flush 192.168.1.5


参考
=====

- `Linux ip Command Examples <https://www.cyberciti.biz/faq/linux-ip-command-examples-usage-syntax/>`_
- `Linux Set Up Routing with ip Command <https://www.cyberciti.biz/faq/howto-linux-configuring-default-route-with-ipcommand/>`_
- `ip command in Linux with examples <https://www.geeksforgeeks.org/ip-command-in-linux-with-examples/>`_
