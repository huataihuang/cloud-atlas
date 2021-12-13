.. _netplan:

================
netplan网络配置
================

Ubuntu发行版默认使用 `Netplan网络配置工具 <https://netplan.io>`_ 配置网络接口，例如我在在 :ref:`pi_ubuntu_network` 中就使用了netplan。netplan支持后端使用 ``networkd`` 或者 ``network-manager`` 进行管理配置。

netplan简介
=============

.. figure:: ../../../_static/linux/ubuntu_linux/network/netplan_design_overview.svg

.. _netplan_static_ip:

激活netplan
==============

Ubuntu在服务器版本默认激活了netplan来配置管理网络，但是在桌面版本，则默认使用NetworkManager管理网络。例如 :ref:`jetson_nano_startup` 可以看到Jetson使用Ubuntu的18.04桌面版本，所以我们需要安装并激活netplan。

- 安装netplan::

   apt install netplan

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

- 默认在 ``/etc/netplan`` 目录下有一个 ``01-netcfg.yaml`` 内容如下:

.. literalinclude:: netplan/01-netcfg-dhcp.yaml
   :language: yaml
   :linenos:
   :caption: netplan初始DHCP配置

.. note::

   如果安装操作系统的时耦没有自动创建一个 ``YAML`` 配置文件，可以通过以下命令先生成一个::

      sudo netplan generate

   不过，对于Ubuntu的desktop, server, cloud版本，自动生成的配置文件会采用不同的名字，例如 ``01-network-manager-all.yaml`` 或 ``01-netcfg.yaml`` 。

- 编辑 ``/etc/netplan/01-netcfg.yaml`` :

.. literalinclude:: netplan/01-netcfg-static.yaml
   :language: yaml
   :linenos:
   :caption: netplan 静态IPP配置

- 执行以下命令生效（注意在控制台执行，否则网络会断开）::

   sudo netplan apply

- 验证检查 ``ifconfig -a`` 可以看到IP地址已经修改成静态配置IP地址

netplan配置有线802.1x认证
============================

企业网络常常会使用802.1x网络实现认证，不仅无线可以通过这种方式加强安全，有线网络也可以实现。netplan也支持在有线网络上加上认证功能，配置案例有些类似后文 ``WPA Enterprise无线网络`` ，案例 ``01-eno4-config.yaml`` 如下:

.. literalinclude:: netplan/01-eno4-config.yaml
   :language: yaml
   :linenos:
   :caption: netplan 802.1x配置

然后执行 ``netplan apply`` 即完成网络激活

netplan配置无线
================

连接开放无线网络
--------------------

对于没有密码要求的无线网络，只需要定义access point::

   network:
     version: 2
     wifis:
       wlan0:
         access-points:
           "open_network_ssid_name": {}
         dhcp4: yes

连接WPA Personal无线
---------------------

对于采用WPA密码保护的无线网络，配置access-point和对应的password就可以。

 - 配置 ``/etc/netplan/02-homewifi.yaml`` ::

    network:
      version: 2
      renderer: networkd
      wifis:
        wlan0:
          dhcp4: yes
          dhcp6: no
          #addresses: [192.168.1.21/24]
          #gateway4: 192.168.1.1
          #nameservers:
          #  addresses: [192.168.0.1, 8.8.8.8]
          access-points:
            "network_ssid_name":
              password: "**********"

WPA Enterprise无线网络
------------------------

在企业网络中，常见的是使用 WPA 或 WPA2 Enterprise加密方式的无线网络，则需要添加认证信息。

- 以下案例是 WPA-EAP 和 TTLS 加密无线网络连接配置::

   network:
     version: 2
     wifis:
       wl0:
         access-points:
           workplace:
             auth:
               key-management: eap
               method: ttls
               anonymous-identity: "@internal.example.com"
               identity: "joe@internal.example.com"
               password: "v3ryS3kr1t"
         dhcp4: yes

