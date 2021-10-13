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

- `ntefilter的bridge性能和安全原因 <https://bugzilla.redhat.com/show_bug.cgi?id=512206#c0>`_ ，禁止bridge设备的netfilter，所以创建 ``/etc/sysctl.d/bridge.conf`` 以下设置::

   net.bridge.bridge-nf-call-ip6tables=0
   net.bridge.bridge-nf-call-iptables=0
   net.bridge.bridge-nf-call-arptables=0

生效::

   sysctl -p /etc/sysctl.d/bridge.conf

.. note::

   ``/etc/sysctl.d/`` 目录下配置文件以 ``.conf`` 结尾都会在系统启动时执行，但是直接运行 ``sysctl -p /etc/sysctl.conf`` 现在已经不会刷新 ``/etc/sysctl.d`` 目录下配置，所以需要指定配置文件刷新

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

传统的 ``brctl`` 工具( ``bridge-utils`` 软件包)提供了管理网桥的功能。

- 创建网桥::

   brctl addbr br0

- 将设备加到网桥::

   brctl addif br0 enp0s25

.. note::

   将接口加入到网桥会导致该接口丢失现有IP地址，所以建议不要远程操作，或者至少有其他方式远程连接。当网桥脚本工作完成后网络连接会恢复。

- 显示网桥::

   brctl show

- 设置网桥设备启动::

   ip link set dev br0 up

- 删除网桥时，需要首先停止::

   ip link set dev br0 down
   brctl delbr br0

.. note::

   要激活网桥的netfilter功能，需要手工加载 ``br_netfilter`` 模块::

      modprobe br_netfilter

使用NetworkManager
--------------------

使用NetworkManager配置网络是很多发行版默认的网络配置方法，我在 :ref:`archlinux_on_thinkpad_x220` 采用 :ref:`xfce` 桌面，配置无线网络就采用NetworkManager。这个网络配置管理工具和桌面完美结合，使用非常方便。这里介绍如何使用NetworkManager的命令行 ``nmcli`` 来完成网桥配置。

- 创建网桥并禁止STP(避免网桥被公告到网络)::

   nmcli c add type bridge ifname br0 stp no

.. note::

   xfce桌面使用NetworkManager图形界面配置时，只提供了对物理网卡设备(作为网桥的slave)的mac地址修改功能，所以如果网络限制了mac地址接入，这里需要命令行修订::

      macchanger -m XX:XX:XX:XX:XX:XX br0

- 将物理网络接口 ``enp0s25`` 作为slave添加到网桥::

   nmcli c add type bridge-slave ifname enp0s25 master br0

- 设置连接down::

   nmcli c down bridge-br0

- 设置网桥启动::

   nmcli c up bridge-br0

- 检查NetworkManager连接::

   nmcli c

可以看到输出::

   NAME                  UUID                                  TYPE      DEVICE
   bridge-br0            9dcd545c-f65a-471c-b1c9-399912dcb4dc  bridge    br0
   bridge-slave-enp0s25  583f6a08-9af1-41c7-bea7-e17387f42071  ethernet  enp0s25

- 检查网桥::

   brctl show

显示::

   bridge name    bridge id        STP enabled    interfaces
   br0        8000.94ebcd8eeb3f    no        enp0s25

使用netplan
-------------

参考:

- `How to create a bridge network on Linux with Netplan <https://www.techrepublic.com/article/how-to-create-a-bridge-network-on-linux-with-netplan/>`_
- `Netplan Examples: Configuring network bridges <https://netplan.io/examples/#configuring-network-bridges>`_

在 :ref:`ubuntu_linux` 服务器上，使用netplan来完成网络设置，为了统一管理，Ubuntu Server我也采用Netplan完成设置

- 备份原先的配置::

   sudo cp /etc/netplan/00-cloud-init.yaml /etc/netplan/00-cloud-init.yaml.bak

- 然后修订配置如下

.. literalinclude:: libvirt_bridged_network/00-cloud-init.yaml
   :language: yaml
   :linenos:
   :caption: /etc/netplan/00-cloud-init.yaml

参数 ``forward-delay`` 会设置bridge启动后延迟4秒之后再开始转发

- 执行生效::

   sudo netplan generate
   sudo netplan apply

- 完成后检查IP::

   ip addr

可以看到::

   2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master br0 state UP group default qlen 1000
       link/ether 94:57:a5:5a:d9:c0 brd ff:ff:ff:ff:ff:ff
   
   9: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
       link/ether 94:57:a5:5a:d9:c0 brd ff:ff:ff:ff:ff:ff
       inet 192.168.6.200/24 brd 192.168.6.255 scope global br0
          valid_lft forever preferred_lft forever
       inet6 fe80::e4b8:87ff:fedc:5146/64 scope link
          valid_lft forever preferred_lft forever

- 检查网桥::

   brctl show


显示::

   bridge name     bridge id               STP enabled     interfaces
   br0             8000.9457a55ad9c0       no              eno1

使用systemd-networkd
---------------------------

参考 `systemd-networkd#Bridge interface <https://wiki.archlinux.org/index.php/Systemd-networkd#Bridge_interface>`_

其他方法
----------

- 使用netctl: `Bridge with netctl <https://wiki.archlinux.org/index.php/Bridge_with_netctl>`_ (未实践)

配置虚拟机
=============

- 对于新安装虚拟机，可以直接指定网络设备的bridge::

   virt-install --network bridge=br0 ...

- 对于 :ref:`create_vm` ，已经创建的虚拟机，可以通过 ``virsh edit win10`` 编辑已经存在的虚拟机配置，修改或添加网卡设备::

    <interface type='bridge'>
      <mac address='52:54:00:9f:98:c9'/>
      <source bridge='br0'/>
      <model type='virtio'/>
    </interface>

.. note::

   这里 ``<model type='virtio'/>`` 选项可选添加，需要确保guest操作系统已经安装过virtio驱动(Linux默认)

参考
========

- `libvirt Networking Handbook - Bridged network <https://jamielinux.com/docs/libvirt-networking-handbook/bridged-network.html>`_
- `Arch Linux社区文档 - Network bridge <https://wiki.archlinux.org/index.php/Network_bridge>`_
