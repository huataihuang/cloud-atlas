.. _introduce_terraform:

=========================
Terraform简介
=========================

Terraform是一个用于构建、修改和版本控制的基础架构。

配置文件描述Terraform组件需要运行一个单一程序或者整个数据中心。Terraform生成一个执行计划来描述如何达到指定状态，然后执行这个计划构建所描述的架构。当配置文件修改，Terraform能够检测到配置修改并创建增量执行计划来完成。

Terraform能够管理的架构包括底层组件，例如计算实例，存储和网络，以及高层组件，如DNS对象，SaaS功能等等。

.. note::

   参考资料

   - YouTube上有Terraform的开发公司 `HashiCorp的订阅频道 <https://www.youtube.com/channel/UC-AdvAxaagE9W2f0webyNUQ>`_ 提供了很多视频参考资料。
     - 《Terraform: Up & Running》作者Yevgeniy Brikman的演讲 `How to Build Reusable, Composable, Battle tested Terraform Modules <https://www.youtube.com/watch?v=LVgP63BkhKQ&pbjreload=10>`_
   - 阿里云提供了Terraform的provider，继承了Terraform的很多resource和datasource，并且提供了Terraform学习案例 `玩转阿里云Terraform <https://yq.aliyun.com/articles/713099>`_ :
     - `Terraform 是什么 <https://yq.aliyun.com/articles/713099>`_
     - `Terraform 的几个关键概念 <https://yq.aliyun.com/articles/721188>`_
     - `Terraform 的安装和加速 <https://yq.aliyun.com/articles/726467>`_
     - `Terraform 常用命令详解 <https://yq.aliyun.com/articles/727057>`_

架构即代码
=============

Infrastructure as Code(架构即代码)是指，架构通过高层次配置语法进行描述。这样可以使得数据中心的蓝图能够版本化并且就好象代码一样。此外，这样也可以使得架构能够分享和重用。

执行计划
----------

Terraform使用一个"planning"步骤来生成一个执行计划。这个执行计划显示了当你apply的时候Terraform将做什么。

资源图形
-----------

Terraform构建了你所有资源的一个图形，并且并发创建和修改任何没有依赖的资源。正因为这样，Terraform构建架构的效率尽可能高，并且操作者可以深入他们架构的依赖关系。

变更自动化
------------

复杂的变更集合可以以最小的人工干预在基础架构上实施。通过执行计划和资源图形，你可以精确了解Terraform将要修改的内容以及顺序，避免很多人为错误。

Terraform适用场景
===================

.. note::

   官方文档描述的多个场景我现在没有经验，我需要更多实践来验证，目前仅记录我理解和能够实施的场景。

多层次应用程序
-----------------

Terraform特别适合部署N-层次应用程序，例如WEB服务+数据库，以及更为复杂的API服务器，缓存服务器，路由mesh等等。Terraform是一个理想的构建和管理这些架构的工具，每个层次都被描述为一组资源集合，以及描述每个层次之间依赖并自动处理。Terraform会确保数据库层次在WEB服务器启动之前就绪，并且负载均衡对WEB节点可用。每个层次都是容易伸缩的，Terraform通过修改一个简单的 ``count`` 配置值来实现。

软件定义网络(SDN)
-------------------

Terraform可以通过编码配置方式来定义软件定义网络，这个配置通过Terraform自动设置和修改控制曾的接口。例如各种运计算服务商的基础网络设施，例如AWS VPC。

资源调度
----------

在大型伸缩架构中，静态分配应用程序到主机上运行是极大的困难，这就产生了大量的调度器，例如Borg，Mesos，YARN和 Kubernetes。这些调度器用于动态调度Docker容器，Hadoop，Spark以及其他软件。

Terraform不限于AWS，而是将资源调度器是为provider，这样Terraform就能够设置运行这些调度器微微调度器网格。

多云部署
--------------

Terraform提供了多个云计算部署的抽象，这样可以使用单一配置来实现管理多个provider，甚至跨云部署。

参考
==========

- `Terraform官方文档 - Introduction to Terraform <https://www.terraform.io/intro/index.html>`_
- `Webinar: Controlling Your Organization With HashiCorp Terraform and Google Cloud Platform <https://www.youtube.com/watch?v=Ym6DtUx5REg>`_
- `Webinar: Multi-Cloud, One Command with Terraform <https://youtu.be/nLg7fpVcIv4>`_
