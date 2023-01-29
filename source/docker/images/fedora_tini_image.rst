.. _fedora_tini_image:

================================
Fedora镜像(采用tini替代systemd)
================================

虽然我构建的 :ref:`fedora_image` (使用systemd作为init进程管理器)能够完美在Docker中运行，但是迁移到 :ref:`kubernetes` 中运行( :ref:`kind_deploy_fedora-dev` )却无法正确初始化 :ref:`systemd` 。我尝试采用Docker默认的init管理器 :ref:`docker_tini` 来再次尝试构建镜像，以期能够在 :ref:`kind_deploy_fedora-dev-tini`

.. note::

   由于使用 :ref:`dockerfile` 重复构建镜像时，需要重复在容器内部执行各种软件包安装下载，非常消耗时间。为了能够节约部署时间(特别是局域网内部)，我采用在 :ref:`k8s_deploy_squid` 在我的 :ref:`kind` ( :ref:`macos_studio` ) ，这样不断重复相同操作系统的安装升级可以节约时间和带宽。

准备工作
================

由于Docker镜像制作需要反复测试，容器内部OS更新和软件安装会不断重复，所以为了加快进度和节约带宽，采用 :ref:`docker_client_proxy` 配置来加速:

- 修改 ``~/.docker/config.json`` :

.. literalinclude:: fedora_image/config.json
   :language: json
   :caption: 采用默认docker网络 bridge 上部署的 :ref:`docker_squid` 代理

- 还有一个问题需要解决: 默认 :ref:`dnf` 会使用 ``mirrors.fedoraproject.org`` 来侦测最快的镜像网站，但是实际上每次选择可能都是不同网站，这导致代理服务缓存效果很差。解决的思路是注释掉 ``metalink=`` 行，启用固定的 ``baseurl=`` 行 ( `How to disable some mirrors for use by dnf in Fedora [closed] <https://unix.stackexchange.com/questions/533543/how-to-disable-some-mirrors-for-use-by-dnf-in-fedora>`_ 提及原先 ``yum-plugin-fastestmirror`` 被移植到dnf时没有移植参数调整功能 )

我采用 :ref:`sed` 修订 ``/etc/yum.repos.d`` 目录下配置:

.. literalinclude:: fedora_image/disable_dnf_mirrors
   :language: bash
   :caption: 关闭dnf镜像列表功能，指定固定软件仓库以便优化使用proxy代理缓存

这里有一个 ``fedora-cisco-openh264.repo`` 配置文件没有提供 ``baseurl=`` ，实际这个只有一个下载地址，所以跳过替换

下文我将脚本融入 :ref:`dockerfile` 中执行

基础运行 ``fedora-base-tini``
===============================

- 初始构建一个基础fedora:

.. literalinclude:: fedora_tini_image/base/Dockerfile
   :language: dockerfile
   :caption: 基础Fedora镜像Dockerfile

- 构建 ``fedora-base-tini`` 镜像:

.. literalinclude:: fedora_tini_image/base/build_fedora-base-tini_image
   :language: bash
   :caption: 构建基础Fedora镜像Dockerfile

- 运行 ``fedora-base-tini`` 镜像:

.. literalinclude:: fedora_tini_image/base/run_fedora-base-tini_container
   :language: bash
   :caption: 运行fedora-base-tini容器

- 连接到 ``fedora-base-tini`` 容器内:

.. literalinclude:: fedora_tini_image/base/exec_fedora-base-tini_container
   :language: bash
   :caption: 通过docker exec运行容器内部bash

tini运行ssh ``fedora-ssh-tini``
====================================

.. note::

   `How to enable SSH connections into a Kubernetes pod <https://blog.lapw.at/how-to-enable-ssh-into-a-kubernetes-pod/>`_ 提供了一个更好的部署SSH key的 :ref:`config_pod_by_configmap` 方法，适合对不同用户在部署pods时候注入SSH key和构建用户HOME目录，后续借鉴实践。

按照 :ref:`docker_tini` 经验总结，采用以下方法实现Docker容器内通过 :ref:`systemd` 运行ssh，实现一个初始完备的远程可登录 :ref:`fedora` 系统:

- ``fedora-ssh-tini`` 包含了安装 :ref:`docker_tini` 以及 :ref:`ssh` 服务，并构建基于认证的SSH登陆环境:

.. literalinclude:: fedora_tini_image/ssh/Dockerfile
   :language: dockerfile
   :caption: 包含tini和ssh的Fedora镜像Dockerfile

- 构建 ``fedora-ssh-tini`` 镜像:

.. literalinclude:: fedora_tini_image/ssh/build_fedora-ssh-tini_image
   :language: bash
   :caption: 构建包含tini和ssh的Fedora镜像

- 运行 ``fedora-ssh-tini`` :

.. literalinclude:: fedora_tini_image/ssh/run_fedora-ssh-tini_container
   :language: bash
   :caption: 运行包含tini和ssh的Fedora容器

开发环境 ``fedora-dev-tini``
===============================

在 ``fedora-ssh-tini`` 基础上，增加开发工具包安装:

- ``fedora-dev-tini`` 包含了安装常用工具和开发环境，并编译和安装必要的vim环境:

.. literalinclude:: fedora_tini_image/dev/Dockerfile
   :language: dockerfile
   :caption: 包含常用工具和开发环境的Fedora镜像Dockerfile

.. csv-table:: ``fedora-dev-tini`` 镜像说明
   :file: fedora_image/fedora-dev.csv
   :widths: 20,80
   :header-rows: 1

- 构建 ``fedora-dev-tini`` 镜像:

.. literalinclude:: fedora_tini_image/dev/build_fedora-dev-tini_image
   :language: bash
   :caption: 构建包含开发环境的Fedora镜像

- 运行 ``fedora-dev-tini`` :

.. literalinclude:: fedora_tini_image/dev/run_fedora-dev-tini_container
   :language: bash
   :caption: 运行包含开发环境的Fedora容器

``修正`` : 真正能够用于Kubernetes的Dockerfile
=================================================

.. warning::

   在 :ref:`kind_deploy_fedora-dev-tini` 实践中发现，上述 ``fedora-dev-tini`` 和 ``fedora-ssh-tini`` 都会 ``Crash`` ，原因是 ``/entrypoint.sh`` 脚本直接运行结束，会被 Kubernetes 判断为程序 Crash 。所以，实际 ``/entrypoint.sh`` 需要改写成最后执行的 ``bash`` 命令永不结束！！！


