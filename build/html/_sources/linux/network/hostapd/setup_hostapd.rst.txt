.. _setup_hostapd:

========================
hostapd实现无线热点
========================

我曾经使用 :ref:`create_ap` 实现了简单的无线AP提供多个设备共享上网，不过，最近 :ref:`setup_hostapd_failed` 。不过，我参考了多个文档后，决定在 :ref:`pi_4` 上(也就是我的 :ref:`arm_k8s` 的master节点)上部署一个无线热点。

激活AP和管理模式并用的WiFi
===========================

通常情况下，我们都使用无线网卡作为无线网络的 "客户端" 模式去连接一个无线AP，这种模式称为 ``managed`` 设备。但是，如果要将Linux主机的无线网卡作为一个WiFi热点，则称为AP模式。由于我们只有一个无线网卡，所以我们需要配置树莓派上的无线网卡 ``wlan0`` 同时工作在AP和管理模式下，以便能够既连接Internet，同时共享AP给其他设备使用，实现一个无线路由器功能。

在树莓派启动时，无线网卡被识别为 ``wlan0`` ，我们需要创建一个udev规则，使得无线网卡 ``wlan0`` 启动时同时能够创建一个 ``managed`` 模式的虚拟网卡。

- 创建 ``/etc/udev/rules.d/70-persistent-net.rules`` ::

   SUBSYSTEM=="ieee80211", ACTION=="add|change", ATTR{macaddress}=="b8:27:eb:ff:ff:ff", KERNEL=="phy0", \
     RUN+="/sbin/iw phy phy0 interface add ap0 type __ap", \
     RUN+="/bin/ip link set ap0 address b8:27:eb:ff:ff:ff"

注意，这里的mac地址必须是无线网卡的mac地址，通过 ``iw dev`` 命令可以查看mac地址，这里创建的虚拟网络设备是 ``ap0`` 。

.. note::

   这步我没有成功，所以我最后还是手工执行命令来激活ap0::

      /sbin/iw phy phy0 interface add ap0 type __ap
      /bin/ip link set ap0 address b8:27:eb:ff:ff:ff

安装DNSmasq和Hostapd
=======================

- Dnsmasq 为WiFi AP 提供DHCP服务
- Hostapd 基于驱动配置来定义无线AP的物理操作

安装::

   sudo apt install dnsmasq hostapd

这里默认启动的dnsmasq服务只启动了dns服务，不会启动dhcp，所以下一步我们需要配置

- 修改 ``/etc/dnsmasq.conf`` 添加如下配置::

   interface=lo,ap0,eth0
   no-dhcp-interface=lo,wlan0
   bind-interfaces
   server=8.8.8.8
   domain-needed
   bogus-priv
   dhcp-range=192.168.10.50,192.168.10.150,12h

- 修订 ``/etc/hostapd/hostapd.conf`` ::

   ctrl_interface=/var/run/hostapd
   ctrl_interface_group=0
   interface=ap0
   driver=nl80211
   ssid=YourApNameHere
   hw_mode=g
   channel=11
   wmm_enabled=0
   macaddr_acl=0
   auth_algs=1
   wpa=2
   wpa_passphrase=YourPassPhraseHere
   wpa_key_mgmt=WPA-PSK
   wpa_pairwise=TKIP CCMP
   rsn_pairwise=CCMP

如果要隐藏SSID，可以添加一行::

   ignore_broadcast_ssid=1

- 修改 ``/etc/default/hostapd`` ::

   DAEMON_CONF="/etc/hostapd/hostapd.conf"

- 修改 ``/etc/network/interfaces`` 来支持AP::

   auto lo
   iface lo inet loopback

   auto ap0
   allow-hotplug ap0
   iface ap0 inet static
       address 192.168.10.1
       netmask 255.255.255.0
       hostapd /etc/hostapd/hostapd.conf

.. note::

   这里没有配置 ``eth0`` 和 ``wlan0`` ，因为我已经配置了使用 :ref:`netplan` 来管理这两个设备。

.. note::

   不需要单独启动hostapd服务，这个服务是通过启动网络接口来启动的。


手工启动
============

- 手工启动虚拟网卡 ``ap0`` (也就是 udev 规则中命令) ::

   /sbin/iw phy phy0 interface add ap0 type __ap
   /bin/ip link set ap0 address b8:27:eb:ff:ff:ff