- 以下案例是 WPA-EAP 和 TLS加密无线网络::

   network:
     version: 2
     wifis:
       wl0:
         access-points:
           university:
             auth:
               key-management: eap
               method: tls
               anonymous-identity: "@cust.example.com"
               identity: "cert-joe@cust.example.com"
               ca-certificate: /etc/ssl/cust-cacrt.pem
               client-certificate: /etc/ssl/cust-crt.pem
               client-key: /etc/ssl/cust-key.pem
               client-key-password: "d3cryptPr1v4t3K3y"
         dhcp4: yes

.. _netplan_mac_spoof:

netplan mac spoof
==================

如果使用 ``networkd`` 后端，则不支持wifi匹配，只能使用接口名字。以下为举例::

   network:
     version: 2
     renderer: networkd
     wifis:
       wlan0:
         dhcp4: yes
         dhcp6: no
         macaddress: xx:xx:xx:xx:xx:xx
     ...

如果使用NetworkManager后端，还可以采用 ``match:`` 方法::

   network:
     version: 2
     renderer: networkd
     wifis:
       wlan0:
         dhcp4: yes
         dhcp6: no
         match:
           macaddress: yy:yy:yy:yy:yy:yy
         macaddress: xx:xx:xx:xx:xx:xx
     ...

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

没有netplan配置systemd-networkd
=================================

实际上你可以不使用netplan也不使用NetworkManager就可以配置网络，因为 :ref:`systemd` 实际上提供了完整的系统配置功能。默认启动的 ``systemd-networkd`` 接管了所有网络配置，所以手工添加配置也可以实现配置。

所有的 ``systemd-networkd`` 配置位于 ``/etc/systemd/network/`` 目录下，例如， ``enp0s25.network`` 配置内容::

   [Match]
   Name=enp0s25

   [Network]
   Address=192.168.6.9/24
   GATEWAY=192.168.6.10
   DNS=192.168.6.10

此时只需要重新加载一次 ``systemd-networkd`` 就可以::

   systemctl restart systemd-networkd

netplan问题排查
================

.. warning::

   netplan似乎不需要作为服务启动，而仅仅是作为一个前端工具，实际调用的是 networkd 和 NetworkManager来完成配置。我在Jetson Nano的Ubuntu 18.04使用netplan失败，似乎这个版本比较老，和现有netplan文档不能对齐，并且使用也很怪异，所以我还是使用 :ref:`switch_nm` 重新切回NetworkManager进行管理。

   以下是一些debug经验记录，仅供参考。

:ref:`switch_nm` 之后，我在 :ref:`jetson` 上将NetworkManager切换成netplan。但是，我发现 ``netplan apply`` 之后，网卡上并没有绑定静态配置的IP地址。虽然看上去 ``/etc/netplan/01-netcfg.yaml`` 和原先在树莓派上运行的Ubuntu 20.04没有什么区别::

   network:
     version: 2
     renderer: networkd
     ethernets:
       eth0:
         dhcp4: no
         dhcp6: no
         addresses: [192.168.6.10/24, ]
         nameservers:
           addresses: [202.96.209.133, ]

既然使用 ``networkd`` 作为 ``renderer`` ，就应该生成 ``systemd-networkd`` 使用的配置文件，但是在 ``/etc/systemd/network`` 目录下没有生成任何配置文件。

参考 `networkd not applying config - missing events? <https://bugs.launchpad.net/ubuntu/+source/netplan.io/+bug/1775566>`_ 可以看到，需要使用 ``networkctl list`` 查看一下网卡是否受到管理::

   networkctl list

果然，我输出显示::

   IDX LINK             TYPE               OPERATIONAL SETUP
     1 lo               loopback           carrier     unmanaged
     2 dummy0           ether              off         unmanaged
     3 eth0             ether              routable    unmanaged
     4 wlan0            wlan               off         unmanaged
     5 l4tbr0           ether              off         unmanaged
     6 rndis0           ether              no-carrier  unmanaged
     7 usb0             ether              no-carrier  unmanaged

对比树莓派上 ``networkctl list`` 显示输出::

   IDX LINK  TYPE     OPERATIONAL SETUP
     1 lo    loopback carrier     unmanaged
     2 eth0  ether    routable    configured
     3 wlan0 wlan     routable    configured

