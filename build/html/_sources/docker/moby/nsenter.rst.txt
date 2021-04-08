.. _nsenter:

=====================
nsenter管理namespace
=====================

在深入学习moby架构之前，我想先介绍一个docker环境中常用的管理namespace的工具 ``nsenter`` 。

我们知道Docker使用了Linux的namespace来隔离容器资源，我们在维护Docker的运行实例时，经常需要在物理主机上去检查容器内部。这时候，有一个工具 ``nsenter`` 可以帮助我们进入容器的namespace。

Docker的shell
===============

Docker提供了 ``docker exec`` 指令允许用户进入Docker容器::

   docker exec -it CONTAINER_NAME /bin/bash

nsenter和docker exec不同，nsenter不会进入cgroups，所以也就避免了资源限制。带来的潜在好处就是方便debugging和额外审计，但是对于远程访问， **docker exec是当前推荐的方式** 。

nsenter提供了一种进入现有namespaces的方法，也可以在一个新的namespace中启动一个进程。这样nsenter就可以做很多事情，但最重要但用途是进入Docker容器进行维护操作。

nsenter使用
============

- 首先找出需要进入的容器的PID::

   PID=$(docker inspect --format {{.State.Pid}} <container_name_or_ID>)

- 然后使用以下命令进入容器::

   nsenter --target $PID --mount --uts --ipc --net --pid

.. note::

   在 :ref:`install_docker_macos` 所使用的是Docker Desktop，采用的是macOS系统的HyperKit运行的Linux系统。

上述命令也可以通过一条命令结合起来::

   sudo nsenter -t $(docker inspect --format '{{ .State.Pid  }}' $(docker ps -lq)) -m -u -i -n -p -w

其中 ``$(docker inspect --format '{{ .State.Pid  }}' [container_id])`` 命令可以返回指定容器的PID，这样就能够通过 ``nsenter -t`` 命令进入指定PID的namespace。

``docker ps -lq`` 命令则是返回最新运行的容器的container ID

参考
======

- `Looking to start a shell inside a Docker container? <https://github.com/jpetazzo/nsenter>`_
- `Attach to your Docker containers with ease using nsenter <https://coderwall.com/p/xwbraq/attach-to-your-docker-containers-with-ease-using-nsenter>`_
