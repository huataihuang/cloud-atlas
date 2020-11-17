.. _suse_static_ip:

===========================
配置SUSE Linux静态IP地址
===========================

SUSE Linux的配置和 :ref:`redhat_linux` 有很多相似之处，在配置网卡静态IP地址也是配置:

- ``/etc/sysconfig/network/ifcfg-eth0``
- ``/etc/sysconfig/network/routes``
- ``/etc/resolv.conf``

.. note::

   在SUSE Linux 12 SP3上，默认安装gnome图形界面，采用的网络管理器是 ``wicked.service`` ，并且禁用了常用的 :ref:`networkmanager` 。

ifcfg-eth0
============

- 默认配置了DHCP

- 修改 ``/etc/sysconfig/network/ifcfg-eth0`` :

.. literalinclude:: network_config/ifcfg-eth0.dhcp
   :language: bash
   :linenos:

修改成:

.. literalinclude:: network_config/ifcfg-eth0.static_ip
   :language: bash
   :linenos:

- 配置 ``/etc/sysconfig/network/routes`` :

.. literalinclude:: network_config/routes
   :language: bash
   :linenos:

- 配置 ``/etc/resolv.conf`` :

.. literalinclude:: network_config/resolv.conf
   :language: bash
   :linenos:

.. note::

   根据 ``/etc/resolv.conf`` 提示，不应该直接修改该文件，而是应该修改 ``/etc/sysconfig/network/config`` ::

      NETCONFIG_DNS_STATIC_SEARCHLIST="huatai.me"
      NETCONFIG_DNS_STATIC_SERVERS="192.168.6.9 192.168.6.1"

参考
=======

- `Configure Static IP on SUSE Linux <https://sahlitech.com/configure-static-ip-on-suse-linux/>`_
