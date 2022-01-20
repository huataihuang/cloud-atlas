.. priv_monitor:

====================
私有云监控
====================

虽然是在一台二手服务器上通过 :ref:`kvm` 虚拟化出云计算集群，但是随着服务器增多和架构部署的复杂化，我渐渐发现，没有一个完善的监控，是很难排查出系统问题和及时发现故障的:

- :ref:`ntp` 异常会导致分布式集群出现很多意想不到的错误，例如 :ref:`squid_ssh_proxy` 遇到 ``kex_exchange_identification: Connection closed`` 异常
- :ref:`dns` 异常会导致服务调用失败
