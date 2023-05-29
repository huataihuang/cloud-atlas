.. _intro_coredns:

=================
CoreDNS简介
=================

CoreDNS是一个通常用于支持在容器运行环境，特别是Kubernetes管理的容器环境中，提供服务发现功能。最早是由Miek Gieben于2016年开发的最初版本，最初称为 SkyDNS。当时使用了一个名为Go DNS的非常流程的在 :ref:`golang` 中提供DNS功能的库。接着，SkyDNS被CoreDNS所取代成为更流行的服务发现。由于开发者Miek非常欣赏一个Go基础web服务器Caddy，所以他fork出Caddy来创建CoreDNS。这样CoreDNS就继承了Caddy的主要有点: 简单的配置语法，强大的插件架构，以及基于Go开发。

CoreDNS使用了 :ref:`bind` 配置语法的配置文件，命名为 ``Corefile`` 。这是一个非常简单的配置。

CoreDNS通过插件功能提供DNS功能:

- 缓存(cache)插件
- 转发(forward)插件
- 读取zone数据的插件
- 配置第二个DNS的插件

这种插件结构的好处时，如果你不需要某个插件功能，你可以不用配置该插件，这样CoreDNS也不会执行这个插件，这就使得CoreDNS运行更快也更安全。CoreDNS插件的开发也较为简便。

在容器化的Kubernetes环境，CoreDNS是核心组件，提供了服务发现能力，确保容器间通讯正常。

CoreDNS的限制
===============

CoreDNS目前还不是完整功能的DNS服务器:

- CoreDNS不支持完全递归，也就是不能从DNS名字空间的根开始查询: 常规的DNS服务器，例如 :ref:`bind` 支持递归查询，也就是从根DNS开始一级一级，直到找到权威DNS服务器获得查询结果

  - 实际上，CoreDNS依赖其他DNS服务器，也就是所谓的转发 ``forwarder``

.. csv-table:: CoreDNS和Bind关键功能对比
   :file: intro_coredns/coredns_bind.csv
   :widths: 60,20,20
   :header-rows: 1

CoreDNS, Kubernetes 和 CNCF
==============================

Kubernetes是2015年由Google开发并捐赠给Google和Linux基金会共同组建的开元组织云原生计算基金会(Cloud Native Computing Foundation, CNCF)。

2017年CoreDNS被提交给CNCF并且在2019年1月孵化毕业。

从Kubernetes 1.13(2018年12月发布)，CoreDNS就成为了Kubernetes的默认DNS。也就是说，现在CoreDNS已经默认安装在几乎所有Kubernetes集群。

参考
======

- ``OReilly Learning CoreDNS``