networkctl
------------

参考 `networkctl — Query the status of network links <https://www.freedesktop.org/software/systemd/man/networkctl.html>`_ ``networkctl`` 可以用于检查网络连线的状态是否被 ``systemd-networkd`` 看到。参考 `systemd-networkd.service, systemd-networkd — Network manager <https://www.freedesktop.org/software/systemd/man/systemd-networkd.service.html#>`_ :

- ``systemd-networkd`` 会管理在 ``[Match]`` 段落找到的 ``.network`` 文件中的任何连接来管理网络地址和路由。
- 由于我执行 ``netplan apply`` 没有生成对应的 networkd 配置文件，所以导致网络没有配置

我尝试先创建空的 ``/etc/netplan`` 目录，然后执行::

   netplan -d generate

显示::

   netplan: netplan version 2.2 starting at Tue Oct 13 22:54:14 2020
   netplan: database directory is /var/lib/plan/netplan.dir
   netplan: user "netplan" is uid 63434 gid 63434
   netplan: switching from user <root> to <uid 63434 gid 63434>
   netplan: running with uid=63434 gid=63434 euid=63434 egid=63434
   netplan: reading access list file /var/lib/plan/netplan.dir/.netplan-acl
   netplan: netplan/tcp not found in /etc/services, using ports 2983 and 5444

- 仔细检查了 ``systemctl status netplan`` ，发现原因了：没有激活netplan daemon::

   ● netplan.service - LSB: Netplan calendar service.
      Loaded: loaded (/etc/init.d/netplan; generated)
      Active: active (exited) since Tue 2020-10-13 21:12:52 CST; 1h 47min ago
        Docs: man:systemd-sysv-generator(8)
     Process: 4631 ExecStart=/etc/init.d/netplan start (code=exited, status=0/SUCCESS)
   
   10月 13 21:12:51 jetson systemd[1]: Starting LSB: Netplan calendar service....
   10月 13 21:12:52 jetson netplan[4631]: Netplan daemon not enabled in /etc/init.d/netplan.
   10月 13 21:12:52 jetson systemd[1]: Started LSB: Netplan calendar service..

上述日志显示在 ``/etc/init.d/netplan`` 中没有激活netplan服务，所以实际该服务状态是 ``active(exited)`` ，也就是退出状态。

编辑 ``/etc/init.d/netplan`` 文件，将::

   # Set ENABLED=0 to disable, ENABLED=1 to enable.
   ENABLED=0

修改成::

   # Set ENABLED=0 to disable, ENABLED=1 to enable.
   ENABLED=1

- 然后再次执行启动 ``netplan`` ::

   systemctl start netplan

此时提示::

   Warning: The unit file, source configuration file or drop-ins of netplan.service changed on disk. Run 'systemctl daemon-reload' to reload units.

所以按照提示执行::

   systemctl daemon-reload
   systemctl restart netplan

启动之后再次检查 ``systemctl status netplan`` 则可以看到状态::

   ● netplan.service - LSB: Netplan calendar service.
      Loaded: loaded (/etc/init.d/netplan; generated)
      Active: active (running) since Tue 2020-10-13 23:07:44 CST; 1min 8s ago
        Docs: man:systemd-sysv-generator(8)
     Process: 8386 ExecStop=/etc/init.d/netplan stop (code=exited, status=0/SUCCESS)
     Process: 8430 ExecStart=/etc/init.d/netplan start (code=exited, status=0/SUCCESS)
       Tasks: 1 (limit: 4174)
      CGroup: /system.slice/netplan.service
              └─8464 /usr/sbin/netplan
   
   10月 13 23:07:43 jetson systemd[1]: Starting LSB: Netplan calendar service....
   10月 13 23:07:44 jetson systemd[1]: Started LSB: Netplan calendar service..

