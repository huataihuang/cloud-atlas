.. _docker_expose_publish_port:

======================================
Docker的expose和publish端口差异和关系
======================================

Dockerfile中的EXPOSE指令
=========================

在配置 :ref:`dockerfile` 时候，你会注意到Dockerfile中往往会有一行配置了容器 ``EXPOSE`` 端口的配置，例如:

.. literalinclude:: ../../linux/alpine_linux/alpine_dev/alpine-node
   :language: dockerfile
   :caption: alpine构建运行node的容器Dockerfile
   :emphasize-lines: 10

这里我的案例是 :ref:`alpine_dev` 时一个运行 :ref:`nodejs` 的容器，采用Node.js官方指导文档 `How do I start with Node.js after I installed it? <https://nodejs.org/en/docs/guides/getting-started-guide/>`_ 中的Hello World代码 ``app.js`` :

 .. literalinclude:: ../../linux/alpine_linux/alpine_dev/app-localhost.js
    :language: javascript
    :caption: nodejs Hello World (绑定127.0.0.1)
    :emphasize-lines: 4

你看，多么完美匹配: Dockerfile 中的 ``EXPOSE 3000`` 对应 js 中指令 ``const port = 3000;`` ，那么我们执行以下 ``docker run`` 命令，就能在网络中访问容器中这个服务了么::

   docker build -t alpine-node .
   docker run -itd alpine-node:latest

并不是如此，此时检查::

   docker ps

可以看到::

   CONTAINER ID   IMAGE               COMMAND        CREATED             STATUS             PORTS     NAMES
   588f22fe8980   alpine-node:latest  "node app.js"  About a minute ago  Up About a minute  3000/tcp  recursing_newton

这里端口显示 ``3000/tcp`` 是表示容器内部的端口 ``3000`` ，但是，为何docker没有在 ``host`` 主机上把这个容器内部的 ``3000`` 端口透出? 现在在物理主机上执行::

   netstat -an | grep 3000

可以看到完全是空的，也就是在外部无法访问容器内部端口

EXPOSE和PUBLISH
=================

在Docker的概念中， ``EXPOSE`` 和 ``PUBLISH`` 是两个不同但是又有关联的概念:

- ``EXPOSE`` 端口只是在 :ref:`dockerfile` 的 ``metadata`` 中定义了暴露端口
- ``必须`` 在容器启动时候 ``PUBLISH`` (发布) 端口才能使得外部能够访问容器内部的服务端口

也就是说， ``exposing`` 端口不能立即生效，这个状态只是容器内部的应用服务器监听端口，并没有 ``binding`` (绑定) 到物理主机的网络接口上。

:ref:`dockerfile` 中列出 ``EXPOSE`` 端口可以帮助用户在启动容器时候配置正确的端口转发规则，特别是使用非标准端口。

- 使用以下命令可以查看运行容器定义的 ``EXPOSE`` 端口::

   docker ps --format="table {{.ID}}\t{{.Image}}\t{{.Ports}}"

可以看到::

   CONTAINER ID   IMAGE                PORTS
   588f22fe8980   alpine-node:latest   3000/tcp

- 使用以下命令可以检查镜像中 ``EXPOSE`` 端口而无需启动容器::

   docker inspect --format="{{json .Config.ExposedPorts}}" alpine-node:latest

输出显示::

   {"3000/tcp":{}}

这样用户在启动容器时候就可以配置相应的 ``PUBLISH`` 端口了，见下文。

PUBLISH端口
=============

既然 ``EXPOSE`` 端口只是定义可暴露端口而并没有输出端口，我们就需要在 ``docker run`` 命令中 ``显式`` 地 ``PUBLISH`` (发布)端口::

   docker run -itd -p 3000:3000 alpine-node:latest

