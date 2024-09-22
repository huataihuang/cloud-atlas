.. _linux_wifi_hotspot:

=======================================
linux-wifi-hotspot: 设置Linux无线热点
=======================================

安装
======

Debian/Ubuntu
----------------

- `linux-wifi-hotspot <https://github.com/lakinduakash/linux-wifi-hotspot>`_ 提供了x86版本二进制debian软件包

- 或者通过仓库安装::

   sudo add-apt-repository ppa:lakinduakash/lwh
   sudo apt install linux-wifi-hotspot

Arch
--------

:ref:`arch_linux` 可以通过 :ref:`archlinux_aur` 安装::

   yay -S linux-wifi-hotspot

上述安装命令会移除之前安装过的 :ref:`create_ap` 

源代码编译安装
-----------------

.. note::

   我的源代码编译安装是在 :ref:`install_kali_pi` 环境实践

- 安装编译依赖软件包::

   sudo apt install -y libgtk-3-dev build-essential gcc g++ pkg-config make hostapd

- 编译安装::

   git clone https://github.com/lakinduakash/linux-wifi-hotspot
   cd linux-wifi-hotspot

   #build binaries
   make

   #install
   sudo make install

如果不安装图形工具，则::

   make install-cli-only

命令行操作
============

命令行操作等同 :ref:`create_ap`

- 使用相同wifi接口共享internet::

   create_ap wlan0 wlan0 MyAccessPoint MyPassPhrase

图形界面操作
==============

异常排查
=========

在 :ref:`pi_400` 上运行 :ref:`kali_linux` ，采用同一个无线网卡配置共享WiFi出现报错::

   WARN: brmfmac driver doesn't work properly with virtual interfaces and
   it can cause kernel panic. For this reason we disallow virtual
   interfaces for your adapter.
   For more info: https://github.com/oblique/create_ap/issues/203
   ERROR: Your adapter can not be a station (i.e. be connected) and an AP at the same time

原因如上显示， ``brmfmac`` 驱动对虚拟网卡支持不好，可能会导致内核crash，所以默认关闭了这种网卡的虚拟接口功能。

解决方法可以采用 :ref:`setup_hostapd`

参考
======

- `linux-wifi-hotspot <https://github.com/lakinduakash/linux-wifi-hotspot>`_
