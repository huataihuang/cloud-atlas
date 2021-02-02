.. _docker_django:

========================
Docker环境运行Django
========================

.. note::

   和 :ref:`docker_compose_django` 不同，本文采用docker构建tini富容器，运行一个完整 nginx + django + mysql 的开发环境。

   后续再拆分这个富容器，采用 kubernetes 的pod 来运行这个组合。

   DigitalOcean文档 `From Containers to Kubernetes with Django <https://www.digitalocean.com/community/tutorial_series/from-containers-to-kubernetes-with-django>`_ 系列提供了一个很好的拆分案例。
