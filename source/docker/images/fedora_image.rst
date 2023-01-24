.. _fedora_image:

===================
Fedora镜像
===================

我采用 :ref:`fedora` 作为个人开发工作环境，在 :ref:`macos_studio` 的 :ref:`kind` 上运行Fedora容器，以便能够快速构建稳定的工作环境。不管更换什么底层系统( :ref:`linux` / :ref:`windows` / :ref:`macos` )都能立即拉起工作环境进行开发。

.. note::

   由于使用 :ref:`dockerfile` 重复构建镜像时，需要重复在容器内部执行各种软件包安装下载，非常消耗时间。为了能够节约部署时间(特别是局域网内部)，我采用在 :ref:`k8s_deploy_squid` 在我的 :ref:`kind` ( :ref:`macos_studio` ) ，这样不断重复相同操作系统的安装升级可以节约时间和带宽。

准备工作
================

由于Docker镜像制作需要反复测试，容器内部OS更新和软件安装会不断重复，所以为了加快进度和节约带宽，采用 :ref:`docker_client_proxy` 配置来加速:

.. literalinclude:: fedora_image/docker.json
   :language: json
   :caption: 配置docker容器内部都采用 "kind" 网络运行的 :ref:`docker_squid` 代理加速
   :emphasize-lines: 3-11

基础运行 ``fedora-base``
===============================

- 初始构建一个基础fedora:

.. literalinclude:: fedora_image/base/Dockerfile
   :language: dockerfile
   :caption: 基础Fedora镜像Dockerfile

- 构建 ``fedora-base`` 镜像:

.. literalinclude:: fedora_image/base/build_fedora-base_image
   :language: bash
   :caption: 构建基础Fedora镜像Dockerfile

- 运行 ``fedora-base`` 镜像:

.. literalinclude:: fedora_image/base/run_fedora-base_container
   :language: bash
   :caption: 运行fedora-base容器

.. note::

   这里配置容器运行网络是 "kind" ，以便能够和 :ref:`docker_squid` 以及 :ref:`macos_studio` 部署的 :ref:`kind` ``dev`` 运行在同一个bridge网络，方便实现代理`

- 连接到 ``fedora`` 容器内:

.. literalinclude:: fedora_image/base/exec_fedora_container
   :language: bash
   :caption: 通过docker exec运行容器内部bash

- 执行 ``dnf update`` 已经进一步安装应用软件，可以观察到 :ref:`docker_squid` 起到了缓存加速作用，这样后续迭代Dockerfile就节约了时间和带宽

