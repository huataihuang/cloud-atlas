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

在操作系统启动时会自动完成上述旧系统命名 ``eth0`` 和 ``wlan0`` 自动转换成明确区分的网络设备名。

在debian 9 或者  Ubuntu 15.04 开始，作为 :ref:`systemd` 的组成部分，该特性称为 `可预测的网络接口命名 <https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/>`_ 。早期简化的 ``eth0`` , ``eth1`` 是操作系统启动时根据驱动检测到设备的顺序命名的，由于每次初始化顺序的不确定性，会导致 ``ethX`` 和实际网卡不是固定的对应关系。从 :ref:`systemd` / udev 版本 v197开始，在 ``udev``
原生命名网络接口如下:

- 根据主板设备Firmware/BIOS提供的索引命名（例如 eno1)
- 根据PCI Express热插拔槽索引号命名 (例如 ens1)
- 根据硬件连接器的物理位置命名 (例如 enp2s0)
- 根据网卡MAC地址命名 (例如 enx78e7d1ea46da)
- 经典的不可预测的内核原生 ``ethX`` 命名 (例如 eth0)

使用 ``可预测的网络接口命名`` 优点:

- 重启后获得稳定不变的接口名
- 即使硬件添加或移除，接口命名不变
- 内核升级或更改也不改变接口名
- 无需用户配置设备名自动分配
- 接口名是可预测的
- 适用于x86和非x86平台

如何禁用 ``可预测的网络接口命名``
=====================================

由于某些兼容性原因，或者你就是不需要，则可以通过以下 ``3种方式之一`` **禁用** ``可预测的网络接口命名`` :

- 使用屏蔽掉 ``udev`` 的软连接来恢复使用以前的那种不可预测内核设备名::

   ln -s /dev/null /etc/systemd/network/99-default.link

- 创建自己的手动命名计划(scheme)，例如可以命名为 ``internet0`` , ``dmz0`` 或 ``lan0`` 等。详细语法参考 `systemd.link(5) <https://www.freedesktop.org/software/systemd/man/systemd.link.html>`_ ，简单的案例如下 ``/etc/systemd/network/10-dmz.link`` :

.. literalinclude:: udev_rename_nic/10-dmz.link
   :language: ini
   :caption: /etc/systemd/network/10-dmz.link

- 在内核命令行参数添加 ``net.ifnames=0`` 则自动恢复原先旧有的 ``eth0`` 这样的命名方式

使用 ``udev`` 规则重命名设备
==============================

.. note::

   使用 ``udev`` 规则重命名设备是一种比较常用且约定俗成的运维方法。当然，也可以使用上文 "如何禁用 ``可预测的网络接口命名`` " 方法二，使用类似 ``/etc/systemd/network/10-dmz.link`` 配置来通过 :ref:`systemd_networkd` 配置设备命名

- 配置 ``/etc/udev/rules.d/30-net_names.rules``

.. literalinclude:: udev_rename_nic/30-net_names.rules
   :caption: 网络设备添加时通过udev规则重命名设备

重启系统后，对应的有线和无线网卡会分别重命名为 ``eth0`` 和 ``wlan0``

其他配置案例也可以采用以下方式::

   KERNEL=="eth*", SYSFS{address}=="00:12:34:fe:dc:ba", NAME="eth0"
   KERNEL=="eth*", SYSFS{address}=="00:56:78:98:76:54", NAME="eth1"

参考
=====

- `How to rename Ethernet devices through udev <https://www.suse.com/support/kb/doc/?id=000015954>`_
- `Rename Network Interface using udev in Debian <http://www.debianhelp.co.uk/udev.htm>`_
- `Why is my network interface named enp0s25 instead of eth0? <https://askubuntu.com/questions/704361/why-is-my-network-interface-named-enp0s25-instead-of-eth0>`_
- `How can I show the old eth0 names and also rename network interfaces in debian 9 stretch? <https://unix.stackexchange.com/questions/396382/how-can-i-show-the-old-eth0-names-and-also-rename-network-interfaces-in-debian-9>`_
- `How to rename network interface in 15.10? <https://askubuntu.com/questions/689501/how-to-rename-network-interface-in-15-10>`_
