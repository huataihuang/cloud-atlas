.. _openstack_env_mq:

============================
OpenStack环境消息队列
============================

OpenStack使用消息队列在服务之间协调操作以及同步状态信息。消息队列通常运行在控制节点。OpenStack支持多种消息队列，包括 RabbitMQ, Qpid 和 ZeroMQ。消息队列可以运行在控制节点。

安装和配置MQ组件
=================

- 安装软件包::

   yum install rabbitmq-server

- 启动消息队列服务::

   systemctl enable rabbitmq-server.service
   systemctl start rabbitmq-server.service

- 添加 ``openstack`` 用户::

   rabbitmqctl add_user openstack RABBIT_PASS

- 配置允许 ``openstack`` 用户读写权限::

   rabbitmqctl set_permissions openstack ".* " ".*" ".*"
