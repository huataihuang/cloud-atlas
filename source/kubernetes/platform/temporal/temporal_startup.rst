.. _temporal_startup:

==================
Temporal快速起步
==================

设置开发环境
================

Go开发
---------

- 在本地安装 :ref:`go_on_arch_linux` 或 :ref:`go_on_fedora`

TypeScript开发
---------------

- 在本地安装 :ref:`nodejs_dev_env`

- 可以使用Temporal SDK创建一个新项目::

   npx @temporalio/create@latest ./my-app

也可以使用以下命令在现有项目中加入Temporal TypeScript SDK::

   npm install @temporalio/client @temporalio/worker @temporalio/workflow @temporalio/activity

.. note::

   目前专注于Go开发Temproal，后续再尝试TypeScript

设置一个Temporal开发集群
------------------------

Temporal官方采用 :ref:`docker` 和 :ref:`docker_compose` ，请按照发行版进行安装

- clone出 `temporalio/docker-compose <https://github.com/temporalio/docker-compose>`_ 仓库，然后运行 ``docker-compose`` 启动环境::

   git clone https://github.com/temporalio/docker-compose.git
   cd  docker-compose
   docker-compose up

当 Temporal 集群运行后，在浏览器中访问 localhost:8080

参考
=======

- `Get started with Temporal <https://learn.temporal.io/getting_started>`_
