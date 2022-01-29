.. _build_squid5_ubuntu:

=========================
Ubuntu环境编译Squid 5
=========================

准备
=======

.. note::

   我的编译工作是在 :ref:`priv_cloud_infra` 的 :ref:`priv_kvm` 进行的，采用 ref:`libvirt_lvm_pool` 中 ``clone虚拟机`` 脚本构建的编译虚拟机。

   编译Squid需要大量磁盘空间，默认clone出来虚拟机6G磁盘(实际空闲空间不足3G)因容量不足，首次编译失败。所以，采用 :ref:`libvirt_lvm_pool_resize_vm_disk` 将虚拟机磁盘扩展到 16GB 以完成编译工作。

- 升级操作系统::

   sudo apt update && sudo apt upgrade -y && sudo reboot

- 安装编译所需的工具::

   sudo apt -y install devscripts build-essential fakeroot debhelper dh-autoreconf dh-apparmor cdbs

- 安装squid 5需要的的头文件包::

   sudo apt -y install \
       libcppunit-dev \
       libsasl2-dev \
       libxml2-dev \
       libkrb5-dev \
       libdb-dev \
       libnetfilter-conntrack-dev \
       libexpat1-dev \
       libcap-dev \
       libldap2-dev \
       libpam0g-dev \
       libgnutls28-dev \
       libssl-dev \
       libdbi-perl \
       libecap3 \
       libecap3-dev \
       libsystemd-dev \
       libtdb-dev

编译Squid 5
===============

源代码包是从 http://http.debian.net/debian/pool/main/s/squid/ 获取，所以查看该目录下可以确定最新版本是 ``5.2`` 

- 创建配置文件 ``squid.ver`` :

.. literalinclude:: build_squid5_ubuntu/squid.ver
   :language: bash
   :caption: 编译squid 5脚本配置 squid.ver

- 编译脚本 ``build_squid.sh`` :

.. literalinclude:: build_squid5_ubuntu/build_squid.sh
   :language: bash
   :caption: 编译squid 5脚本: build_squid.sh

- 执行编译::

   ./build_squid.sh

- 安装脚本 ``install_squid.sh`` :

.. literalinclude:: build_squid5_ubuntu/install_squid.sh
   :language: bash
   :caption: 安装squid 5脚本: install_squid.sh

- 执行安装::

   ./install_squid.sh

参考
=====

- `Build Squid 5 on Ubuntu 20.04 LTS <https://docs.diladele.com/howtos/build_squid_on_ubuntu_20/index.html>`_
