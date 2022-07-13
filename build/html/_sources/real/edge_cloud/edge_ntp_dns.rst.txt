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
