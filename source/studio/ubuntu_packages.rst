.. _ubuntu_packages:

=====================
Ubuntu Server软件包
=====================

Ubuntu Server默认的最小化安装，只安装SSH Server，根据需要逐步增加必要软件包。

这里汇总在各个阶段不断补充完善的软件包组合，作为后续参考。

.. _ubuntu_packages_base:

基础软件包
===============

- 基础软件包（Ubuntu Server通常默认安装) ::

   sudo apt install screen openssh-server nmon net-tools


.. _ubuntu_packages_wifi:

无线网络
===========

- Broadcom BCM43xx 无线网卡驱动安装 ::

   sudo apt update
   sudo apt --reinstall install bcmwl-kernel-source

- 安装NetworkManager :ref:`set_ubuntu_wifi` （包含了 ``nmcli`` 和 ``wpa_supplicant`` ）::

   sudo apt install network-manager
