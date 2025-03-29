.. _grafeas:

=======================
Grafeas元数据安全审计
=======================

软件供应链管理
=================

在Google内部运行了大量的容器，每周需要部署超过20亿次容器(2019年5月数据， `Software Supply Chain with Grafeas and Kritis <https://www.infoq.com/presentations/supply-grafeas-kritis/>`_ ，我理解是每天需要创建3亿次容器) ，所以Google有巨大的压力需要了解容器内究竟发生了什么，部署了什么代码，哪些代码是自己开发的。

.. note::

   任何一个巨型软件公司都使用了大量的开源、商用以及自研软件，就好比组装iPhone是由全世界不同供应商提供的零部件，你需要完整跟踪整个供应链，以确保质量和安全性。

   你可以将Grafeas+Kritis视为一个巨大的软件指纹库，来验证部署的源代码、软件状态、测试和安全记录。在InfoQ有一篇翻译介绍文章 `使用“Grafeas”元数据 API 和“Kritis”部署授权管理软件供应链 <https://www.infoq.cn/article/2018/05/grafeas-kritis-security>`_

当你编写了代码，构建了镜像以及容器，并且测试和验证了二进制代码，然后通过QA测试最终部署到生产环境。这个过程由持续集成CI pipelines自动完成。你依然需要检查你的发布包中所包含的第三方依赖，因为你只控制了自己编写的程序代码部分，如果没有第三方依赖的功能、安全检查，你依然无法信任自己发布的软件包是安全可靠的。

由于容器化部署带来的交付二进制包(包括Docker镜像)呈指数级增长，进一步扩大了上述安全隐患 - 你很难判断容器镜像内包含的多种语言的二进制包的质量信息以及安全漏洞信息。

Google开发了Grafeas和Kritis，通过开放的metadata(元数据)标准，定义如何构建元数据和测试元数据，并且作为一个中心化的元数据知识库，包含了你的最终产品所使用的变量以及编译信息。可以通过配置策略控制和查看修改，然后通过Kritis(管理控制器)部署到Kubernetes中，就可以运行集群管理定义，在某些pod加载是检查镜像中 的服务漏洞以及镜像来源，如果不符合管理定义策略，就会拒绝加载pod。

.. note::

   Grafeas是中心化元数据存储中心；Kritis是运行在Kubernetes集群中的管理控制器。Kritis是通过Grafeas提供的API来读取元数据信息，然后对容器进行策略检查

通用的元数据需要集中的“Source of Truth”，需要覆盖软件交付的整个生命周期，能够兼容公有/私有云环境，能够实现扩展性和可插拔性。

Grafeas是作为一个容器注册漏洞扫描，而Kritis则作为二进制授权，在Google已经作为生产使用。在扫描容器时，会检查容器是否存在漏洞，例如CVE。通过不同的CVD的开放数据库，可以检测到容器是否包含公开的安全漏洞。

此外，后台的定时任务会周期性对运行的pod进行基本检查以确定pod是否存在安全漏洞。

Kritis的使用是验证型admission webhook，这是在接收到admission请求以后的HTTP回调，就能够根据定制的admission策略来决定我们是否接受或者拒绝这个请求。

Grafeas 起源于容器的安全性质量控制，但从定义来看它并不局限于容器。它是提供统一方式来审计，监控软件组件的开源工件元数据 API。 这里的'Software'可以是 Docker 镜像，也可以是 War，Jar 和 Zip 包，'Supply Chain' 指的是构建这些发布包所包含的组件。

在软件交付的每一步，都会通过 Grafeas API 将每个阶段的关键元数据进行收集。漏洞扫描的工具会将各种类型的第三方依赖包进行扫描，并且将扫描结果通过 Grafeas API 和发布的 Docker 镜像做关联，这样的好处是在部署镜像到 Kubernetes 集群之前，能够知道这个镜像是符合公司的安全策略的。

Grafeas概念
============

Grafeas将元数据信息分为 ``notes`` 和 ``occurrences`` :

- notes 是描述元数据的抽象
- occurences 是notes的执行实体(instantiations)，描述了当一个给定的note赋予资源时应该发生什么。

以上区分是的第三方元数据提供方能够创建和管理各自不同客户的元数据，并允许精细定义元数据的访问控制。

Notes
---------

notes描述了元数据的上层描述。举例，你可以在分析了一个Linux软件包之后创建一个有关特定安全漏洞的note。你可以使用这个note来存储有关一个编译进程的编译器信息。note通常由执行这个分析的provider来拥有和创建。可以通过分析以及跨不同项目发生多次来生成notes。

note的名字必须按照格式 ``/projects/<project_id>/notes/<notes_id>`` 。这里note ID是对每个项目唯一，并且尽可能提供信息。例如，漏洞note对名字可以是 ``CVE-2013-4869`` 以引用它所描述对CVE。

通常应该将note和occurrences存储到各自独立对项目，这样可以使用精细控制的访问权限来管理。

note只能由note的owner编辑，并且只对具有访问引用occurrences的用户只读。

Occurrences(存在)
-------------------

occurrence是note的执行实体(实例/instantiation)。occurrences描述了给定note的特定对象。例如，有关一个漏洞的note的occurrence将会描述在哪个软件包中发现漏洞，指定补救步骤(remediation steps)。或者，一个有关编译详情的note的occurrence会描述一个编译的生成的容器镜像。

开源元数据API和审计平台Grafeas
================================

`开源元数据API和审计平台Grafeas <https://grafeas.io>`_ 可以审计完整的软件供应链。提供了API用于管理软件资源的元数据，例如容器镜像、虚拟机镜像、JAR文件和脚本。

.. figure:: ../../_static/kubernetes/security/grafeas_architecture.png
   :scale: 75

参考
========

- `Grafeas-来自谷歌，IBM, 红帽和 JFrog 的元数据标准 <https://blog.csdn.net/wangqingjiewa/article/details/78594054>`_
- `Software Supply Chain with Grafeas and Kritis <https://www.infoq.com/presentations/supply-grafeas-kritis/>`_
- `Grafeas Concepts <https://github.com/grafeas/grafeas/blob/master/docs/grafeas_concepts.md>`_