- 重启一次 ``ap0`` ::

   sudo ifdown --force ap0
   sudo ifup ap0

启动以后可以看到接口::

   ip addr

显示输出::

   ...
   3: wlan0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
       link/ether b8:27:eb:ff:ff:ff brd ff:ff:ff:ff:ff:ff
       inet6 fe80::96eb:cdff:fe8e:eb3f/64 scope link
          valid_lft forever preferred_lft forever
   ...
   9: ap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
       link/ether b8:27:eb:ff:ff:ff brd ff:ff:ff:ff:ff:ff
       inet 192.168.10.1/24 brd 192.168.10.255 scope global ap0
          valid_lft forever preferred_lft forever
       inet6 fe80::96eb:cdff:fe8e:eb3f/64 scope link
          valid_lft forever preferred_lft forever 

可以看到之前 ``wlan0`` 上通过 :ref:`netplan` 获得的无线IP地址消失了，而我们重新启动的 ``ap0`` 则已经分配了静态IP地址。

- 再次执行 ``netplan`` 恢复wlan0的无线IP::

   netplan apply

则再次观察 ``ip addr`` 输出可以看到 ``wlan0`` 和 ``ap0`` 都正确获得IP地址::

   3: wlan0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
       link/ether b8:27:eb:ff:ff:ff brd ff:ff:ff:ff:ff:ff
       inet6 fe80::96eb:cdff:fe8e:eb3f/64 scope link
          valid_lft forever preferred_lft forever
   ...
   9: ap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
       link/ether b8:27:eb:ff:ff:ff brd ff:ff:ff:ff:ff:ff
       inet 192.168.10.1/24 brd 192.168.10.255 scope global ap0
          valid_lft forever preferred_lft forever
       inet6 fe80::96eb:cdff:fe8e:eb3f/64 scope link
          valid_lft forever preferred_lft forever

- 现在我们重新启动dnsmasq为我们的 ``ap0`` 提供DHCP服务::

   systemctl restart dnsmasq

通过 ``systemctl status dnsmasq`` 可以看到分配DHCP::

   ● dnsmasq.service - dnsmasq - A lightweight DHCP and caching DNS server
        Loaded: loaded (/lib/systemd/system/dnsmasq.service; enabled; vendor preset: enabled)
        Active: active (running) since Tue 2021-04-27 23:32:39 CST; 28s ago
       Process: 2542555 ExecStartPre=/usr/sbin/dnsmasq --test (code=exited, status=0/SUCCESS)
       Process: 2542564 ExecStart=/etc/init.d/dnsmasq systemd-exec (code=exited, status=0/SUCCESS)
       Process: 2542574 ExecStartPost=/etc/init.d/dnsmasq systemd-start-resolvconf (code=exited, status=0/SUCCESS)
      Main PID: 2542573 (dnsmasq)
         Tasks: 1 (limit: 2101)
        Memory: 2.0M
        CGroup: /system.slice/dnsmasq.service
                └─2542573 /usr/sbin/dnsmasq -x /run/dnsmasq/dnsmasq.pid -u dnsmasq -7 /etc/dnsmasq.d,.dpkg-dist,.dpkg-old,.dpkg-new --local-service --trust-anchor=.,20326,8,2,e06d4>
   
   Apr 27 23:32:39 pi-master1 dnsmasq[2542573]: started, version 2.80 cachesize 150
   Apr 27 23:32:39 pi-master1 dnsmasq[2542573]: compile time options: IPv6 GNU-getopt DBus i18n IDN DHCP DHCPv6 no-Lua TFTP conntrack ipset auth nettlehash DNSSEC loop-detect inoti>
   Apr 27 23:32:39 pi-master1 dnsmasq-dhcp[2542573]: DHCP, IP range 192.168.10.50 -- 192.168.10.150, lease time 12h
   Apr 27 23:32:39 pi-master1 dnsmasq-dhcp[2542573]: DHCP, sockets bound exclusively to interface ap0
   Apr 27 23:32:39 pi-master1 dnsmasq[2542573]: using nameserver 8.8.8.8#53
   Apr 27 23:32:39 pi-master1 dnsmasq[2542573]: reading /etc/resolv.conf
   Apr 27 23:32:39 pi-master1 dnsmasq[2542573]: using nameserver 8.8.8.8#53
   Apr 27 23:32:39 pi-master1 dnsmasq[2542573]: using nameserver 127.0.0.53#53
   Apr 27 23:32:39 pi-master1 dnsmasq[2542573]: read /etc/hosts - 10 addresses
   Apr 27 23:32:39 pi-master1 systemd[1]: Started dnsmasq - A lightweight DHCP and caching DNS server.

