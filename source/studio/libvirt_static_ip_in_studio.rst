.. _libvirt_static_ip_in_studio:

================================
Studio环境libvirt静态分配IP
================================

默认情况下libvirt内置的dnsmasq服务会动态分配IP地址给虚拟机，这导致每次启动的虚拟机IP地址可能不同。有部分作为固定服务的虚拟机IP地址期望不变，需要对libvirt的default网络做一些修改。

详细配置请参考 `KVM libvirt静态分配IP和端口转发 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/kvm/startup/in_action/kvm_libvirt_static_ip_for_dhcp_and_port_forwarding.md>`_

这里没有采用配置dnsmasq的static DHCP方法，而是修改libvirt的DHCP的range，空出部分IP地址不分配，然后在虚拟机内部配置静态IP地址，这样更为简洁方便，

libvirt的DHCP分配范围调整
===========================

- 检查libvirt网络::

   virsh net-list

可以看到输出::

   Name                 State      Autostart     Persistent
   ----------------------------------------------------------
   default              active     yes           yes 

- 编辑默认网络::

   virsh net-edit default

将::

    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>

修改成::

    <dhcp>
      <range start='192.168.122.51' end='192.168.122.254'/>
    </dhcp>

这样，IP地址段 ``192.168.122.1 ~ 192.168.122.50`` 就不会动态分批，保留给固定IP地址使用。

- 重新生成libvirt网络::

   virsh  net-destroy default
   virsh  net-start default 

- 然后重新将虚拟机网络连接::

   brctl addif virbr0 vnet0
   brctl addif virbr0 vnet1
   ...

.. note::

   Host主机 ``/var/lib/libvirt/dnsmasq/virbr0.status`` 提供了当前dnsmasq分配的IP地址情况。

配置Ubuntu虚拟机的静态IP
==========================

对于Kubernetes master等服务器，我期望IP地址是固定的IP地址，所以准备配置static IP。不过，Ubuntu 18系列的静态IP地址配置方法和以前传统配置方法不同，采用了 ``.yaml`` 配置文件，通过 ``netplan`` 网络配置工具来修改。

.. note::

   根据Ubuntu的安装不同，有可能你的安装并没有包含Netplan，则依然可以采用传统的Debian/Ubuntu配置静态IP的方法，即直接修改 ``/etc/network/interfaces`` 来实现。不过，从Ubuntu 17.10 开始，已经引入了 Netplan 网络配置工具。

Netplan允许通过YAML抽象来配置网络接口，在 ``NetworkManager`` 和 ``systemd-networkd`` 网络服务（引用为 ``renderers`` )结合共同工作。

Netplan会读取 ``/etc/netplan/*.yaml`` 配置文件来设置所有的网络接口。

列出所有激活的网络接口
--------------------------

- 使用 ``ifconfig`` 命令列出所有网络接口::

   ifconfig -a

例如，看到的输出数据（DHCP）::

   ens2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
           inet 192.168.122.61  netmask 255.255.255.0  broadcast 192.168.122.255
           inet6 fe80::5054:ff:fe97:c338  prefixlen 64  scopeid 0x20<link>
           ether 52:54:00:97:c3:38  txqueuelen 1000  (Ethernet)
           RX packets 382  bytes 45170 (45.1 KB)
           RX errors 0  dropped 84  overruns 0  frame 0
           TX packets 165  bytes 22890 (22.8 KB)
           TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

- 默认在 ``/etc/netplan`` 目录下有一个 ``01-netcfg.yaml`` 内容如下::

   # This file describes the network interfaces available on your system
   # For more information, see netplan(5).
   network:
     version: 2
     renderer: networkd
     ethernets:
       ens2:
         dhcp4: yes

.. note::

   如果安装操作系统的时耦没有自动创建一个 ``YAML`` 配置文件，可以通过以下命令先生成一个::

      sudo netplan generate

   不过，对于Ubuntu的desktop, server, cloud版本，自动生成的配置文件会采用不同的名字，例如 ``01-network-manager-all.yaml`` 或 ``01-netcfg.yaml`` 。

- 编辑 ``/etc/netplan/01-netcfg.yaml`` ::

   network:
     version: 2
     renderer: networkd
     ethernets:
       ens2:
         dhcp4: no
         dhcp6: no
         addresses: [192.168.122.11/24, ]
         gateway4: 192.168.122.1
         nameservers:
            addresses: [192.168.122.1, ]

- 执行以下命令生效（注意在控制台执行，否则网络会断开）::

   sudo netplan apply

- 验证检查 ``ifconfig -a`` 可以看到IP地址已经修改成静态配置IP地址

参考
=========

- `How to Configure Network Static IP Address in Ubuntu 18.04 <https://www.tecmint.com/configure-network-static-ip-address-in-ubuntu/>`_
