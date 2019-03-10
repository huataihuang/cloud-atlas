.. _operator_framework:

===================
Operator框架
===================

`Operator Framework <https://github.com/operator-framework>`_ 是用于管理Kubernetes原生应用（native applications）的开源toolkit，提供了高度伸缩性，自动化的解决方案。

Operator是一种打包、部署和管理Kubernetes应用的方法。Kubernetes应用是部署在Kubernetes中并且使用Kubernetes API和 ``kubectl`` 工具管理的应用。为了使应用程序更为Kubernetes，需要一系列组合的API组合来扩展和管理运行在Kubernetes中的应用。可以将Operator视为在Kubernetes中的管理应用的runtime。

从概念上说，Operator将人的操作知识编码成更易于打包和分享给客户端的软件。也就是Operator是软件工程师团队的一个扩展，用于监控Kubernetes环境，并使用Kubernetes的当前状态来实时决定操作内容。Operator从基本功能到应用程序的特殊逻辑配置都遵循成熟度模型（maturity model）。

参考
===========

- `Introducing the Operator Framework: Building Apps on Kubernetes <https://coreos.com/blog/introducing-operator-framework>`_
- `Introducing Operators: Putting Operational Knowledge into Software <https://coreos.com/blog/introducing-operators.html>`_
- `operator-framework/getting-started <https://github.com/operator-framework/getting-started>`_