然后检查 ``docker ps`` 可以看到明显不同的端口信息::

   CONTAINER ID   IMAGE                COMMAND            CREATED          STATUS          PORTS                                         NAMES
   f01c8a82dc61   alpine-node:latest   "node app.js"      34 seconds ago   Up 32 seconds   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp     objective_blackwell

可以看到，此时物理主机所有接口上 ``3000`` 端口都被映射到容器内部 ``3000`` 端口::

   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp

此时在物理主机上执行 ``netstat -an | grep 3000`` 会看到物理主机上已经打开了 ``3000`` 端口监听::

   tcp        0      0 0.0.0.0:3000            0.0.0.0:*               LISTEN
   tcp        0      0 :::3000                 :::*                    LISTEN

PUBLISH ``所有`` 端口
=====================

``docker`` 运行时候还提供了一个 ``--publish-all`` 参数，也就是 ``-P`` (大写)，会将Dockerfile中所有 ``EXPOSE`` 列出的端口全部 ``PUBLISH`` 出去::

   docker run -itd -P alpine-node:latest

此时 ``docker ps`` 可以看到::

   CONTAINER ID   IMAGE                COMMAND            CREATED          STATUS          PORTS                                         NAMES
   0af8544b5cc0   alpine-node:latest   "node app.js"      3 seconds ago    Up 1 second     0.0.0.0:49153->3000/tcp, :::49153->3000/tcp   elegant_yonath

虽然非常简单，但是有一个问题，就是在 ``host`` 主机上输出的端口是随机的，对于测试工作来说比较方便，但是如果是对外提供稳定服务则显然不受控制。

使用端口范围
=================

有时候容器内部需要 ``EXPOSE`` 一个端口范围::

   EXPOSE 8000-8100

可以通过以下命令方式将 ``host`` 主机上的一段端口范围和容器内部对应起来::

   docker run -p 6000-6100:8000-8100 ...

当然也可以使用 ``docker run --publish-all`` 把这100个端口直接输出，只不过物理主机上随机100个端口监听管理起来非常不方便。

什么时候不需要 ``PUBLISH`` 端口
===================================

如果你的容器只是在 ``host`` 物理主机内部做一个开发环境，并不对外通讯，你可以创建一个独立的内部网络，然后将这些容器连接到这个独立网络，而不会对外暴露(安全性)::

   docker network create demo-network
   docker run -d --network demo-network --name web web:latest
   docker run -d --network demo-network --name database database:latest

且慢，真的能访问容器内部的 ``3000`` 端口服务了吗?
====================================================

如果你完全参考我上文的案例，并使用 ``EXPOSE 3000`` 结合 ``docker run -p 3000:3000 alpine-node:latest`` 来运行Nodes.js案例程序，你会惊讶地发现，依然无法访问应用界面的 ``Hellow World`` ，原因就是 ``app-localhost.js`` 使用了::

   const hostname = '127.0.0.1';

这使得容器内部应用程序只监听回环地址；而 ``docker run`` 的 ``PUBLISH`` 指令是映射到容器内部的虚拟网卡上，所以无法访问。

.. figure:: ../../_static/docker/network/container_loopback.png
   :scale: 50

解决方法是修改 ``app.js`` 监听 ``0.0.0.0`` ，如下:

 .. literalinclude:: ../../linux/alpine_linux/alpine_dev/app.js
    :language: javascript
    :caption: nodejs Hello World (绑定0.0.0.0)
    :emphasize-lines: 5

则此时容器内服务会监听在内部虚拟机接口 ``172.17.0.2`` 上，就能通过Docker ``PUBLISH`` 端口映射到外部进行通讯:

.. figure:: ../../_static/docker/network/container_all_interfaces.png
   :scale: 50

参考
======

- `What’s the Difference Between Exposing and Publishing a Docker Port? <https://www.cloudsavvyit.com/14880/whats-the-difference-between-exposing-and-publishing-a-docker-port/>`_
- `Connection refused? Docker networking and how it impacts your image <https://pythonspeed.com/articles/docker-connection-refused/>`_
