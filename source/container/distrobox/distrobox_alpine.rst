.. _distrobox_alpine:

============================
Distrobox运行Alpine Linux
============================

在完成 :ref:`alpine_distrobox` 部署之后，我初步运行起 :ref:`distrobox_debian` 系统。但是我也想构建一个更为轻量级的容器，也就是 ``alpine on alpine`` : 在Alpine Linux Host 主机上通过 ``distrobox`` 来运行一个 Alpine Linux :ref:`podman` 容器。

快速起步
===========

- 创建alpine系统容器:

.. literalinclude:: distrobox_alpine/create
   :caption: 创建alpine容器

- 运行

.. literalinclude:: distrobox_alpine/run
   :caption: 运行alpine容器

基于Dockerfile构建
======================

使用 ``distrobox`` 来运行容器虽然简单，但是只是从官方下载标准镜像，首次进入初始化要做一次长时间安装更新，而且进入以后又要重新安装必要的软件，还是很繁琐的。

实际上 ``distrobox`` 底层使用的 :ref:`podman` 或 :ref:`docker` 都能够基于 :ref:`dockerfile` 来构建自定义镜像，可以包含需要安装的软件以及必要的基础配置。这些工作都是有积累的可重复的，所以我现在都是先构建自定义镜像，再使用 ``distrobox`` ，以结合两者优势。

- 准备 :ref:`alpine_docker_image` ``alpine-dev`` :

.. literalinclude:: ../../docker/images/alpine_docker_image/alpine-dev/Dockerfile_podman
   :caption: ``alpine-dev`` 镜像 Dockerfile

- 构建镜像:

.. literalinclude:: distrobox_alpine/build
   :caption: 构建 ``alpine-dev`` 镜像

- 运行容器:

.. warning::

   不能在Dockerfile中使用早期语法 ``EXPOSE 22:1122`` :

   原先Dockerfile中我习惯配置 ``EXPOSE 22:1122`` 以表明希望后续 ``docker run`` 时使用 ``-p 1122:22`` ，但是在 ``distrobox`` 实践中发现会检查Docker镜像中 ``EXPOSE`` 并报错显示端口语法错误:

   .. literalinclude:: distrobox_alpine/expose_invalid
      :caption: Dockerfile中 ``EXPOSE 22:1122`` 导致 ``distrobox`` 报错 "invalid port number"

   原因是现在 ``Dockerfile`` 中配置(文档) ``EXPOSE`` 语法应该是:

   .. literalinclude:: distrobox_alpine/expose_syntax
      :caption: ``Dockerfile`` 中 ``EXPOSE`` 语法

.. note::

   我参考 :ref:`distrobox_debian` 使用 ``--init-hook "sudo service ssh start"`` 来启动ssh服务，配置:

   .. literalinclude:: distrobox_alpine/create_alpine-dev_init-hooks
      :caption: 配置 ``--init-hooks "sudo rc-service sshd start"`` 尝试容器启动时启动ssh服务
      
   结果启动:

   .. literalinclude:: distrobox_alpine/run
      :caption: 运行容器

   失败

   检查 ``podman logs alpine-dev`` 显示ssh服务早已启动，重复执行启动ssh导致报错:

   .. literalinclude:: distrobox_alpine/run_alpine-dev_init-hooks_error
      :caption: 由于容器内ssh服务已启动，再执行 ``--init-hooks "sudo rc-service sshd start"`` 报错

   **真是这样吗?**

   请参考 :ref:`distrobox_sshd` 调查