- 但是比较奇怪，我执行 ``netplan -d generate`` 始终不生成配置文件，仅提示::

   netplan: netplan version 2.2 starting at Tue Oct 13 23:25:29 2020
   netplan: database directory is /var/lib/plan/netplan.dir
   netplan: user "netplan" is uid 63434 gid 63434
   netplan: switching from user <root> to <uid 63434 gid 63434>
   netplan: running with uid=63434 gid=63434 euid=63434 egid=63434
   netplan: reading access list file /var/lib/plan/netplan.dir/.netplan-acl
   netplan: netplan/tcp not found in /etc/services, using ports 2983 and 5444

根据 `netplan-generate - generate backend configuration from netplan YAML files <http://manpages.ubuntu.com/manpages/cosmic/man8/netplan-generate.8.html>`_ 说明：

- ``netplan generate`` 是根据 netplan 的 yaml配置来调用networkd后端或者NetworkManager后端来生成对应后端服务的配置文件
- 通常不需要独立运行 ``netplan generate`` ，只需要运行 ``netplan apply`` 就可以，因为 ``netplan apply`` 会自动调用 ``netplan generate`` ，而 ``netplan generate`` 只是为了验证配置生成
- ``netplan`` 会一次从以下3个位置读取配置文件，并且按照优先级，仅有一个位置的配置文件生效:

  - ``/run/netplan`` 优先级最高
  - ``/etc/netplan`` 次优先级
  - ``/lib/netplan`` 最低优先级

参考 `netplan - Troubleshooting networking issues <https://netplan.io/troubleshooting/>`_ 当出现配置不能生成，需要将后端服务器启动成debug模式。例如，我使用 ``systemd-netowrkd`` 则需要启用 `DebuggingSystemd <https://wiki.ubuntu.com/DebuggingSystemd>`_ ::

   sudo systemctl stop systemd-networkd
   SYSTEMD_LOG_LEVEL=debug /lib/systemd/systemd-networkd

但是我发现我执行 ``netplan generate`` 和 ``netplan apply`` 都没有任何影响，似乎就没有连接上。

虽然手工可以创建一个 ``/run/systemd/network/10-netplan-eth0.network`` 填写内容::

   [Match]
   Name=eth0
   
   [Network]
   LinkLocalAddressing=ipv6
   Address=192.168.6.10/24
   DNS=202.96.209.133

配置创建后，执行 ``networkctl`` 就可以看到该eth0网卡是 ``configured`` ，似乎状态正常了。但是重启主机则网卡又是 ``unmanaged`` 并且 ``/run/systemd/network`` 目录又空了。

发现一个蹊跷，执行 ``netplan -d -v generate`` 显示输出::

   netplan: netplan version 2.2 starting at Wed Oct 14 09:46:03 2020
   netplan: database directory is /var/lib/plan/netplan.dir
   ...

为何显示数据库目录是 ``/var/lib/plan/netplan.dir`` ?

我这个版本的netplan默认去读取了空白的 ``/var/lib/plan/netplan.dir`` ，这个和官方文档不同。我尝试移除这个目录::

   cd /var/lib
   mv plan plan.bak

再次启动 ``netplan -d -v generate`` 显示::

   netplan: netplan version 2.2 starting at Wed Oct 14 09:49:16 2020
   netplan: database directory is /var/lib/plan/netplan.dir
   netplan: user "netplan" is uid 63434 gid 63434
   netplan: switching from user <root> to <uid 63434 gid 63434>
   netplan: running with uid=63434 gid=63434 euid=63434 egid=63434
   netplan: no read/write access to /var/lib/plan/netplan.dir/.: No such file or directory

这个版本的netplan可能是早期版本，只能固定读取 ``/var/lib/plan/netplan.dir/`` ，不使用 ``/etc/netplan`` 目录，导致我配置无效。我还发现在 ``/var/lib/plan/netplan.dir/`` 有一个隐含文件::

   .netplan-acl -> /etc/plan/netplan-acl

5G Hz无线网络连接
===================

