.. _openstack_architecture:

======================
OpenStack 架构
======================

OpenStack服务关系
===================

- OpenStack软件架构关系图

.. figure:: ../_static/openstack/openstack_kilo_conceptual_arch.png
    :scale: 60

OpenStack逻辑架构
===================

要设计、部署和配置OpenStack，系统管理员必须懂得逻辑架构。

OpenStack包含了一系列独立组件，称为OpenStack服务。所有服务的认证通过一个公共的标识服务。独立的服务相互间通过公开的API交互，除非需要特定系统管理员命令。

OpenStack内部服务由一系列进程构成。所有的服务至少有一个API进程，监听API请求，处理请求并传递给其他配合的服务。通过标识服务，实际工作是有彼此独立的进程处理。

为了在服务的进程间通讯，需要使用一个AMQP消息队列。而服务的状态保存在数据库。当部署和配置OpenStack云计算，你需要选择部署消息队列和数据库解决方案，例如，RabbitMQ, MySQL, MiriaDB, 和 SQLite 。

用户可以通过Web用户界面(Horizon Dashboard)访问OpenStack，也可以通过命令行客户端，以及通过浏览器插件或 ``curl`` 来访问API请求。对于应用程序，提供了一系列SDK。所有这些访问方式都是通过REST API调用来访问OpenStack服务。

- OpenStack逻辑架构图:

.. figure:: ../_static/openstack/openstack-arch-kilo-logical-v1.png
    :scale: 30
