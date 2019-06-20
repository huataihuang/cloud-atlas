.. _operator:

==================================
Operator - Kubernetes应用打包部署
==================================

Operator概念
================

- Operator是Kubernetes应用程序

`Operator Framework <https://github.com/operator-framework>`_ 是用于管理Kubernetes原生应用（native applications）的开源toolkit，提供了高度伸缩性，自动化的解决方案。

Operator是一种打包、部署和管理Kubernetes应用的方法。Kubernetes应用是部署在Kubernetes中并且使用Kubernetes API和 ``kubectl`` 工具管理的应用。为了使应用程序更为Kubernetes，需要一系列组合的API组合来扩展和管理运行在Kubernetes中的应用。可以将Operator视为在Kubernetes中的管理应用的runtime。

从概念上说，Operator将人的操作知识编码成更易于打包和分享给客户端的软件。也就是Operator是软件工程师团队的一个扩展，用于监控Kubernetes环境，并使用Kubernetes的当前状态来实时决定操作内容。Operator从基本功能到应用程序的特殊逻辑配置都遵循成熟度模型（maturity model）。高级的Operator被设计成无感知地处理升级系统，自动处理故障，而不是偷工减料，例如跳过软件备份处理来节约时间。

Operator框架提供了一个软件开发工具包SDK，通过使用生命管理周期机制来管理应用的安装和升级，这就赋予观柳岸使用Operator来管理任何Kubernetes集群。

Operator Framework
=====================

Operator Framework是一个提供给开发人员的开源项目，提供了运行Kubernetes工具，你可以使用Operator来加快Kubernetes部署。这个Operator框架包括：

- Operator SDK: 开发人员可以用SDK来根据他们自己的经验来构建Operator，而且不需要了解Kubernetes API的细节
- Operator Lifecycle Management: Operator生命周期管理包括了安装、升级和管理所有Operators（以及它们相应的服务）的生命周期，以便在Kubernetes集群上运行Operator。
- Operator Metering: 用于报考提供特定服务的Operators

Operator SDK
--------------

Operator SDK提供了用于构建、测试和打包Operators的工具。起初，SDK采用Kubernetes API加速了一个应用程序的业务逻辑（例如，如何伸缩，更新或者备份）来执行这些操作。随着时间推移，SDK开始让工程师能够使得应用程序更为灵活，云计算服务体验更佳。

.. figure:: ../../../_static/kubernetes/operator-framework-1.png
   :scale: 75

Operator Lifecycle Manager
----------------------------

一旦构建成功，Operator就需要部署到Kubernetes集群。Operator Lifecycle Manager是Kubernetes集群负责管理Operators的后台。使用Operator生命周期管理器，系统管理员可以控制Operators在哪个namespace中使用，谁能够操作运行Operators。并且能够管理Operators的整个生命期以及可用资源，例如触发Operator和它的资源的升级，或者授权一个团队能够操作集群的某个有权限的分片。

.. figure:: ../../../_static/kubernetes/operator-framework-2.png
   :scale: 75

简单来说，无状态应用程序可以通过使用一个通用Operator（例如 `Helm Operator <https://github.com/operator-framework/helm-app-operator-kit>`_ ）来使用Operator Framework中的生命周期管理功能而不需要写任何代码。不过，复杂的状态相关应用程序才是Operator的用武之地。一个云能力可以编码到Operator中来提供一个高级用户功能，例如自动升级、备份和伸缩。

Operator Metering
----------------------

未来版本，Operator Framework将包含度量应用程序使用率的能力 - 首先是Kubernetes，提供扩展给集中的IT团队用于预算，以及给软件供应商提供商业软件。Operator Metering被设计成处理集群的CPU和内存报告，就好像用于计算IaaS的城北以及类似license的计算。

.. note::

   Google有一个 `Kubebuilder <https://github.com/kubernetes-sigs/kubebuilder>`_ 项目提供了使用 `自定义资源(custom resource definitions, CRDs) <https://kubernetes.io/docs/tasks/access-kubernetes-api/extend-api-custom-resource-definitions>`_ 来构建Kubernetes API的开发框架。

参考
===========

- `Introducing the Operator Framework: Building Apps on Kubernetes <https://coreos.com/blog/introducing-operator-framework>`_
- `Introducing Operators: Putting Operational Knowledge into Software <https://coreos.com/blog/introducing-operators.html>`_
- `operator-framework/getting-started <https://github.com/operator-framework/getting-started>`_
