.. _kubernetes_serverless:

===============================
Kubernetes Severless
===============================

Serverless 表示利用 Serverless 形态的产品实现的应用架构，这种架构完全依托于云厂商或云平台提供产品完成系统的组织及构建。在这种架构中，用户无需关注支撑应用服务运行的主机，而将关注点投入在系统架构，业务开发，业务支撑运维上。

- BaaS: 后端即服务 - 包含第三方云托管应用程序和服务的应用程序，以管理服务器端逻辑和状态。
- FaaS: 函数即服务 - 在无状态计算容器中运行，这些容器是事件触发的，短暂的（可能只持续一次调用），并且完全由第三方提供。

.. note::

   参考:

   - `Serverless 系列（一）：基本概念入门 <https://www.infoq.cn/article/s101GtcCV05_2AgKo8GD>`_
   

.. toctree::
   :maxdepth: 2

   introduce_serverless.rst
   faas/index
   baas/index
