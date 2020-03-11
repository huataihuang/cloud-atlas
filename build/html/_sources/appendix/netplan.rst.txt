.. _netplan:

================
netplan网络配置
================

.. _netplan_static_ip:

使用netplan配置静态IP
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

.. _netplan_bonding:

netplan配置bonding
===================

简单active-backup bonding
----------------------------

- 参考原先安装虚拟机自动生成的 ``/etc/netplan/50-cloud-init.yaml`` 注释内容，禁用cloud-init网络配置，即创建 ``/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg`` 内容如下::

   network: {config: disabled}

备份原配置::

   cp /etc/netplan/50-cloud-init.yaml ~/
   cd /etc/netplan
   rm -f 50-cloud-init.yaml

- 编辑 ``/etc/netplan/01-netcfg.yaml`` ::

   network:
     version: 2
     renderer: networkd
     ethernets:
       ens33:
         dhcp4: no
         dhcp6: no
       ens38:
         dhcp4: no
         dhcp6: no
     bonds:
       bond0:
         interfaces: [ens33, ens38]
         parameters:
           mode: active-backup
           mii-monitor-interval: 1
           primary: ens33
         addresses: [192.168.161.10/24, ]
         gateway4: 192.168.161.1
         nameservers:
           addresses: [127.0.0.53, ]

bonding上增加VLAN
---------------------

- 编辑 ``/etc/netplan/01-netcfg.yaml`` ::

   network:
     version: 2
     renderer: networkd
     ethernets:
       eth0:
         dhcp4: no
         dhcp6: no
       eth1:
         dhcp4: no
         dhcp6: no
     bonds:
       bond0:
         interfaces: [eth0, eth1]
         parameters:
           mode: active-backup
           mii-monitor-interval: 1
           primary: eth0
     vlans:
       bond0.22:
         id: 22
         link: bond0
         addresses: [ "192.168.1.24/24" ]
         gateway4: 192.168.1.1
         nameservers:
           addresses: [ "192.168.1.1", "192.168.1.17", "192.168.1.33" ]
           search: [ "huatai.me", "huatai.net", "huatai.com" ]

.. note::

   `Red Hat Enterprise Linux 7 Networking Guide Using Channel Bonding <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-using_channel_bonding>`_ 提供了详细的参数设置，通常 ``miimon=time_in_milliseconds`` 设置 100 表示100ms，也就是 0.1s 。不过这里我参考netplan文档设置为1s。

   有关 VLAN over bonding配置请参考 `Netplan - configuring 2 vlan on same bonding <https://askubuntu.com/questions/1112288/netplan-configuring-2-vlan-on-same-bonding>`_

参考
=======

- `How to Configure Network Static IP Address in Ubuntu 18.04 <https://www.tecmint.com/configure-network-static-ip-address-in-ubuntu/>`_
- `Netplan configuration examples <https://netplan.io/examples>`_
