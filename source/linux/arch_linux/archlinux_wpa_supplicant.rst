.. _archlinux_wpa_supplicant:

==========================================
arch linux使用wpa_supplicant连接无线网络
==========================================

启动 :ref:`asahi_linux` 之后，可以看到已经识别了 :ref:`apple_silicon_m1_pro` MacBook Pro内置的无线网卡 ``wlan0`` 

wpa_supplicant基础配置
========================

- 创建 ``wpa_supplicant`` 的配置文件:

.. literalinclude:: archlinux_wpa_supplicant/wpa_passphrase
   :language: bash

.. note::

   wap_supplicant配置文件命名为 ``/etc/wpa_supplicant/wpa_supplicant-interface.conf`` 可以方便后面结合 :ref:`systemd_networkd` 启动对应的无线网卡

   对于5G的无线网络，需要配置 ``country code``

   对于隐藏AP，需要添加 ``ap_scan``

- 激活对应无线网卡的服务，并且激活dhcpcd (DHCP客户端):

.. literalinclude:: archlinux_wpa_supplicant/systemctl_enable_wpa_passphrase_dhcpcd
   :language: bash

- 已经配置完成，可以重启主机生效或者直接启动服务:

.. literalinclude:: archlinux_wpa_supplicant/systemctl_start_wpa_passphrase_dhcpcd
   :language: bash

企业级wpa_supplicant
=======================

参考
=======

- `archlinux: wpa_supplicant <https://wiki.archlinux.org/title/Wpa_supplicant>`_
