.. _alpine_wireless:

========================
设置Alpine Linux无线
========================

wpa_supplicant
===================

使用无线需要安装 ``wpa_supplicant`` ，如果系统没有安装这个软件包，则使用以下命令安装::

   apk add wpa_supplicant

在 :ref:`pi_3` 上安装Alpine Linux默认镜像中已经包含该软件包。

- 检查网络接口::

   ip link

- 将指定无线网卡激活::

   ip link set wlan0 up

- 使用以下命令添加Wi-Fi网络到 ``wpa_supplicant`` ::

   wpa_passphrase 'ExampleWifiSSID' 'ExampleWifiPassword' > /etc/wpa_supplicant/wpa_supplicant.conf

- 然后在前台尝试是否可以连接无线网络::

   wpa_supplicant -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf

- 如果一切正常，则添加 ``-B`` 参数将 ``wpa_supplicant`` 放入后台::

   wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf

- 在正常运行了 ``wpa_supplicant`` 之后，需要配置网卡接口获取IP地址::

   udhcpc -i wlan0

现在可以检查接口是否获得IP::

   ip addr show wlan0

启动时自动配置无线
======================

上述手工配置验证正确后，需要配置一个系统启动时自动启动无线网卡。这个设置是在 ``/etc/network/interfaces`` ，添加以下内容::

   auto wlan0
   iface wlan0 inet dhcp

- 验证配置，首先将接口 down::

   ip link set wlan0 down

- 然后再次启动网络::

   /etc/init.d/networking --quiet restart &

- 如果工作正常，则添加自动启动::

   rc-update add wpa_supplicant boot

- 并确保 ``networking`` 也是自动启动::

   rc-update add networking boot

参考
=======

- `Alpine Linux Wi-Fi <https://wiki.alpinelinux.org/wiki/Wi-Fi>`_
