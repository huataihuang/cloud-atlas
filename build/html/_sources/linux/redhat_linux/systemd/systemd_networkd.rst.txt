.. _systemd_networkd:

=====================
Systemd Networkd服务
=====================

systemd配置静态IP地址
========================

``systemd-networkd`` 配置静态IP地址非常简单，创建一个和网卡接口名相同配置文件，例如 ``eth0`` 创建 ``/etc/systemd/network/10-eth0.network`` 内容如下:

.. literalinclude:: 10-eth0.network
   :language: bash
   :linenos:
   :caption:

- 执行以下命令将默认NetworkManager切换成 ``systemd-networkd`` ::

   systemctl stop NetworkManager.service
   systemctl start systemd-networkd.service
   systemctl restart systemd-resolved.service

   systemctl disable NetworkManager.service
   systemctl enable systemd-networkd.service


systemd创建网桥
=================

.. note::

   在使用 ``systemd-networkd`` 创建网桥前，我们已经有一个 ``/etc/systemd/network/enp0s25.network`` 配置了有线以太网的IP地址

   .. literalinclude:: networkd_conf/enp0s25.network
      :language: bash
      :linenos:

   所以此时 ``ip addr`` 显示 ``enp0s25`` 的地址如下::

      2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
          link/ether f0:de:f1:9b:0c:7b brd ff:ff:ff:ff:ff:ff
          inet 192.168.6.9/24 brd 192.168.6.255 scope global enp0s25
             valid_lft forever preferred_lft forever
          inet6 fe80::f2de:f1ff:fe9b:c7b/64 scope link
             valid_lft forever preferred_lft forever

   我们配置bridge网络，将bridge绑定到 ``enp0s25`` 上，绑定过程中  ``enp0s25`` 接口的IP地址 ``192.168.6.9`` 会丢失

- systemd创建名为 ``br0`` 的网桥使用配置文件 ``/etc/systemd/network/mybridge.netdev`` :

.. literalinclude:: networkd_conf/mybridge.netdev
   :language: bash
   :linenos:

- 然后重启 ``systemd-networkd.service`` ::

   systemctl restart systemd-networkd.service

- 然后执行 ``ip addr`` 检查可以看到以下网桥::

   8: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
       link/ether 7e:33:f1:ea:9e:e3 brd ff:ff:ff:ff:ff:ff

注意，此时接口 ``br0`` 状态还是 ``DOWN``

.. note::

   ``systemd-networkd`` 是基于接口名字和主机ID为网桥设置MAC地址的，但是在某些场景可能存在问题，例如基于MAC过滤的路由。为了能够精确控制网桥MAC地址，可以在上述 ``NetDev`` 段落添加 ``MACAddress=xx:xx:xx:xx:xx:xx`` 来创建指定MAC地址的网桥。

- 将以太网接口绑定到bridge

接下来需要将物理网络接口( ``enp0s25`` )绑定到网桥( ``br0`` )上，则增加一个配置 ``/etc/systemd/network/bind.network`` :

.. literalinclude:: networkd_conf/bind.network
   :language: bash
   :linenos:

这里 ``[Match]`` 段落也配置通配符，也能起到相似作用，例如::

   [Match]
   Name=en*

- 现在重启一次 ``systemd-networkd`` ，此时使用 ``brctl show`` 检查，就看到 ``br0`` 网桥已经启动，并且绑定在 ``enp0s25`` 接口上::

   bridge name	bridge id		STP enabled	interfaces
   br0		8000.7e33f1ea9ee3	no		    enp0s25

- 配置网桥IP

网桥 ``br0`` 已经绑定到以太网物理接口 ``enp0s25`` 上，需要为网桥配置一个指定IP地址。这个配置也是通过 ``.network`` 文件定义，和配置普通网卡相同， ``/etc/systemd/network/mybridge.network`` 配置一个静态IP地址:

.. literalinclude:: networkd_conf/mybridge.network
   :language: bash
   :linenos:

这里也可以使用DHCP来配置网桥::

   [Match]
   Name=br0
   
   [Network]
   DHCP=ipv4

.. note::

   这里有一个疑惑 ``enp0s25.network`` 配置绑定到 ``enp0s25`` 的配置没有生效。在bind到br0之后，IP地址丢失。虽然可以通过 ``ifconfig`` 手工恢复，但是networkd配置文件没有生效。

参考
======

- `arch linxu wiki: systemd-networkd <https://wiki.archlinux.org/index.php/Systemd-networkd>`_
- `18.04 - does it force netplan or can I still use resolved.conf? <https://askubuntu.com/questions/1098052/18-04-does-it-force-netplan-or-can-i-still-use-resolved-conf>`_ 引用了 `systemd.network Examples <https://www.freedesktop.org/software/systemd/man/systemd.network.html#Examples>`_
