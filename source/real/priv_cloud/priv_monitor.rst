.. _priv_monitor:

====================
私有云监控
====================

虽然是在一台二手服务器上通过 :ref:`kvm` 虚拟化出云计算集群，但是随着服务器增多和架构部署的复杂化，我渐渐发现，没有一个完善的监控，是很难排查出系统问题和及时发现故障的:

- :ref:`ntp` 异常会导致分布式集群出现很多意想不到的错误，例如 :ref:`squid_ssh_proxy` 遇到 ``kex_exchange_identification: Connection closed`` 异常
- :ref:`dns` 异常会导致服务调用失败

物理主机监控
==============

采用 :ref:`prometheus` 能够对 :ref:`kubernetes` 集群进行监控，也能够通过 :ref:`ipmi_exporter` 采集物理主机的温度、主频等基础数据，所以在物理主机中:

- 物理主机独立部署 :ref:`prometheus` 和 :ref:`ipmi_exporter` (采用 :ref:`systemd` 运行)，这样可以持续采集监控数据
- 物理主机上部署一个独立 :ref:`grafana` 来汇总基础运行监控，例如底层的 :ref:`ceph` :ref:`gluster` :ref:`zfs` 等监控数据
- 通过 :ref:`prometheus-webhook-dingtalk` 发送钉钉消息，也通过 微信 来发送通知，此外还可以尝试自己接入一个短信、语音网关来实现通知

另外一个轻量级的主机监控是 :ref:`cockpit` ，发行版已经提供了集成，并且可以快速激活，也可以尝试实现上述 :ref:`prometheus` 的监控服务，同时提供对服务器的配置管理:

- 通过激活 :ref:`cockpit-pcp` 可以监控 :ref:`metrics` 实现服务器的温度监控

.. note::

   上述两种方案我都准备实现， :ref:`prometheus` 侧重监控和告警， :ref:`cockpit` 侧重服务器配置管理兼监控