在树莓派上配置了netplan的无线配置，配置文件 ``/etc/netplan/02-wifi.yaml``::

   network:
     version: 2
     renderer: networkd
     wifis:
       wlan0:
         optional: true
         dhcp4: yes
         dhcp6: no
         access-points:
           "SSID-HOME":
             password: "home-passwd"
           "SSID-OFFICE":
             auth:
               key-management: eap
               identity: "office.id"
               password: "office-passwd"

但是发现无线始终无法连接， ``ip addr`` 显示::

   3: wlan0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
       link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff

- 使用 ``iwconfig`` 检查::

   wlan0     IEEE 802.11  ESSID:off/any
             Mode:Managed  Access Point: Not-Associated   Tx-Power=31 dBm
             Retry short limit:7   RTS thr:off   Fragment thr:off
             Encryption key:off
             Power Management:on

- 使用 ``networkctl list`` 检查发现::

   IDX LINK  TYPE     OPERATIONAL SETUP      
     1 lo    loopback carrier     unmanaged
     2 eth0  ether    routable    configured
     3 wlan0 wlan     no-carrier  configuring
   
   3 links listed.

- 检查无线网络连接服务配置状态::

   systemctl status netplan-wpa-wlan0.service

显示连接了一个明显错误的 ``bssid=00:00:00:00:00:00`` 的无线AP，导致认证错误::

   ● netplan-wpa-wlan0.service - WPA supplicant for netplan wlan0
        Loaded: loaded (/run/systemd/system/netplan-wpa-wlan0.service; enabled-runtime; vendor preset: enabled)
        Active: active (running) since Thu 2020-11-05 16:17:34 CST; 2min 7s ago
      Main PID: 1932 (wpa_supplicant)
         Tasks: 1 (limit: 9257)
        CGroup: /system.slice/netplan-wpa-wlan0.service
                └─1932 /sbin/wpa_supplicant -c /run/netplan/wpa-wlan0.conf -iwlan0
   
   Nov 05 16:18:51 pi-worker2 wpa_supplicant[1932]: wlan0: CTRL-EVENT-ASSOC-REJECT bssid=00:00:00:00:00:00 status_code=16
   Nov 05 16:10:27 pi-worker2 wpa_supplicant[1849]: wlan0: Trying to associate with SSID 'SSID-OFFICE'
   Nov 05 16:10:30 pi-worker2 wpa_supplicant[1849]: wlan0: CTRL-EVENT-ASSOC-REJECT bssid=00:00:00:00:00:00 status_code=16
   Nov 05 16:10:30 pi-worker2 wpa_supplicant[1849]: wlan0: CTRL-EVENT-SSID-TEMP-DISABLED id=0 ssid="SSID-OFFICE" auth_failures=1 duration=23 reason=CONN_FAILED   

经过一周 `排查wpa_supplicant无法连接5GHz无线问题 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/redhat/system_administration/systemd/debug_systemd_networkd.md>`_ 终于发现对于5G Hz无线网络连接，必须在 ``wpa_supplicant.conf`` 中指定 ``Country Code`` 。

不过，netplan的配置中当前不支持配置 ``country=`` ，所以可以采用两种方法：

- 在执行 ``wpa_supplicant`` 之前，先通过 ``wireless-tools`` 工具包中的 ``iw`` 命令设置 ``regdomain`` ::

   iw reg set CN

然后 ``wpa_supplicant`` 就可以连接5G Hz的无线AP。

- 为了能够持久化上述 ``regdomain`` 配置，在Ubuntu中，可以修改 ``/etc/default/crda`` 配置设置如下::

   REGDOMAIN=CN

然后重启就能够正常连接5G Hz无线网络。

参考
=======

- `How to Configure Network Static IP Address in Ubuntu 18.04 <https://www.tecmint.com/configure-network-static-ip-address-in-ubuntu/>`_
- `Netplan configuration examples <https://netplan.io/examples>`_
- `Netplan not spoofing MAC as expected <https://serverfault.com/questions/920020/netplan-not-spoofing-mac-as-expected>`_
- `Netplan reference <https://netplan.io/reference/>`_
- `How to configure networking with Netplan on Ubuntu <https://vitux.com/how-to-configure-networking-with-netplan-on-ubuntu/>`_
