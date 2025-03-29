.. _introduce_terraform:

=========================
Terraform简介
=========================

.. note::

   为什么我们需要Terraform？

   原因就是各个云计算厂商的SDK过于复杂和千差万别，导致编写简单的操作过程也需要重复投入资源。Terraform就是云计算基础设施的配置管理工具，通过标准配置提供虚拟机和虚拟网络、虚拟存储等底层基础设施，并编排组成最基础的物理架构。

   你可以把Terraform想象成操作(虚拟)硬件设备的Ansible/Chef这样的配置管理工具，只不过比传统的配置管理工具(需要先有VM服务器)更低一层，提供的是基础设备的配置管理。

   之后，Ansible/Puppet就可以登场，在Terraform构建的底层系统上部署软件应用。或者，也可以使用给予镜像容器的Kubernetes来构IaaS。

长期以来，数据中心部署是由系统管理员负责，从零开始，一步步手工安装每个服务器，每个数据库，每个负载均衡，以及手工配置网络。这是一个非常黑暗而痛苦的过程：宕机、错误配置以及缓慢而重复的安装配置。

:ref:`devops` 的兴起，极大程度减轻了系统管理员的工作负担，可以采用申明式语言描述来实现自动化部署，无需每个系统管理员低效地编写"匆忙而未经充分测试"的脚本。随着云计算的兴起，有带来的新的挑战：每个云计算厂商提供的API以及资源都存在不兼容情况，就如同早期系统工程师需要面对不同厂商的数据库、网络设备和操作系统。

Terraform则应运而生，提供了不同云厂商的统一抽象，实现了将IaaS视为简单的、精心定义的语言程序，实现在不同云厂商统一的管理架构。不论你使用的是AWS，Azure，Google Cloud，阿里云，以及私有云计算平台(例如，OpenStack，VMware)，都能使用很少的命令完成复杂的部署。

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

DevOps实现方式
===============

配置管理工具(Configuration Management Tools)
----------------------------------------------

Chef, Puppet, Ansible, SaltStac等配置管理工具设计成对现有服务器进行安装和管理软件以及配置文件来实现DevOps：

- 代码转换成一致性，可预测结构：清晰的结构和命名参数
- 结合脚本实现
- 分布式分发执行

服务器模板工具(Server Templating Tools)
-----------------------------------------

服务器模板工具类似 Docker, Packer 和 Vargant。和配置管理工具不同，配置管理工具是在服务器上运行相同代码，而服务器模板工具则采用完全自包含的快照，所有软件，文件和相关配置都在一个镜像中。

.. figure:: ../../_static/devops/terraform/vm_container.png
   :scale: 50

   两种不同类型的镜像：虚拟机(VM)和容器(Container)

服务器供给工具(Server Provisioning Tools)
-------------------------------------------

虽然配置管理工具和服务器模板工具都定义了在每个服务器上运行的代码，但是服务器供给工具(Server Provisioning Tools)，例如Terraform, CloudFormation, OpenStack Heat提供了另一种DevOps模式：可以创建服务器，数据库，缓存，负载均衡，消息队列，监控，网络配置，SSL证书，几乎是所有的基础架构。

.. figure:: ../../_static/devops/terraform/server_provision_tool.png
   :scale: 50

Terraform案例代码::

   resoure "aws_instance" "app" {
     instance_type = "t2.micro"
     availability_zone = "us-east-1a"
     ami = "ami-40d8157"
   
     user_data = <<-EOF
                 #!/bin/bash
                 sudo service apache2 start
                 EOF
   }


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

Terraform工作原理
==================

通过Terraform部署架构：

- 使用不同provider的API，包装抽象成Terraform的标准代码结构
- 用户不需要了解每个云计算厂商的API细节，降低了部署难度

参考
==========

- `Terraform官方文档 - Introduction to Terraform <https://www.terraform.io/intro/index.html>`_
- `Webinar: Controlling Your Organization With HashiCorp Terraform and Google Cloud Platform <https://www.youtube.com/watch?v=Ym6DtUx5REg>`_
- `Webinar: Multi-Cloud, One Command with Terraform <https://youtu.be/nLg7fpVcIv4>`_
