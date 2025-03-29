.. _libvirt_nat_network:

======================
libvirt NAT型网络
======================

Libvirt的NAT网络是针对只需要外出流量的IPv4网络的虚拟机，libvirt服务器作为一个路由器，所有VM流量对外显示成从这个服务器的IPv4地址发出。

默认的虚拟机网络就是一个NAT网络(具备 `fragile hook system <http://wiki.libvirt.org/page/Networking#Forwarding_Incoming_Connections>`_ 来转发进入的连接)。但是，NAT网络引入了iptables规则，所以难以控制，除非你已经完全禁止默认网络。如果你需要完全控制并避免libvirt介入，则参考 :ref:`libvirt_custom_nat` 。

Host主机配置
=============

每个标准的libvirt安装会提供虚拟机连接外部的NAT虚拟网络，这个NAT虚拟网络也称为"default virtual network"，可以通过以下命令检查::

   virsh net-list --all

输出可以看到::

   Name                 State      Autostart 
   -----------------------------------------
   default              active     yes


如果libvirt安装时没有创建默认NAT虚拟网络，可以通过example的XML配置重新加载和激活::

   virsh net-define /usr/share/libvirt/networks/default.xml

如果没有上述案例配置文件，可以从其他正确安装NAT虚拟网络的主机上使用命令 ``virsh net-edit default`` 查看标准的配置::

   <network>
     <name>default</name>
     <bridge name="virbr0"/>
     <forward mode="nat"/>
     <ip address="192.168.122.1" netmask="255.255.255.0">
       <dhcp>
         <range start="192.168.122.2" end="192.168.122.254"/>
       </dhcp>
     </ip>
   </network>

然后执行如下命令定义::

   virsh net-define /tmp/default.xml

在Arch Linux实践KVM时候，检查发现默认default网络没有激活(最初安装libvirt时没有同时安装bridge-utils)::

   # virsh net-list --all
    Name      State      Autostart   Persistent
   ----------------------------------------------
    default   inactive   no          yes

启动default网络::

   virsh net-start default

报错显示，NAT网络依赖防火墙后端::

   error: Failed to start network default
   error: internal error: Failed to initialize a valid firewall backend

参考 `libvirt: “Failed to initialize a valid firewall backend” <https://superuser.com/questions/1063240/libvirt-failed-to-initialize-a-valid-firewall-backend>`_ 上述报错是因为没有安装firewalld软件包，即使此时系统已经安装了 ebtables, dnsmasq libvirt iptables::

   $ pacman -Q ebtables dnsmasq libvirt iptables
   ebtables 2.0.10_4-7
   dnsmasq 2.80-4
   libvirt 5.5.0-1
   iptables 1:1.8.3-1

修复方法如下::

   sudo pacman -Syu ebtables dnsmasq firewalld
   sudo systemctl start firewalld
   sudo systemctl enable firewalld
   sudo systemctl restart libvirtd

现在就可以启动default网络了::

   virsh net-start default

然后设置default NAT虚拟网路默认启动::

   virsh net-autostart default

当默认的NAT网络启动后，你会看到一个隔离的bridge设备，这个设备 ``没有`` 任何物理网络接口连接，所以它使用的是 NAT+forwarding 来连接外部网络。请不要添加任何网络接口!!!

检查::

   brctl show

显示::

   bridge name	bridge id		STP enabled	interfaces
   virbr0       8000.7a5026bf337c       yes             virbr0-nic

libvirt会添加iptables规则INPUT, FORWARD, OUTPUT 和 POSTROUTING 链路，允许附加到virtbr0设备的guest系统流量的进出。另外libvirt也会激活 ``ip_forward`` ，最佳的方式是添加以下配置到 ``/etc/sysctl.conf`` ::

   net.ipv4.ip_forward = 1

这个值对应内核参数 ``/proc/sys/net/ipv4/ip_forward`` ，只要确保是 1 就可以转发虚拟机流量。

如果上述内核参数值不是1,则可以执行以下命令修订::

   echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
   echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf
   echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
   sysctl -p

 .. note::

    创建虚拟机参考 :ref:`create_vm`

virbr0设备DOWN排查
====================

发现一个比较奇怪的问题，之前工作正常的NAT libvirt网络，突然不能正常通讯，虚拟机无法ping网关192.168.122.1，但是实际上default的libvirt网络是激活状态的::

   virsh net-list

显示正常::

    Name      State    Autostart   Persistent
   --------------------------------------------
    default   active   yes         yes   

``brctl show`` 也正常显示了虚拟网卡设备 ``virbr0-nic``::

   bridge name	bridge id		STP enabled	interfaces
   br0		8000.7e33f1ea9ee3	no		
   virbr0		8000.7a5026bf337c	yes		virbr0-nic

但是，使用 ``ip addr`` 显示libvirt网络并未启动::

   6: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
       link/ether 7a:50:26:bf:33:7c brd ff:ff:ff:ff:ff:ff
       inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
          valid_lft forever preferred_lft forever
   7: virbr0-nic: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel master virbr0 state DOWN group default qlen 1000
       link/ether 52:54:00:45:db:25 brd ff:ff:ff:ff:ff:ff

启动虚拟机之后检查，可以看到 ``virbr0`` 设备恢复了UP状态，但是绑定的``virbr0-nic``依然状态DOWN::

   6: virbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
       link/ether 7a:50:26:bf:33:7c brd ff:ff:ff:ff:ff:ff
       inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
          valid_lft forever preferred_lft forever
   7: virbr0-nic: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel master virbr0 state DOWN group default qlen 1000
       link/ether 52:54:00:45:db:25 brd ff:ff:ff:ff:ff:ff
   10: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master virbr0 state UNKNOWN group default qlen 1000
       link/ether 6e:5e:da:70:92:0b brd ff:ff:ff:ff:ff:ff
       inet6 fe80::fc54:ff:fe9f:98b9/64 scope link 
          valid_lft forever preferred_lft forever

这让我很疑惑，特别是虚拟机网开 ``vnet0`` 状态 UNKNOWN 并且 ``virbr0-nic`` 状态始终为DOWN。

检查 ``brctl show`` 显示::

   bridge name  bridge id               STP enabled     interfaces
   br0          8000.7e33f1ea9ee3       no
   virbr0       8000.7a5026bf337c       yes             virbr0-nic
                                                        vnet0

之前发现 ``virbr0`` 接口始终是DOWN状态，这可能是VM网络不通的原因。我关闭虚拟机，使用了 ``ip link set virtbr0 up`` 设置之后，再启动虚拟机，则这个接口会从DOWN自动转变成UP。则此时虚拟机能够通讯了。但是 ``virbr0-nic`` 始终是DOWN状态。

参考 `How virbr0-nic is created? <https://serverfault.com/questions/516366/how-virbr0-nic-is-created>`_ 解说，这个 ``virbr0-nic`` 是网络dummy设备。

使用以下命令可以检查虚拟机的虚拟网卡设备::

   sudo virsh domiflist win10

输出显示::

    Interface   Type     Source   Model    MAC
   -----------------------------------------------------------
    vnet0       bridge   virbr0   virtio   52:54:00:9f:98:b9

参考
========

- `libvirt Networking Handbook - NAT-based network <https://jamielinux.com/docs/libvirt-networking-handbook/nat-based-network.html>`_
- `Libvirt社区文档 - Networking - NAT forwarding (aka "virtual networks") <https://wiki.libvirt.org/page/Networking#NAT_forwarding_.28aka_.22virtual_networks.22.29>`_
