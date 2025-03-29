.. _edge_ntp_dns:

=====================
边缘云NTP和DNS服务
=====================

我最初部署 :ref:`priv_cloud_infra` 时为整个私有网络部署了两个重要的基础服务:

- :ref:`priv_ntp`
- :ref:`priv_dnsmasq_ics`

这两个关键服务也是同时提供给 :ref:`edge_cloud_infra` 共用的。

随着 :ref:`priv_cloud` 和 :ref:`edge_cloud` 拆分(部署到隔离的两个网络)， :ref:`edge_cloud_infra` 缺乏 :ref:`dns` 和 :ref:`ntp` 支持，会产生异常。所以，独立在 alpine linux 环境下重新部署:

- :ref:`alpine_chrony`
- :ref:`alpine_dnsmasq`

在集群中部署 :ref:`ntp` 和 :ref:`dns` 是非常不起眼但是又非常重要的步骤:

- :ref:`raspberry_pi` 这样低成本SBC系统没有RTC时钟，每次系统重启如果没有 :ref:`alpine_chrony` 提供时钟矫正将无法正常运行( :ref:`alpine_pi_clock_skew` )
- 集群( :ref:`distributed_system` )业务跨节点调度和通讯强依赖每个节点时钟一致，任何时钟扭曲都会造成应用异常甚至崩溃
- :ref:`etcd` 等服务使用域名解析来完成节点互相访问，所以在 :ref:`edge_cloud_infra` 如果不提供 :ref:`alpine_dnsmasq` DNS解析，则 ``etcd`` 甚至找不到peer节点导致无法启动(例如我在配置中采用了主机名而不是直接的IP)

部署NTP服务: :ref:`chrony`
============================

- 使用 :ref:`alpine_apk` 安装 ``chrony`` (也可能在 :ref:`alpine_install_pi_usb_boot` 已经安装过)

- 选择一台服务器，例如 ``x-k3s-m-1`` 作为服务器，配置 ``/etc/chrony/chrony.conf`` :

.. literalinclude:: ../../linux/alpine_linux/alpine_chrony/chrony-server.conf
   :language: bash
   :caption: chrony服务器的/etc/chrony/chrony.conf配置

- 重启 ``x-k3s-m-1`` 上 ``chronyd`` 服务，则该NTP服务器会和internet上时钟服务器进行时钟同步，并为局域网内部服务器提供NTP服务:

.. literalinclude:: ../../linux/alpine_linux/alpine_chrony/restart_chronyd
   :language: bash
   :caption: alpine linux系统中重启chronyd服务

- 除了 ``x-k3s-m-1`` 外，其他 :ref:`edge_cloud_infra` 主机都是NTP客户端，则都以 ``x-k3s-m-1`` 为NTP服务器，配置 ``/etc/chrony/chrony.conf`` 如下:

.. literalinclude:: ../../linux/alpine_linux/alpine_chrony/chrony-client.conf
   :language: bash
   :caption: chrony服务端的/etc/chrony/chrony.conf配置

- 同样NTP客户端也需要重启chronyd来以 ``x-k3s-m-1`` 为基准矫正时间:

.. literalinclude:: ../../linux/alpine_linux/alpine_chrony/restart_chronyd
   :language: bash
   :caption: alpine linux系统中重启chronyd服务

完成上述部署之后，请仔细核对所有节点，确保时钟一致。则我们就可以开始下一步部署

部署DNS服务: :ref:`dns`
===========================

:ref:`edge_cloud_infra` 作为边缘云，要求系统精简轻量级，所以部署DNS服务也是选择轻量级的 :ref:`dnsmasq` 

- :ref:`alpine_apk` 安装:

.. literalinclude:: ../../linux/alpine_linux/alpine_dnsmasq/apk_add_dnsmasq
   :language: bash
   :caption: alpine linux安装DNSmasq

- 参考 :ref:`deploy_dnsmasq` 配置 ``/etc/dnsmasq.conf`` :

.. literalinclude:: ../../linux/alpine_linux/alpine_dnsmasq/dnsmasq.conf
   :language: bash
   :caption: alpine linux配置DNSmasq /etc/dnsmasq.conf

- 启动dnsmasq并且将dnsmasq服务配置成启动时启动:

.. literalinclude:: ../../linux/alpine_linux/alpine_dnsmasq/start_enable_dnsmasq
   :language: bash
   :caption: alpine linux启动dnsmasq摒弃配置DNSmasq系统启动时启动

完成上述部署后，在所有节点都通过 ``host`` 命令接茬DNS解析，确保能够解析集群中所有服务器的IP地址。
