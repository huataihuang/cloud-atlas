.. _pi_ubuntu_network:

=====================
树莓派Ubuntu网络设置
=====================

:ref:`ubuntu64bit_pi` ，设置有线网络静态IP地址以及无线网络。

有线网络(静态地址)
===================

Ubuntu默认使用netplan结合systemd-networkd来完成网络设置，初始安装就激活了有线网卡的的DHCP配置，所以在 ``/etc/netplan/50-cloud-init.yaml`` 配置了::

   network:
       ethernets:
           eth0:
               dhcp4: true
               optional: true
       version: 2

不过，我需要设置固定IP地址，以便部署服务，所以移除 ``50-cloud-init.yaml`` 并添加 ``01-netcfg.yaml`` ::

   network:
       version: 2
       renderer: networkd
       ethernets:
           eth0:
               dhcp4: no
               dhcp6: no
               addresses: [192.168.6.8/24, ]
               #addresses: [192.168.6.8/24,192.168.1.8/24 ]
               #gateway4: 192.168.1.1
               nameservers:
                   addresses: [202.96.209.133, ]

然后执行::

   netplan apply

就激活有线网络的静态IP地址。

无线网络
==========

.. note::

   `How to install Ubuntu on your Raspberry Pi - 3. Wi-Fi or Ethernet <https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#3-wifi-or-ethernet>`_ 提供了一个在安装过程中设置WiFi的步骤，即编辑SD卡的 ``system-boot`` 分区中的 ``network-config`` 文件，去除掉以下段落的注释符号 ``#`` 类似如下::

      wifis:
        wlan0:
        dhcp4: true
        optional: true
        access-points:
          <wifi network name>:
            password: "<wifi password>"

   然后保存。然后用这个SD卡首次启动树莓派，就会自动连接WiFi。

Ubuntu for Raspberry Pi默认已经识别了树莓派的无线网卡，之前在 :ref:`ubuntu_on_mbp` 和 :ref:`ubuntu_on_thinkpad_x220` 都使用了NetworkManager :ref:`set_ubuntu_wifi` 。但是这种方式实际上多安装了组件，并且和默认netplan使用的 ``systemd-networkd`` 是完成相同工作，浪费系统内存资源。

所以，这里采用系统已经安装的 ``netplan`` + ``networkd`` 后端来完成无线设置。

- 配置 ``/etc/netplan/02-wifi.yaml`` ::

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
           "home_ssid_name":
             password: "**********"

然后再次执行::

   netplan apply

激活无线网络。

企业网络链接
=============

如果企业级网络采用了EAP认证，则修订上述配置::

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
           "home_ssid_name":
             password: "**********"
           "office_ssid_name":
             auth:
               key-management: eap
               identity: "user_name"
               password: "user_passwd"

然后再次执行::

   netplan apply

5G Hz无线网络
==============

在树莓派上运行Ubuntu Server，我曾经遇到一个非常诡异的无线网络问题：

- 最初通过 :ref:`netplan` 配置了 PEAP 认证无线网络连接，发现偶尔有不能连接上无线AP的问题。但是最近一次升级重启以后，再也无法连接。可以确定账号密码正确，因为同样的配置，在ThinkPad上运行的Arch Linux完全工作正常。

- 完全相同的 ``wpa_supplicant-office.conf`` 配置

报错排查
===========

在执行 ``netplan apply`` 有时会遇到报错::

   Warning: The unit file, source configuration file or drop-ins of 
   netplan-wpa-wlan0.service changed on disk. 
   Run 'systemctl daemon-reload' to reload units.

这个问题让我很困惑，因为系统重启有时候工作是正常的，有时候无线网络却没有正常运行，启动系统后手工执行命令 ``netplan apply`` 则报上述错误。

排查采用 ``netplan --debug apply`` 


参考
======

- `How to install Ubuntu on your Raspberry Pi <https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi>`_
- `Netplan configuration examples <https://netplan.io/examples/>`_
