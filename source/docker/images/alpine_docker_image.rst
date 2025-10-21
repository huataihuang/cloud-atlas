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

.. warning::

   这里你很可能和我一样遇到GFW屏蔽docker registry导致的报错:

   .. literalinclude:: ../../rancher/rancher_desktop/config_docker_deamon_rancher_desktop/registry_fail
      :caption: 由于docker registry被屏蔽的报错
      :emphasize-lines: 4,14

   请参考 :ref:`config_docker_deamon_rancher_desktop` 或者 :ref:`docker_proxy`

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

.. _alipine-nginx:

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
   :emphasize-lines: 6

.. note::

   修订默认的 ``/etc/nginx/http.d/default.conf`` 是在 :ref:`kubernetes` 中运行自定义AlpineLinux NGINX的重要一步

   :ref:`dockerfile_entrypoint_vs_cmd`

- 构建 ``alpine-nginx`` 镜像:

.. literalinclude:: alpine_docker_image/alpine-nginx/build_alpine-nginx_image
   :language: bash
   :caption: 构建提供nginx的alpine linux镜像

- 注意: 默认的 ``default.conf`` :

.. literalinclude:: alpine_docker_image/alpine-nginx/default_origin.conf
   :language: bash
   :caption: 默认nginx的网站配置 /etc/nginx/http.d/default.conf

必须被配置允许访问的 ``default.conf`` 替换，否则类似 :ref:`kind_run_simple_container` 无法启动(见下文)

- 简单的运行 ``alpine-nginx`` 验证:

.. literalinclude:: alpine_docker_image/alpine-nginx/run_alpine-nginx_container
   :language: bash
   :caption: 简单地运行alpine-nginx验证镜像

现在验证通过的NGINX镜像，是否就可以用到 :ref:`kind_run_simple_container` 呢？


不能在Kubernetes启动的 ``alpine-nginx``
------------------------------------------

实际 :ref:`alpine_linux` 出于安全考虑(这是一个注重安全的面向嵌入式平台的发行版)，将 ``default.conf`` 设置成禁止访问(直接返回 ``404`` )，而不是一般发行版默认允许访问 ``index.html`` 。

这导致我在 :ref:`kind_run_simple_container` 遇到始终出现 :ref:`k8s_health_check` 失败的 :ref:`k8s_crashloopbackoff`

解决的方法也很简单，就是准备好一个允许正常访问的 ``default.conf`` 在 BUILD 时候覆盖镜像中的配置文件，这个 ``default.conf`` 可以如下:

.. literalinclude:: alpine_docker_image/alpine-nginx/default.conf
   :language: bash
   :caption: 修订后nginx的网站配置 /etc/nginx/http.d/default.conf，可以让nginx正常运行满足Kubernetes健康检查

下一步
--------

我将部署到 :ref:`kind` 集群中来模拟 :ref:`kubernetes` 运行:

  - :ref:`load_kind_image` 或者先部署 :ref:`kind_local_registry` 然后统一从Registry下载镜像构建Kubernetes运行的pod
  - 使用 :ref:`zfs_nfs` 提供共享存储
  - 配置 :ref:`k8s_nfs` 将共享卷中我的 ``cloud-atlas`` build好的html作为NGINX的目录(配置和上文Docker运行方式类似)

SSH服务 ``alpine-ssh``
=======================

.. note::

   参考 :ref:`debian_tini_image` 配置 ``alpine-ssh`` 镜像

.. literalinclude:: alpine_docker_image/alpine-ssh/Dockerfile
   :caption: 采用 ``tini`` 进程管理启动ssh服务


参考
=======

- `How to Use the Alpine Docker Official Image <https://www.docker.com/blog/how-to-use-the-alpine-docker-official-image/>`_
- `Deploying NGINX and NGINX Plus with Docker <https://www.nginx.com/blog/deploying-nginx-nginx-plus-docker/>`_
