.. _docker_concept:

===========================
Docker基本概念
===========================

镜像、层、容器
------------------

.. image:: ../_static/docker/docker_image_layer_container.png
   :scale: 50

* Docker Image

Docker镜像是最底层的包含文件系统和元数据的打包文件

* Docker Layer

Docker层是在镜像之上，根据不同需求不断叠加的文件修改内容。使用相同的镜像底层和相同的层创建的Docker容器是完全一致的。

* Docker Container

Docker容器就是从镜像上运行的实例，相同镜像可以运行多个容器，区别只是容器的名字不同。

.. note::

   用操作系统概念做一个对比：你可以将镜像看成存储在磁盘上的应用程序（文件），而容器就是把程序文件加载到内存中运行的进程。

   用面向对象编程做一个对比：镜像就相当于类，而容器相当于对象。对象是类的实例化，类似的，容器就是镜像的实例化。可以从单个镜像创建多个容器，每个容器都是彼此隔离的，就好像从类创建的对象也是彼此分离的。无论你如何修改对象，都不会影响到类的定义。

.. image:: ../_static/docker/docker_image_container.png
   :scale: 50

Docker镜像文件实际存储在磁盘中，镜像包含了文件（系统文件）和元数据，是应用程序运行环境。

.. note::

   元数据是环境变量、端口映射、卷等信息

当容器从镜像上运行起来，所修改的文件在容器中采用了 copy-on-write 机制存储，这样就不会影响到基础的镜像。容器是从镜像创建的，继承了镜像的文件系统，并使用元数据来决定启动配置。

containerd / runc 
====================

.. note::

   参考 `How containerd compares to runC <https://stackoverflow.com/questions/41645665/how-containerd-compares-to-runc>`_

在使用docker时候，会发现系统中有 ``containerd`` 也有 ``runc`` 进程，有必要梳理一下概念。

- `containerd <http://containerd.io/>`_ 是一个用于管理完整容器生命周期的容器运行服务，包括镜像传输和存储，以及容器运行，容器监督和容器网络都是由 ``contained`` 负责
- ``container-shim`` 负责处理headless 容器（没有显示输出的容器），即负责容器的初始化。这也表示，一旦 ``runc`` 初始化了容器， ``container-shim`` 就会退出处理容器，即这是一个中间状态。
- `runc <http://runc.io/>`_ 是一个轻量级统一运行时容器，遵守了OCI标准。 ``runc`` 是 ``containerd`` 使用的，用于启动并运行符合OCI标准的容器。这个进程也通常被 ``libcontainer`` 重新包装。
- `gRPC <http://www.grpc.io/>`_ 用于在docker-engine之间通讯。
- `OCI <https://www.opencontainers.org/>`_ 维护OCI的运行时和镜像标准。当前的docker版本支持OCI镜像和运行时标准。

.. image:: ../_static/docker/docker_containerd_runc.png

Docker容器内服务
===================

systemd
-------------

.. note::

   参考 `Start service using systemctl inside docker conatiner <https://stackoverflow.com/questions/46800594/start-service-using-systemctl-inside-docker-conatiner>`_
