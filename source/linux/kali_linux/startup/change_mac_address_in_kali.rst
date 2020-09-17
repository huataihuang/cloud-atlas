.. _change_mac_address_in_kali:

======================
Kali Linux伪装MAC地址
======================

.. warning::

   在局域网中通过限制MAC地址方式来限制网络访问，实际效果会非常差，因为很多时候操作系统可以修改MAC地址，导致安全策略无效。

通过修改网卡的MAC地址可以使得Kali Linux在做hack活动之前避免被反向跟踪。

在修改任何网络设备前需要确保已经关闭（down）了设备，然后再运行修改MAC地址的命令。

修改有线网卡MAC地址
=====================

- 如果需要修改 ``eth0`` 网卡的MAC地址，需要关闭网卡::

   ifconfig eth0 down

- 确保该网卡设备停止，然后再修改网卡::

   ifconfig eth0 hw ether 00:11:22:33:44:55

- 然后再次UP起网卡接口，确认MAC地址已经修改成对应的MAC::

   ifconfig eth0 up

修改无线网卡MAC地址
======================

如果要修改无线网卡的MAC地址，则基于使用的不同无线网卡，可能需要采用不同方式。

- 首先检查无线网卡::

   iwconfig

输出显示::

   wlan0     IEEE 802.11bgn  ESSID:off/any
             Mode:Managed  Access Point: Not-Associated   Tx-Power=31 dBm
             Retry short limit:7   RTS thr:off   Fragment thr:off
             Encryption key:off
             Power Management:on

- 关闭该无线网卡接口::

   ifconfig wlan0 down

- 然后再使用 ``iwconfig`` 检查无线网卡接口可以看到(Tx-Power已经去除)::

   wlan0     IEEE 802.11bgn  ESSID:off/any
             Mode:Managed  Access Point: Not-Associated
             Retry short limit:7   RTS thr:off   Fragment thr:off
             Encryption key:off
             Power Management:on

- 使用 ``macchanger`` 工具修改无线网卡的MAC地址::

   macchanger -m 00:11:22:33:44:55 wlan0

- 然后启动无线网卡，检查网卡的MAC地址::

   ifconfig wlan0 up

- 要确保每次系统启动都能够正确修改MAC地址，需要在网卡配置文件 ``/etc/network/interfaces`` ``最后`` 添加如下内容::

   pre-up ifconfig eth0 hw ether 00:33:55:77:99:00

- 然后重启网络服务::

   service network-manager restart

ubuntu macchanger
===================

在Ubuntu中，安装macchanger，则会提示

.. figure:: ../../../_static/linux/kali_linux/startup/ubuntu_macchanger.png
   :scale: 75

.. note::

   实际上系统修改MAC地址有很多种方法，在 `arch linux官方文档-MAC address spoofing <https://wiki.archlinux.org/index.php/MAC_address_spoofing>`_ 提供了不同的方案。使用的工具有两种 ``iproute2`` 和 ``macchanger`` ，不过自动化设置则结合了systemd-networkd，systemd-udevd, systemd unit以及netctl hook等方法。

netplan实现mac spoof
======================

现代的Ubuntu发行版采用了 :ref:`netplan` 来配置网络，这个netplan工具后端实现是通过 systemd 的 networkd 或者 NetworkManager 来实现的，同样支持 :ref:`netplan_mac_spoof` 。

参考
=======

- `Change Mac Address in Kali Linux(Permanently) <https://www.yeahhub.com/change-mac-address-kali-linux-permanently/>`_
