.. _docker-infrastructure:

======================
Docker架构
======================

.. note::

   理解Docker架构可以帮助你更好使用Docker，避免使用误区，更好发挥Docker的优势。

.. image:: ../_static/docker/docker_architecture.png
   :scale: 50

在运行Docker的host主机上，Docker分为两部分 -- 提供RESTful API的daemon服务 以及 和daemon服务交互的客户端。

.. note::

   RESTful API使用标准的HTTP请求类型： ``GET`` ， ``POST`` ， ``DELETE`` 以及其他反映资源及对资源对操作。在Docker概念中，镜像、容器、卷就是表达的资源。

在使用 ``docker`` 命令就是通过Docker客户端向Docker的服务器请求信息和获取结构；服务端接收请求并使用HTTP协议返回响应。这里的服务器可以接收命令行客户端的请求也可以接收任何授权连接的请求。

在Docker架构中，所有的请求调用和返回响应都是采用RESTful API方式。

对于私有Docker registry，是运行在内部局域网的Docker镜像存储服务，可以避免外部非授权访问，也加速了镜像的分发。

Docker Hub则是由Docker公司提供的公共Docker registry，此外也可以使用第三方的公共镜像中心。

Docker daemon
================

Docker daemon是Docker交互的中心，也是理解相关Docker概念的起点，它管理这容器和镜像的状态，并且是和外部世界交互的代理：

.. image:: ../_static/docker/docker_daemon.png
   :scale: 50

