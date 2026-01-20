.. _freebsd_firewall:

============================
FreeBSD防火墙
============================

防火墙是用于过滤系统进出流量，设置影响网络数据包整形系列规则以及是否允许通过的系统。防火墙规则会影响一个或多个数据包特性，例如网络协议，源或目标地址以及源或目标端口。

通常防火墙会增强一个主机或网络的安全，用于如下场景:

- 保护和隔离应用，服务和主机避免公共internet不希望的流量
- 限制internet访问或禁止访问内部网路追究
- 实现网络地址转换( :ref:`freebsd_nat` )，允许内部网路使用私有地址，并共享外部internet的地址或一个自动分配公共地址的地址池

FreeBSD在base系统中内置了3种防火墙: ``PF`` , ``IPFW`` 和 ``IPFILTER`` (IPF)，并提供两种控制带宽使用的流量整形工具: ``altq`` (通常结合PF) 和 ``dummynet`` (通常结合IPFW)。

:ref:`freebsd_pf` 是目前最主要的防火墙模块，并且在FreeBSD 15及后续发行版中，PF正在成为事实上的通用标准和开发中心:

- 最初源自OpenBSD，后被移植到FreeBSD并深度重构以支持多核(SMP)
- 采用 **声明式(Declarative)** 配置，逻辑清晰易于阅读和维护
- **默认"最后匹配胜出"** (可使用 ``quick`` 关键字改变)
- 及其强大的状态跟踪能力，NAT转换和状态标处理非常优雅
- 在二层过滤(以太网Layer 2)上较弱，传统上不擅长MAC地址过滤，所以会采用 IPFW 补充
- 流量整形使用 ``altq`` ，但没有像 IPFW 那样高度集成 ``dummynet``

在FreeBSD 15开始，由Netgate等机构赞助，FreeBSD的PF版本正在和OpenBSD对齐和缩短差距。FreeBSD版本的PF针对多核并行化深度优化，在高带宽、多核的服务器环境表现优于原始的OpenBSD版本。并且由于 :ref:`pfsense` 、 :ref:`opnsense` 以及Apple 的 :ref:`macos` / :ref:`ios` 全部采用了PF，其生态系统和人才储备远超IPFW。

不过，IPFW在需要 **超高性能流量整形** (dummynet)、二层MAC过滤以及复杂的负载均衡(如配合 ``ng_ipfw`` 使用Netgraph)等电信级场景中依然是首选。目前IPFW出于"稳定维护"状态，非常可靠，但新增的现代化特性(如比较直观的语法规则)较少。

参考
=====

- `FreeBSD Handbook: Chapter 33. Firewalls <https://docs.freebsd.org/en/books/handbook/firewalls/>`_
