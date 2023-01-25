.. _fedora_image:

===================
Fedora镜像
===================

我采用 :ref:`fedora` 作为个人开发工作环境，在 :ref:`macos_studio` 的 :ref:`kind` 上运行Fedora容器，以便能够快速构建稳定的工作环境。不管更换什么底层系统( :ref:`linux` / :ref:`windows` / :ref:`macos` )都能立即拉起工作环境进行开发。

.. note::

   由于使用 :ref:`dockerfile` 重复构建镜像时，需要重复在容器内部执行各种软件包安装下载，非常消耗时间。为了能够节约部署时间(特别是局域网内部)，我采用在 :ref:`k8s_deploy_squid` 在我的 :ref:`kind` ( :ref:`macos_studio` ) ，这样不断重复相同操作系统的安装升级可以节约时间和带宽。

准备工作
================

由于Docker镜像制作需要反复测试，容器内部OS更新和软件安装会不断重复，所以为了加快进度和节约带宽，采用 :ref:`docker_client_proxy` 配置来加速

我最初想采用 ``kind`` 网路部署 :ref:`docker_squid` 代理加速

.. literalinclude:: fedora_image/docker.json
   :language: json
   :caption: 配置docker容器内部都采用 "kind" 网络运行的 :ref:`docker_squid` 代理加速
   :emphasize-lines: 3-11

需要注意，所有 ``docker run`` 需要加上 ``--network kind`` 以便能够不使用默认的 ``default`` 网络，而改为使用 ``kind`` bridge网络

但是很奇怪， ``docker build`` 的 ``--network`` 参数和 ``docker run`` 不同，不是指定连接的网络，而是指定网络模式::

   --network string          Set the networking mode for the RUN instructions during build (default "default")

这给我带来很大困扰，因为当前除了Docker默认的3种网络模式，我在 :ref:`macos_studio` 使用 :ref:`kind` 构建时创建的 ``kind`` 网络也是 ``bridge`` 类型的::

   % docker network ls
   NETWORK ID     NAME      DRIVER    SCOPE
   6137c2fed5b2   bridge    bridge    local
   3536bf002494   host      host      local
   ce9eaba7480a   kind      bridge    local
   2e726b8a3f97   none      null      local

参考 `Exploring Default Docker Networking Part 1 <https://blogs.cisco.com/learning/exploring-default-docker-networking-part-1>`_ :

  - 容器网络通过 ``docker network ls`` 以及 ``docker network inspect <network_name>`` 可以检查网络参数，包括 ``default`` 指网络参数 ``"com.docker.network.bridge.default_bridge": "true"``
  - 一种方式是采用 :ref:`docker_squid` 中思考的方案，在一个容器中插入多个网段网卡，同时为多个网络提供代理；docker注入代理环境变量时采用域名而不是IP，以便bind进容器的 ``/etc/hosts`` 能够提供不同的解析
  - 另一种方式是简化docker配置，只部署默认网络的 :ref:`docker_squid` ， ``kind`` 网络的代理留给 :ref:`k8s_deploy_squid_startup` 来解决(目前我采用这个方法加快部署)

所以，我调整了 :ref:`docker_squid` 将 ``kind`` 网络绑定摘除，恢复构建到Docker default网络的 ``squid`` 容器，然后修改

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

   这里配置容器运行网络是 "kind" ，以便能够和 :ref:`docker_squid` 以及 :ref:`macos_studio` 部署的 :ref:`kind` ``dev`` 运行在同一个bridge网络，方便实现代理

- 连接到 ``fedora`` 容器内:

.. literalinclude:: fedora_image/base/exec_fedora_container
   :language: bash
   :caption: 通过docker exec运行容器内部bash

- 执行 ``dnf update`` 可以进一步安装应用软件，可以观察到 :ref:`docker_squid` 起到了缓存加速作用，这样后续迭代Dockerfile就节约了时间和带宽

systemd运行ssh ``fedora-ssh``
====================================

按照 :ref:`docker_systemd` 经验总结，采用以下方法实现Docker容器内通过 :ref:`systemd` 运行ssh，实现一个初始完备的远程可登录 :ref:`fedora` 系统:

- ``fedora-ssh`` 包含了安装 :ref:`systemd` 以及 :ref:`ssh` 服务，并构建基于认证的SSH登陆环境:

.. literalinclude:: fedora_image/ssh/Dockerfile
   :language: dockerfile
   :caption: 包含systemd和ssh的Fedora镜像Dockerfile

- 构建 ``fedora-ssh`` 镜像:

.. literalinclude:: fedora_image/ssh/build_fedora-ssh_image
   :language: bash
   :caption: 构建包含systemd和ssh的Fedora镜像


