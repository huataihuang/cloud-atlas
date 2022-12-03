.. _docker_multi-platform_images:

=========================================
Docker多平台镜像(multi-platform images)
=========================================

Docker镜像可以支持多平台(multiple platforms)，意味着单个镜像可能包含针对不同架构的变体(contain variants for different architectures)，有时候还包含了针对不同的操作系统(例如Windows)的变体。

当运行一个支持多平台的镜像， ``docker`` 会自动选择匹配你的OS和架构的镜像。

大多数存储在Docker Hub的docker官方镜像都提供一系列架构。例如 ``busybox`` 镜像支持 ``amd64, arm32v5, arm32v6, arm32v7, arm64v8, i386, ppc64le, s390x`` 。当运行在 ``x86_64 / amd64`` 主机时，会自动下载和运行 ``amd64`` 。

构建多平台镜像
===============

采用 ``Buildx`` 的 ``BuildKit`` 可以为多平台构建镜像，而不会仅限于构建时用户恰好使用的体系结构和操作系统。

调用 ``build`` 的时候，可以设置 ``--platform`` 参数来指定构建输出的目标平台(例如， ``linux/amd64`` , ``linux/arm64`` 或者 ``darwin/amd64`` )。

如果当前构建实例的后端是采用 ``docker-container`` 驱动，则可以同时指定多个平台架构。此时，会构建一个清单列表，其中包含所有指定架构的镜像。这样，当使用 ``docker run`` 或者在docker服务中使用这个镜像时，Docker会自动根据节点的平台选择正确的镜像。

可以使用 ``Buildx`` 和 ``Dockerfiles`` 支持三种不同策略构建多平台镜像:

- 在内核中使用 QEMU 仿真支持
- 使用相同的bulder实例在多个原生节点构建
- 使用Dockerfile中的阶段交叉编译到不同的体系结构

.. note::

   这里实践需要参考 :ref:`buildkit_startup` 进行

.. _docker_official_multi-platform_images:

Docker官方多平台镜像(Docker Official Images Architectures other than amd64)
----------------------------------------------------------------------------

官方镜像的Dockerfile格式使用类似如下:


参考
======

- `Building Multi-Arch Images for Arm and x86 with Docker Desktop <https://www.docker.com/blog/multi-arch-images/>`_
- `arm Developer: Getting started with Docker - Multi-architecture images <https://developer.arm.com/documentation/102475/0100/Multi-architecture-images>`_ ARM官方开发指南中有关多架构镜像的构建
- `docker build: multi-platform images <https://docs.docker.com/build/building/multi-platform/>`_
- `Faster Multi-Platform Builds: Dockerfile Cross-Compilation Guide <https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/>`_
- `Multi-Platform Docker Builds <https://www.docker.com/blog/multi-platform-docker-builds/>`_
- `Building Multiplatform Container Images the Easy Way <https://blog.container-solutions.com/building-multiplatform-container-images>`_
