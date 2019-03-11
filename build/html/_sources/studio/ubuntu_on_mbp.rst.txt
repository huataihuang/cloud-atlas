.. _ubuntu_on_mbp:

===========================
MacBook Pro上运行Ubuntu
===========================

安装
=========

现代的Linux操作系统桌面实际上已经非常完善，对于硬件的支持也非常好，除了由于Licence限制无法直接加入私有软件需要特别处理，几乎可以平滑运行在常用的电脑设备上。当然，对于MacBook Pro支持也非常完善。

如果你参考我的 :ref:`base_os` 选择，详细的安装如下：

- :ref:`ubuntu_server`
- :ref:`ubuntu_desktop`

.. note::

   推荐阅读 `archlinux的MacBookPro11,x文档 <https://wiki.archlinux.org/index.php/MacBookPro11,x>`_

安装提示：

- MacBook Pro/Air使用了UEFI（取代了传统的BIOS），这要求硬盘上必须有一个FAT32分区，标记为EFI分区

.. note::

   在Ubuntu安装过程中，磁盘分区中需要先划分的primary分区，标记为EFI分区。这步骤必须执行，否则安装后MacBook Pro无法从没有EFI分区的磁盘启动。

   Ubuntu Desktop版本安装比较灵活，可以自定义EFI分区大小，例如，可以设置200MB。但是，如果使用Ubuntu Server版本，则会强制设置512MB（大小不可调整），而且是系统自动选择创建在 ``/dev/sda1`` 。

- Ubuntu操作系统 ``/`` 分区需要采用 ``Ext4`` 文件系统
  
.. note::

   实践发现和Fedora不同，采用 Btrfs 作为根文件系统（ 特别配置了 ``XFS`` 的 ``/boot`` 分区）无法启动Ubuntu。

配置
==============

- 由于不使用IPv6，所以安装后内核配置参数关闭IPv6

编辑 ``/etc/default/grub`` 设置::

   GRUB_CMDLINE_LINUX="ipv6.disable=1"

然后执行 ``update-grub`` 并重启系统来关闭IPv6

.. note::

   详细请参考 `Ubuntu在MacBook Pro上WIFI <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ubuntu/install/ubuntu_on_macbook_pro_with_wifi.md>`_

.. _set_ubuntu_wifi:

设置无线网络
================

.. note::

   由于版权原因，默认安装的Ubuntu Server/Desktop都没有安装Broadcom无线网卡驱动，请分别参考对应版本安装:

   - :ref:`ubuntu_server`
   - :ref:`ubuntu_desktop`

   安装驱动之后，才能够继续以下配置无线网络操作。


推荐使用NetworkManager管理无线网络，现代主流Linux发行版，不论是 CentOS 7 还是 Ubuntu 18.0.4，默认都采用了NetworkManager来管理网络。详情请参考 `NetworkManager命令行nmcli <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/redhat/system_administration/network/networkmanager_nmcli.md>`_ 。

- 安装NetworkManager::

   sudo apt install network-manager

- 启动NetworkManager::

   sudo systemctl start NetworkManager
   sudo systemctl enable NetworkManager

- 显示所有可以连接的访问热点（AP）::

   sudo nmcli device wifi list

- 新增加一个wifi类型连接，连接到名为 ``HOME`` 的AP上（配置设置成名为 ``MYHOME`` ）::

   nmcli con add con-name MYHOME ifname wlp3s0 type wifi ssid HOME \
   wifi-sec.key-mgmt wpa-psk wifi-sec.psk MYPASSWORD

- 指定配置 ``MYHOME`` 进行连接::

   nmcli con up MYHOME

- 新增加一个公司所用的802.1x认证的无线网络连接，连接到名为 ``OFFICE`` 的AP上（配置设置成 ``MYOFFICE`` ）::

   nmcli con add con-name MYOFFICE ifname wlp3s0 type wifi ssid OFFICE \
   wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
   802-1x.identity "USERNAME" 802-1x.password "MYPASSWORD"

- 执行连接（例如，使用配置 ``MYOFFICE`` ）::

   nmcli con up MYOFFICE

- 开启或关闭wifi::

   sudo nmcli radio wifi <on|off>

.. note::

   ``nmcli`` 指令有很多缩写的方法，只要命令不重合能够区分，例如 ``connection`` 可以缩写成 ``con`` 。
