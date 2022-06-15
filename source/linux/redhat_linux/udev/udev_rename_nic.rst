.. _udev_rename_nic:

========================
通过udev重命名网络设备名
========================

在 :ref:`thinkpad_x220` 上安装Linux系统，会看到网络设备命名不是约定俗成的 ``eth0`` 和 ``wlan0`` 而是:

- Intel 82579LM 千兆有线网卡: ``enp0s25``
- Intel Advanced-N 6205无线网卡: ``wlp3s0``

这对一些配置工作带来困扰，也不方便编写通用的网络配置脚本。

为了能够稳定识别网络设备并转换成标准的 ``eth0`` 和 ``wlan0`` ，方便 :ref:`archlinux_config_ip` ，使用 ``udev`` 规则来完成命名转换。

操作步骤
==========

- 首先找出网络设备的MAC地址，这个MAC地址将用于 ``udev`` 规则匹配设备::

   ip link

例如输出::

   2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
       link/ether f0:de:f1:9b:0c:7b brd ff:ff:ff:ff:ff:ff
   3: wlp3s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
       link/ether 08:11:96:8a:e2:b4 brd ff:ff:ff:ff:ff:ff

可以看到系统中网络设备::

   enp0s25   f0:de:f1:9b:0c:7b
   wlp3s0    08:11:96:8a:e2:b4

为什么网络设备会这样命名
==========================

实际上网络设备命名是为了唯一标识设备，所以操作系统启动时内核特意把网络设备按照驱动进行重命令。例如::

      dmesg | grep enp

可以看到::

   [    8.175520] e1000e 0000:00:19.0 enp0s25: renamed from eth0
   [   11.651108] e1000e 0000:00:19.0 enp0s25: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
   [   11.651200] IPv6: ADDRCONF(NETDEV_CHANGE): enp0s25: link becomes ready

无线网卡也是如此::

   dmesg | grep wlp

显示从wlan0重命名::

   [    8.643639] iwlwifi 0000:03:00.0 wlp3s0: renamed from wlan0

在操作系统启动时会自动完成上述旧系统命名 ``eth0`` 和 ``wlan0`` 自动转换成明确区分的网络设备名。在debian 9 或者  Ubuntu 15.10 开始就是这种方式。可以避免当系统多次重启且安装了多块网卡时，重启时无法保证每次网卡都同样命名的问题。



- 配置 ``/etc/udev/rules.d/30-net_names.rules``

参考
=====

- `How to rename Ethernet devices through udev <https://www.suse.com/support/kb/doc/?id=000015954>`_
- `Rename Network Interface using udev in Debian <http://www.debianhelp.co.uk/udev.htm>`_
- `Why is my network interface named enp0s25 instead of eth0? <https://askubuntu.com/questions/704361/why-is-my-network-interface-named-enp0s25-instead-of-eth0>`_
- `How can I show the old eth0 names and also rename network interfaces in debian 9 stretch? <https://unix.stackexchange.com/questions/396382/how-can-i-show-the-old-eth0-names-and-also-rename-network-interfaces-in-debian-9>`_
