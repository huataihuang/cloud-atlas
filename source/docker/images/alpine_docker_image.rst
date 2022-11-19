.. _alpine_docker_image:

===========================
Alpine Docker镜像
===========================

作为兼顾安全和轻量级的 :ref:`alpine_linux` 是 :ref:`docker` 默认的基础镜像，能够极大地缩减Docker镜像，并且降低运行资源，真正体现容器的轻量、灵活。

如果你像我一样，尝试从0开始在 :ref:`arm` 架构( 例如 :ref:`apple_silicon_m1_pro` 和 :ref:`raspberry_pi` )构建自己的 :ref:`mobile_cloud` ，那么你可以从最精简的 :ref:`alpine_linux` 基础镜像开始，只在镜像中添加和运行程序直接相关的库和工具，避免引入不必要的系统开销和安全隐患。

Alpine Docker官方镜像
========================

Alpine DOI(Docker Official Image)是一个包含执行软件堆栈的Alpine Linux Docker镜像，包含你的源代码，库，工具以及应用程序晕高兴的必要核心依赖。

和其他Linux发行版不同:

- Alpine基于 ``musl libc`` 实现C标准库
- Alpine使用 ``BusyBox`` (用一个执行程序替代一组核心功能程序)替代 ``GNU coreutils``

.. note::

   :ref:`alpine_linux` 吸引了不需要强制性兼容和功能的开发人员，并且提供了友好和直接的使用体验(没有复杂的软件组合)

构建Dockerfile
==================

.. note::

   如果镜像下载过于缓慢，请配置 :ref:`docker_server_socks_proxy`

基础运行
-----------

- 在 ``alpine-base`` 目录下 ``Dockerfile`` :

.. literalinclude:: alpine_docker_image/alpine-base/Dockerfile
   :language: dockerfile
   :caption: 基础alpine linux镜像Dockerfile

.. note::

   注意 :ref:`docker_json_use_double_quotes`

- 构建 ``alpine-base`` 镜像:

.. literalinclude:: alpine_docker_image/alpine-base/build_alpine-base_image
   :language: bash
   :caption: 构建基础alpine linux镜像

- 如果在本地Docker中运行，则直接执行:

.. literalinclude:: alpine_docker_image/alpine-base/run_alpine-base_container
   :language: bash
   :caption: 运行alpine linux基础镜像的容器

.. note::

   :ref:`alpine_linux` 使用 :ref:`alpine_apk` 安装软件

添加SSH服务
-------------


参考
=======

- `How to Use the Alpine Docker Official Image <https://www.docker.com/blog/how-to-use-the-alpine-docker-official-image/>`_
