.. _alpine_docker_image:

===========================
Alpine Docker镜像
===========================

作为兼顾安全和轻量级的 :ref:`alpine_linux` 是 :ref:`docker` 默认的基础镜像，能够极大地缩减Docker镜像，并且降低运行资源，真正体现容器的轻量、灵活。

如果你像我一样，尝试从0开始在 :ref:`arm` 架构( 例如 :ref:`apple_silicon_m1_pro` 和 :ref:`raspberry_pi` )构建自己的 :ref:`mobile_cloud` ，那么你可以从最精简的 :ref:`alpine_linux` 基础镜像开始，只在镜像中添加和运行程序直接相关的库和工具，避免引入不必要的系统开销和安全隐患。

Alpine Docker官方镜像
========================

Alpine DOI(Docker Official Image)是一个包含执行软件堆栈的Alpine Linux Docker镜像，包含你的源代码，库，工具以及应用程序运行的必要核心依赖。

和其他Linux发行版不同:

- Alpine基于 ``musl libc`` 实现C标准库
- Alpine使用 ``BusyBox`` (用一个执行程序替代一组核心功能程序)替代 ``GNU coreutils``

:ref:`alpine_linux` 吸引了不需要强制性兼容和功能的开发人员，并且提供了友好和直接的使用体验(没有复杂的软件组合)。

采用 :ref:`alpine_linux` 构建的运行容器镜像都非常精简:

.. csv-table:: alpine linux镜像大小
   :file: alpine_docker_image/alpine_linux_images_size.csv
   :widths: 40, 60
   :header-rows: 1

基础运行 ``alpine-base``
============================

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

基础运行 ``alpine-bash``
==========================

.. note::

   很多运维人员习惯使用 ``bash`` ，所以也可以构建支持 ``bash`` 的 :ref:`alpine_linux`

- 在 ``alpine-bash`` 目录下 ``Dockerfile`` :

.. literalinclude:: alpine_docker_image/alpine-bash/Dockerfile
   :language: dockerfile
   :caption: 提供bash的alpine linux镜像Dockerfile

- 构建 ``alpine-bash`` 镜像:

.. literalinclude:: alpine_docker_image/alpine-bash/build_alpine-bash_image
   :language: bash
   :caption: 构建提供bash的alpine linux镜像

- 运行 ``alpine-bash`` :

.. literalinclude:: alpine_docker_image/alpine-bash/run_alpine-bash_container
   :language: dockerfile
   :caption: 运行提供bash的alpine linux容器

NGINX服务 ``alpine-nginx``
===========================

.. note::

   提供nginx服务的alpine镜像: 我准备将数据存放在 ``/data`` 目录下( :ref:`kubernetes` ):

   - ``html`` 子目录存放 WEB 内容( :ref:`zfs_nfs` )
   - ``nginx`` 软件包安装后默认 ``nginx.conf`` 将读取的 ``/etc/nginx/http.d`` 目录下配置，其中 ``/etc/nginx/httpd.defult.conf`` 配置可覆盖修改以使用自己定制的数据目录

- 在 ``alpine-nginx`` 目录下 ``Dockerfile`` :

.. literalinclude:: alpine_docker_image/alpine-nginx/Dockerfile
   :language: dockerfile
   :caption: 提供nginx的alpine linux镜像Dockerfile

- 构建 ``alpine-nginx`` 镜像:

.. literalinclude:: alpine_docker_image/alpine-nginx/build_alpine-nginx_image
   :language: bash
   :caption: 构建提供nginx的alpine linux镜像

- 简单的 ``default.conf`` :

.. literalinclude:: alpine_docker_image/alpine-nginx/default.conf
   :language: bash
   :caption: 默认nginx的网站配置 /etc/nginx/http.d/default.conf

- 简单的运行 ``alpine-nginx`` 验证:

.. literalinclude:: alpine_docker_image/alpine-nginx/run_alpine-nginx_container
   :language: bash
   :caption: 简单地运行alpine-nginx验证镜像

SSH服务 ``alpine-ssh``
=======================


参考
=======

- `How to Use the Alpine Docker Official Image <https://www.docker.com/blog/how-to-use-the-alpine-docker-official-image/>`_
- `Deploying NGINX and NGINX Plus with Docker <https://www.nginx.com/blog/deploying-nginx-nginx-plus-docker/>`_
