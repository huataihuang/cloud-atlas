.. _alpine_dnsmasq:

========================
Alpine Linux运行dnsmasq
========================

在 :ref:`edge_cloud_infra` 中，部署独立 :ref:`edge_ntp_dns` ( :ref:`dnsmasq` ) 以提供整个边缘云的DNS解析:

软件安装
==========

- 依然是 :ref:`alpine_apk` 安装:

.. literalinclude:: alpine_dnsmasq/apk_add_dnsmasq
   :language: bash
   :caption: alpine linux安装DNSmasq

安装后默认 ``/etc/dnsmasq.conf`` 配置文件

配置
======

配置参考 :ref:`deploy_dnsmasq` ，不过在 :ref:`alpine_linux` 平台一切以简洁为准，所以主要修订:

.. literalinclude:: alpine_dnsmasq/dnsmasq.conf
   :language: bash
   :caption: alpine linux配置DNSmasq /etc/dnsmasq.conf

- 启动dnsmasq并且将dnsmasq服务配置成启动时启动(重要，因为所有服务都会依赖DNS解析，如 :ref:`k3s_ha_etcd` ):

.. literalinclude:: alpine_dnsmasq/start_enable_dnsmasq
   :language: bash
   :caption: alpine linux启动dnsmasq摒弃配置DNSmasq系统启动时启动

