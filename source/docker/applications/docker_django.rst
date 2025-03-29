.. _docker_django:

========================
Docker环境运行Django
========================

.. note::

   和 :ref:`docker_compose_django` 不同，本文采用docker构建tini富容器，运行一个完整 nginx + django + mysql 的开发环境。

   后续再拆分这个富容器，采用 kubernetes 的pod 来运行这个组合。

   DigitalOcean文档 `From Containers to Kubernetes with Django <https://www.digitalocean.com/community/tutorial_series/from-containers-to-kubernetes-with-django>`_ 系列提供了一个很好的拆分案例。

Tini
=======

在这个完整的Django运行环境是基于 :ref:`docker_tini` 来运行的，也就是以 tini 为进程管理器，在Docker容器中启动多个服务：

- ssh: 提供基础的运维操作
- cron: 提供定时任务执行
- django: 应用运行程序
- nginx: 提供前端web访问，并代理django