- 万事具备，我们现在可以启动 iptables masquerade ::

   sudo sysctl -w net.ipv4.ip_forward=1
   sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE

问题排查
-----------

我遇到一个问题，客户端可以正确连接到AP并且获得IP地址，也能够ping通网关(即无线AP的地址 192.168.10.1)，而且检查DNS解析也正确(DNS是192.168.10.1，即通过该路由器的dnsmasq代理解析正确)。

但是，无法ping通外网，也无法和外网通讯

- 检查 ``iptables -t nat -L`` 显示::

   Chain POSTROUTING (policy ACCEPT)
   target     prot opt source               destination
   KUBE-POSTROUTING  all  --  anywhere             anywhere             /* kubernetes postrouting rules */
   MASQUERADE  all  --  172.17.0.0/16        anywhere
   RETURN     all  --  pi-master1/16        pi-master1/16
   MASQUERADE  all  --  pi-master1/16       !base-address.mcast.net/4  random-fully
   RETURN     all  -- !pi-master1/16        pi-master1/24
   MASQUERADE  all  -- !pi-master1/16        pi-master1/16        random-fully
   MASQUERADE  all  --  192.168.10.0/24     !192.168.10.0/24

这里可以看到很多NTA规则，原因是这台服务器同时是kubernetes集群的master管控主机。

我怀疑是顺序原因，所以改为在头部插入::

   iptables -t nat -L POSTROUTING --line-numbers -n

显示::

   Chain POSTROUTING (policy ACCEPT)
   num  target     prot opt source               destination
   1    KUBE-POSTROUTING  all  --  0.0.0.0/0            0.0.0.0/0            /* kubernetes postrouting rules */
   2    MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0
   3    RETURN     all  --  10.244.0.0/16        10.244.0.0/16
   4    MASQUERADE  all  --  10.244.0.0/16       !224.0.0.0/4          random-fully
   5    RETURN     all  -- !10.244.0.0/16        10.244.0.0/24
   6    MASQUERADE  all  -- !10.244.0.0/16        10.244.0.0/16        random-fully
   7    MASQUERADE  all  --  192.168.10.0/24     !192.168.10.0/24

- 在第二行插入::

   iptables -t nat -I POSTROUTING 2 -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE

但是依然无效

- 我尝试了清理nat规则::

   iptables -t nat -F

但是发现系统会自动恢复添加以下NAT规则::

   RETURN     all  --  pi-master1/16        pi-master1/16
   MASQUERADE  all  --  pi-master1/16       !base-address.mcast.net/4  random-fully
   RETURN     all  -- !pi-master1/16        pi-master1/24
   MASQUERADE  all  -- !pi-master1/16        pi-master1/16        random-fully

然后即使加了以下nat规则也没有效果::

   MASQUERADE  all  --  192.168.10.0/24     !192.168.10.0/24

我尝试删除::

   iptables -t nat -D POSTROUTING 1
   ...

但是系统不断自动刷新添加，最终么有成功解决

自动化脚本
============

以上手工命令我们可以综合成一个脚本 ``/home/pi/start-ap-managed-wifi.sh`` ::

   #!/bin/bash
   sleep 30
   sudo ifdown --force ap0 && sudo ifup ap0
   sudo netplan apply
   sudo sysctl -w net.ipv4.ip_forward=1
   sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE
   sudo systemctl restart dnsmasq

然后配置一个启动cron::

   sudo crontab -e

添加内容::

   @reboot /home/pi/start-ap-managed-wifi.sh

这样每次重启都会执行上述脚本(脚本第一行添加 ``sleep 30`` 是为了估算启动到网卡时间)

参考
======

- `Raspberry Pi Zero W Simultaneous AP and Managed Mode Wifi <https://blog.thewalr.us/2017/09/26/raspberry-pi-zero-w-simultaneous-ap-and-managed-mode-wifi/>`_
