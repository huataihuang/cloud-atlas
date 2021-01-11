.. _install_centos8:

=================
安装CentOS8
=================

CentOS 8于2019年9月发布，标志着Red Hat社区进入了一个新的阶段，有必要系统地对企业级Red Hat Linux深入学习。

安装
======

.. note::

   我的学习实践环境是在 :ref:`kvm` 中 :ref:`create_vm` ，安装采用了 2c4g 配置，最小化安装，所以，本文及今后的实践记录将以此为基础展开。

安装完成初步设置
------------------

- 配置固定IP地址是修改 ``/etc/sysconfig/network-scripts/ifcfg-enp1s0`` ::

   TYPE="Ethernet"
   PROXY_METHOD="none"
   BROWSER_ONLY="no"
   DEFROUTE="yes"
   IPV4_FAILURE_FATAL="no"
   NAME="enp1s0"
   UUID="3ccbfb7c-ed47-449b-8e37-f0d072599540"
   DEVICE="enp1s0"
   ONBOOT="yes"
   # 以下为修订值
   IPV6INIT="no"
   IPV6_AUTOCONF="no"
   IPV6_DEFROUTE="no"
   IPV6_FAILURE_FATAL="no"
   IPV6_ADDR_GEN_MODE="stable-privacy"
   BOOTPROTO="static"
   # 以下为增加值
   IPADDR=192.168.122.252
   NETMASK=255.255.255.0
   GATEWAY=192.168.122.1

- 添加 ``/etc/sudoers`` 配置::

   huatai   ALL=(ALL:ALL) NOPASSWD:ALL

- ``huatai`` 用户帐号修改uid为 ``501`` gid 为 ``20``

- 安装必要初始软件包::

   sudo dnf install gcc gcc-c++ git python3

.. note::

   在不同的编译安装环境，可能需要安装不同的软件包。我准备通过 :ref:`vmware_fusion_clone_vm` 创建不同的开发环境，例如 :ref:`gvisor_quickstart` 中安装编译开发环境。
