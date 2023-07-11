.. _switch_nm:

=====================
切换NetworkManager
=====================

在Ubuntu桌面和服务器版本，默认使用不同的网络配置工具:

- 桌面版本使用NetworkManager (NetworkManager适合桌面GUI使用)
- 服务器版本使用 :ref:`netplan` 来配置 ``systemd-networkd`` (不过netplan也支持NetworkManager作为后端)

在部署树莓派集群时，我采用完全字符模式运行，虽然安装的 :ref:`jetson` 是NVIDIA L4T的Ubuntu桌面版本，我还是切换成netplan进行配置，不仅统一管理，而且节约了NetworkManager占用的资源。

.. note::

   Jetson Nano的Ubuntu版本netplan使用不如树莓派Ubuntu 20.04，很多管理操作命令方法和netplan官方文档不同，所以我最后放弃了在Jetson Nano的Ubuntu 18.04上使用netplan，返回直接使用NetworkManager进行管理 - 配置无线方法参考 :ref:`ubuntu_on_mbp`

停用Network Manager并激活systemd-networkd
===========================================

- 禁用NetworkManager::

   sudo systemctl stop NetworkManager
   sudo systemctl disable NetworkManager
   sudo systemctl mask NetworkManager

- 启动和激活 ``systemd-networkd`` ::

   sudo systemctl unmask systemd-networkd.service
   sudo systemctl enable systemd-networkd.service
   sudo systemctl start systemd-networkd.service

- netplan配置位于 ``/etc/netplan`` 目录，如果这个目录不存在，首先创建。然后针对网卡添加配置

举例，添加dhcp配置::

   network:
     version: 2
     renderer: networkd
     ethernets:
       enp0s3:
         dhcp4: yes   

.. note::

   我采用配置是静态IP地址配置，采用 :ref:`netplan` 配置方法，不再重复。


- 完成配置后，执行以下命令生效::

   sudo netplan apply

反向操作：激活NetworkManager关闭systemd-networkd
===================================================

以下操作可以反向关闭netplan，重新使用NetworkManager，不过这种方式不建议在Ubuntu server上使用。

- 停止 ``systemd-networkd`` 服务::

   sudo systemctl disable systemd-networkd.service
   sudo systemctl mask systemd-networkd.service
   sudo systemctl stop systemd-networkd.service

- 安装NetworkManager::

   sudo apt-get install network-manager

- 在 ``/etc/netplan`` 目录下将配置文件 ``.yaml`` 中配置修改成使用 ``NetworkManager`` 作为 ``renderer`` ::

   network:
     version: 2
     renderer: NetworkManager

- 然后使用netplan命令生成NetworkManager的后端特定配置文件::

   sudo netplan generate

- 启动NetworkManager服务::

   sudo systemctl unmask NetworkManager
   sudo systemctl enable NetworkManager
   sudo systemctl start NetworkManager

.. note::

   虽然可以在Ubuntu Server版本上通过NetworkManager管理网络，但是从Ubuntu Server 18.04开始，服务器版本已经全面采用 ``systemd-networkd`` 并使用 :ref:`netplan` 来替代NetworkManager配置网络。所以，不建议在服务器上使用NetworkManager。

.. note::

   在 :ref:`cockpit_cannot_refresh_cache_whilst_offline` 需要采用NetworkManager来避免问题，或者配置 ``PackageKit`` 不使用NetworkManager

参考
=========

- `Ubuntu Network Manager: Enabling and disabling NetworkManager on Ubuntu <https://www.configserverfirewall.com/ubuntu-linux/ubuntu-network-manager/>`_
