.. _intro_bird:

======================
Bird网络路由技术简介
======================

互联网路由是一个非常神秘、然而却无所不在的基础平台。或许我们对随手点击转跳网页以及手机应用App无所不能已经习以为常，很少有人会想到这些数据是如何正确流动的。

对于复杂的三层/四层 TCP/IP路由，已经不是简单的局域网二层网络技术能够支持的，涉及到不同网络的互相发现和数据跨域传递，需要对TCP/IP协议有深入学习和了解。

开源路由软件栈
=================

最早的开源路由协议栈软件是GNU组织开发的 `Zebra <https://www.gnu.org/software/zebra/>`_ 软件(已停止开发)，在Zebra基础上又Fork出了 `Quagga <https://www.quagga.net/>`_ ，目前是学习研究路由协议的主要软件栈。Quagga也被很多公司用于内部研究和再开发(但是很少有对外发布，所以这些公司内部自研并不违反GPL)。 

.. note::

   Zebra和Quagga并没有实现所有的路由协议，但由于实现非常精简且支持主要协议，所以是学习研究的很好软件平台。

BIRD(BIRD Internet Routing Daemon)是比Quagga(Zebra)更为复杂和全面的路由软件堆栈，也是最为主流的路由软件。BIRD完整实现了全功能IP动态路由，并且基于GPL协议，面向主流Linux,FreeBSD以及其他UNIX系统。

由于BIRD实现功能丰富且完备，目前除了商业的Cisco/Junipter占据主要路由网络市场外，BIRD可能是最主要的开源替代，有大量的互联网交换(Internet exchanges)企业使用BIRD来构建核心路由(BIRD可能占据了互联网一半的骨干网络)。

-  London Internet Exchange (LINX), LONAP, DE-CIX 和 MSK-IX 这些互联网骨干交换中心都使用BIND作为路由服务器
- Netflix(流媒体巨头)，Equinix(世界最大数据中心和基础架构服务上)，Amazon(Twitch游戏平台)，甚至思科也将BIRD作为可选解决方案提供给客户
- 2012年Euro-IX调查显示，BIRD是欧洲互联网交换使用最多的路由服务器

在 :ref:`k8s_network` 解决方案中，企业级的 :ref:`calico` 和 :ref:`cilium` 都选择BIRD作为路由解决基础架构。也就是说，如果需要实现超大规模多Kubernetes集群的容器网络路由，BIRD是生产级别的解决方案。

虽然BIRD功能丰富，但是其性能也非常卓越，在性能测试中，不论是小规模网络还是大规模复杂路由，其性能都不弱于 `FRRouting <https://frrouting.org/>`_ (从Quagga项目Fork出来的开源路由软件)。

BIRD特色
============

- 简明的配置文件 ``/etc/bird.conf`` 采用脚本语言配置，语法类似JunOS (Junipter)

参考
=======

- `BGP Open-Source Tools – Quagga vs. BIRD vs. ExaBGP <https://www.bizety.com/2018/09/04/bgp-open-source-tools-quagga-vs-bird-vs-exabgp/>`_ 详细介绍了3个主要的路由软件历史、背景、功能对比以及应用范围，是比较好的选择参考
- `Still true? How true? <https://www.reddit.com/r/ProgrammerHumor/comments/q9u1kf/still_true_how_true/>`_ Reddit上讨论极少人维护支持的关键性开源技术，其中对bird路由软件的评估让人大为惊叹
- `BIRD VS FRRouting <https://www.saashub.com/compare-bird-vs-frrouting>`_ 提供了两种开源路由实现的对比资料索引，可以按图索骥
- `Comparing Open Source BGP Stacks <https://elegantnetwork.github.io/posts/comparing-open-source-bgp-stacks/>`_ 对开源BGP软件的性能对比
