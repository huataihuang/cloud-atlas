.. _systemd_networkd_wlan:

===============================
使用systemd-networkd配置无线
===============================

本质上，无线网络的配置都是通过 :ref:`wpa_supplicant` 来实现的，网络配置管理工具 :ref:`netplan` 、 :ref:`networkmanager` 在管理无线网络底层都是使用 ``wpa_supplicant`` ，区别只是配置方式，底层都是调用 ``wpa_supplicant`` 。

:ref:`systemd_networkd` 也是一种配置管理工具，同样可以结合 ``wpa_supplicant`` 管理无线网络。

由于当前 ``systemd`` 已经成为主要的系统管理框架和组件集，所以使用 ``systemd-networkd`` 结合 ``wpa_supplicant`` 实现无线网络管理，就是一种非常简洁并且不需要第三方管理工具的实现方法。

systemd-networkd配置
======================

所有位于 ``/etc/system/network/`` 目录下 ``.network`` 配置文件都会匹配一个设备实现网络配置。我已经展示了 :ref:`systemd_networkd` 配置有线网络，相似的，我们可以启用无线接口 ``wlan0`` 对应配置文件 ``20-wlan0.network`` (这个文件名只要以 ``.network`` 结尾即可，文件名无要求)

.. literalinclude:: systemd_networkd/20-wlan0.network
   :language: bash
   :linenos:
   :caption:

- 配置5GHz无线网络的国家代码 ``/etc/default/crda`` (重要：对于使用5GHz无线必须配置) :

.. literalinclude:: systemd_networkd/crda
   :language: bash
   :linenos:
   :caption: 5GHz无线网络国家代码配置 /etc/default/crda

- 创建 ``/etc/wpa_supplicant/wpa_supplicant-wlan0.conf`` :

.. literalinclude:: systemd_networkd/wpa_supplicant-wlan0.conf
   :language: bash
   :linenos:
   :caption:

- 启用 systemd-neworkd wpa_supplicant 服务::

   systemctl enable wpa_supplicant@wlan0
   systemctl start wpa_supplicant@wlan0

- 然后检查systemd服务::

   systemctl status wpa_supplicant@wlan0

可以看到 ``wpa_supplicant@wlan0.service`` 对应读取配置是 ``/etc/wpa_supplicant/wpa_supplicant-wlan0.conf`` 就是我们上面配置的wpa_suplicant对应配置文件 ::

   ● wpa_supplicant@wlan0.service - WPA supplicant daemon (interface-specific version)
      Loaded: loaded (/lib/systemd/system/wpa_supplicant@.service; enabled; vendor preset: enabled)
      Active: active (running) since Sun 2021-03-07 00:02:30 CST; 4s ago
    Main PID: 7738 (wpa_supplicant)
       Tasks: 1 (limit: 4915)
      CGroup: /system.slice/system-wpa_supplicant.slice/wpa_supplicant@wlan0.service
              └─7738 /sbin/wpa_supplicant -c/etc/wpa_supplicant/wpa_supplicant-wlan0.conf -Dnl80211,wext -iwlan0
   
   Mar 07 00:02:30 pi400 systemd[1]: Started WPA supplicant daemon (interface-specific version).
   Mar 07 00:02:30 pi400 wpa_supplicant[7738]: Successfully initialized wpa_supplicant
   Mar 07 00:02:33 pi400 wpa_supplicant[7738]: wlan0: Trying to associate with SSID 'office'

- 然后检查 ``ip addr`` 就可以看到无线网卡获得的IP地址并能够连接internet。

参考
======

- `Using systemd-networkd with wpa_supplicant to manage wireless network configuration <https://remy.grunblatt.org/using-systemd-networkd-with-wpa_supplicant-to-manage-wireless-network-configuration.html>`_
- `Managing WPA wireless with systemd-networkd ? <https://bbs.archlinux.org/viewtopic.php?id=178625>`_
