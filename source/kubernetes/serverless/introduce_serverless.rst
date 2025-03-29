.. _introduce_serverless:

==================
Serverless概述
==================

Serverless 表示利用 Serverless 形态的产品实现的应用架构，这种架构完全依托于云厂商或云平台提供产品完成系统的组织及构建。在这种架构中，用户无需关注支撑应用服务运行的主机，而将关注点投入在系统架构，业务开发， 业务支撑运维上。

.. note::

   用户需要都是云计算都计算能力以支持业务平稳可伸缩运行，屏蔽掉底层技术细节和难点，使得用户无需浪费精力在基础架构上，这是云计算的目标。

Serverless是BaaS和FaaS的结合： Serverless = FaaS + BaaS

- BaaS (Backend as a Service，后端即服务) - 后端云服务，比如云数据库、对象存储、消息队列等。利用 BaaS，可以极大简化我们的应用开发难度。
- FaaS (Function as a Service，函数即服务) - 运行函数的平台，比如阿里云的函数计算、AWS 的 Lambda 等。

Serverless 则可以理解为运行在 FaaS 中的，使用了 BaaS 的函数。

:ref:`knative` 是Google在2018年Google Cloud Next大会上发布的基于Kubernetes的Serverless框架。Knative通过整合容器构建(或者函数)、工作负载管理(动态扩展)以及事件模型这三者来实现Serverless标准。Knative 社区的主要贡献者有 Google、Pivotal、IBM、Red Hat，并且得到CloudFoundry、OpenShift 这些 PAAS 提供商支持。

.. note::

   独立章节 :ref:`knative` 实践这项技术方案。

在Knative之前，社区已经有很多Serverless解决方案：

- :ref:`kubeless`
- :ref:`fission`
- ...

各大云厂商也都有各自的 FAAS 产品的实现:

- AWS Lambda
- Google Cloud Functions
- Microsoft Azure Functions
- 阿里云的函数计算

参考
=======

- `Serverless 系列（一）：基本概念入门 <https://www.infoq.cn/article/s101GtcCV05_2AgKo8GD>`_
- `Serverless 掀起新的前端技术变革 <https://zhuanlan.zhihu.com/p/65914436>`_
- `初识 Knative: 跨平台的 Serverless 编排框架 <初识 Knative: 跨平台的 Serverless 编排框架>`_
