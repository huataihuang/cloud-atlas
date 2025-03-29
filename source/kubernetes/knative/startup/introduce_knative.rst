.. _introduce_knative:

==================
Knative简介
==================

Knative通过扩展 :ref:`kubernetes` 来提供一系列中间件组件，通过这种方式构建了现代化的、源自中心的(source-centric)、基于容器的应用程序。

Knative项目的每个组件都以符合公共模式并且以符合编程最佳实践的方式来共享，而且这些组件都是成功的、基于实践的Kubernetes框架和应用程序。Knative的组件目标是解决乏味但艰巨的任务：

- :ref:`knative_app_deploy`
- :ref:`knative_blue_green_deploy`
- :ref:`knative_config_autoscale`
- :ref:`kubernetes_event_source`

Knative组件
============

Knative包含服务组件和事件组件:

- :ref:`knative_eventing` - 管理和分发事件
- :ref:`knative_serving` - 可以伸缩到0的由请求驱动的计算

受众
======

Knative是针对不同用户设计的：

.. figure:: ../../../_static/kubernetes/knative/startup/knative-audience.svg

- 开发者

Knative组件提供了开发者Kubernates原生API在一个自动伸缩的运行环境中部署serverless风格的函数、应用和容器。

- 操作者

Knative组件被规划成能够集成到大多数成熟产品中，以便云计算服务供应商或者在大企业中的小型团队能够运维它。

- 贡献者

具有清晰的项目领域，轻量级治理模式(lightweight governance model)，以及插件的清晰分离线路，Knative项目建立了一个高效的贡献者工作流。

你可参与Knative贡献者的以下工作：

  - serving
  - eventing
  - documentation

参考
======

- `Knative入门——构建基于 Kubernetes 的现代化Serverless应用 <https://www.servicemesher.com/getting-started-with-knative/>`_
