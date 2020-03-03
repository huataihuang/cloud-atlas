.. _wikipedia_base:

====================
Wikipedia基础架构
====================

.. note::

   Widiamedia基金会构建了一个 `Wikitech网站 <https://wikitech.wikimedia.org>`_ 提供了完整的技术和架构文档，包括生产系统，Wikimedia云计算(基于 :ref:`openstack` )，Toolforge主机环境(PaaS)以及相关技术。这是我们学习世界上最大网站底层技术的最好文档。

Wikipedia是世界上访问量最大的网站之一，作为非盈利组织，Wikipedia提供了一个独特的高性能网站：

* 经费有限(依靠募捐，网站完全没有广告)，每个数据中心只使用不到300台服务器(2008年) - 当前(2020)年数据待查
* 维持了高达99%的高可用率

2008年介绍的架构：

* 200台应用服务器，20台数据库服务器和70台 :ref:`squid` 缓存服务器
* Wikipedia基于MediaWiki软件运行，这是一个开源的PHP平台，后端使用MySQL数据库 - 是的，你不要鄙视PHP，关键是开发者的能力和部署的架构，即使PHP也能支持起世界最大的内容网站
* 结合了 :ref:`squid` , :ref:`memcached` 以及 :ref:`lvs` 负载均衡，并使用数据库主从结构的 :ref:`database_sharding` 技术

参考
========

- `A Look Inside Wikipedia's Infrastructure <https://www.datacenterknowledge.com/archives/2008/06/24/a-look-inside-wikipedias-infrastructure>`_
- `Wikimedia news Category: Technology <https://wikimediafoundation.org/news/category/technology/>`_
- 

