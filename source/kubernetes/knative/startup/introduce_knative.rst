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

参考
======

- `Knative入门——构建基于 Kubernetes 的现代化Serverless应用 <https://www.servicemesher.com/getting-started-with-knative/>`_
