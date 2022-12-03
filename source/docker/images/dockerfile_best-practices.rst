.. _dockerfile_best-practices:

======================
Dockerfiles最佳实践
======================

.. _docker_json_use_double_quotes:

Dockerfile使用JSON，应该用双引号
==================================

.. note::

   这是我犯过的一个乌龙，不起眼，但是确实容易忽略

我在 :ref:`alpine_docker_image` 时构建一个最基本的 ``alpine-base`` 镜像，我本想在 ``Dockerfile`` 最后使用::

   ENTRYPOINT ['/bin/ash']
   
来进入一个简单的交互界面

但是没想到 ``docker run --name alpine alpine-base`` 总是提示错误::

   /bin/sh: [/bin/ash]: not found

奇怪，即使我在 ``Dockerfile`` 中添加了 ``RUN apk add --no-cache busybox`` 也没有找到执行shell 。why?

原因很简单， ``Dockerfil`` 使用 ``JSON`` ，在 ``JSON`` 中单引号是错误的语法，必须使用双引号。

所以，最后 ``Dockerfile`` 应该订正为::

   ENTRYPOINT ["/bin/ash"]

.. _dockerfile_platform:

Dokerfile指定处理器架构
==========================

在 :ref:`kind_multi_node` 采用ARM架构，我通过向 Dockerfile 中指定 ``--platform`` 来构建特定平台镜像。可以规避 ``docker pull`` 多平台镜像时出现错乱。

Docker镜像支持 :ref:`docker_multi-platform_images` ，可以在一个镜像中包含不同架构的变体，甚至可以针对不同操作系统(如Windows)的变体。在运行多平台支持的镜像时，docker会自动选择和操作系统以及体系结构向匹配的镜像。

参考
======

- `Best practices for writing Dockerfiles <https://docs.docker.com/develop/develop-images/dockerfile_best-practices/>`_
- `ENTRYPOINT ['/bin/bash'] not work, but --entrypoint=/bin/bash works #30752 <https://github.com/moby/moby/issues/30752>`_
