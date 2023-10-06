.. _ubuntu_tini_image:

================================
Ubuntu镜像(采用tini替代systemd)
================================

.. note::

   由于使用 :ref:`dockerfile` 重复构建镜像时，需要重复在容器内部执行各种软件包安装下载，非常消耗时间。为了能够节约部署时间(特别是局域网内部)，我采用在 :ref:`k8s_deploy_squid` 在我的 :ref:`kind` ( :ref:`macos_studio` ) ，这样不断重复相同操作系统的安装升级可以节约时间和带宽。

我构建基于 :ref:`ubuntu_linux` 的Android开发环境，基于 :ref:`ubuntu_tini_image` 修改，来实现一个轻量级的Ubuntu通用开发环境。这样我的实践就覆盖了 :ref:`redhat_linux` 系(rpm)和 Debian系(apt)两个主流发行版的Docker镜像。

准备工作
================

由于Docker镜像制作需要反复测试，容器内部OS更新和软件安装会不断重复，所以为了加快进度和节约带宽，采用 :ref:`docker_client_proxy` 配置来加速: (注意：这里首先需要在docker集群中部署 :ref:`docker_squid` 代理容器，然后通过 :ref:`docker_client_proxy` 配置为所有docker容器注入使用代理服务器访问外网来加速下载)

- 修改 ``~/.docker/config.json`` :

.. literalinclude:: fedora_image/config.json
   :language: json
   :caption: 采用默认docker网络 bridge 上部署的 :ref:`docker_squid` 代理

基础运行 ``ubuntu-base-tini``
===============================

- 初始构建一个基础Ubuntu:

.. literalinclude:: ubuntu_tini_image/base/Dockerfile
   :language: dockerfile
   :caption: 基础Ubuntu镜像Dockerfile

- 构建 ``ubuntu-base-tini`` 镜像:

.. literalinclude:: ubuntu_tini_image/base/build_ubuntu-base-tini_image
   :language: bash
   :caption: 构建基础Ubuntu镜像Dockerfile

- 运行 ``ubuntu-base-tini`` 镜像:

.. literalinclude:: ubuntu_tini_image/base/run_ubuntu-base-tini_container
   :language: bash
   :caption: 运行ubuntu-base-tini容器

- 连接到 ``ubuntu-base-tini`` 容器内:

.. literalinclude:: ubuntu_tini_image/base/exec_ubuntu-base-tini_container
   :language: bash
   :caption: 通过docker exec运行容器内部bash

tini运行ssh ``ubuntu-ssh-tini``
====================================

.. note::

   `How to enable SSH connections into a Kubernetes pod <https://blog.lapw.at/how-to-enable-ssh-into-a-kubernetes-pod/>`_ 提供了一个更好的部署SSH key的 :ref:`config_pod_by_configmap` 方法，适合对不同用户在部署pods时候注入SSH key和构建用户HOME目录，后续借鉴实践。

   我改进了之前在 :ref:`fedora_tini_image` 的方案: 原先是直接在制作镜像时直接将公钥注入到镜像中，这个方法虽然简单但是比较笨拙(固化)，所以我现在改为通过卷映射方式，将本地物理主机上的目录 ``home/`` 映射到容器内部:

   - 可以灵活替换和修改密钥(也方便作为通用方案)
   - 兼顾了用户目录数据持久化: 卷映射可以避免容器销毁后数据丢失，重建容器也可以保持数据。此外，如果多个容器共享一个映射目录，可以互相传递数据

按照 :ref:`docker_tini` 经验总结，实现一个初始完备的远程可登录 :ref:`ubuntu_linux` 系统:

- ``ubuntu-ssh-tini`` 包含了安装 :ref:`docker_tini` 以及 :ref:`ssh` 服务，并构建基于认证的SSH登陆环境:

.. literalinclude:: ubuntu_tini_image/ssh/Dockerfile
   :language: dockerfile
   :caption: 具备ssh服务的ubuntu镜像Dockerfile

其中，使用的 ``entrypoint.sh`` 脚本是 :ref:`kind_deploy_fedora-dev-tini` 实践中改进过的脚本:

.. literalinclude:: fedora_tini_image/ssh/entrypoint_ssh_cron_bash
   :language: bash
   :caption: ``/entrypoint.sh`` 脚本的 ``main()`` 确保持续运行(循环)

.. note::

   这里在 ``/entrypoint.sh`` 增加了一个将 ``/home/admin`` 目录修订属主的命令，这是因为默认映射的目录属主是容器内部的 ``root`` 用户

- 构建 ``ubuntu-ssh-tini`` 镜像:

.. literalinclude:: ubuntu_tini_image/ssh/build_ubuntu-ssh-tini_image
   :language: bash
   :caption: 构建包含tini和ssh的ubuntu镜像

- 运行 ``ubuntu-ssh-tini`` :

.. literalinclude:: ubuntu_tini_image/ssh/run_ubuntu-ssh-tini_container
   :language: bash
   :caption: 运行包含tini和ssh的ubuntu容器

开发环境 ``ubuntu-dev-tini``
===============================

在 ``ubuntu-ssh-tini`` 基础上，增加开发工具包安装:

- ``ubuntu-dev-tini`` 包含了安装常用工具和开发环境，并编译和安装必要的vim环境:

.. literalinclude:: ubuntu_tini_image/dev/Dockerfile
   :language: dockerfile
   :caption: 包含常用工具和开发环境的ubuntu镜像Dockerfile

.. csv-table:: ``ubuntu-dev-tini`` 镜像说明
   :file: ubuntu_tini_image/ubuntu-dev.csv
   :widths: 20,80
   :header-rows: 1

- 构建 ``ubuntu-dev-tini`` 镜像:

.. literalinclude:: ubuntu_tini_image/dev/build_ubuntu-dev-tini_image
   :language: bash
   :caption: 构建包含开发环境的ubuntu镜像

- 运行 ``ubuntu-dev-tini`` :

.. literalinclude:: ubuntu_tini_image/dev/run_ubuntu-dev-tini_container
   :language: bash
   :caption: 运行包含开发环境的ubuntu容器

