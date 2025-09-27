.. _docker_proxy_quickstart:

==========================
Docker 代理快速起步
==========================

.. note::

   本文综合了我的 :ref:`docker_proxy` 和 :ref:`colima_proxy` 实践经验，力求快速准确完成Docker :ref:`across_the_great_wall`

概述
========

- 采用我认为最简便且安全的 :ref:`ssh_tunneling` 将本地回环地址端口 ``3128`` 映射到墙外的VPS上 :ref:`squid` 或 :ref:`privoxy` 服务端口 ``3128`` (本文没有包含VPS上代理服务器安装配置，所以请参考对应章节)
- HOST物理服务器配置软件仓库代理( :ref:`yum_proxy` / :ref:`apt_proxy` )
- HOST物理服务器全局配置代理(可设置部分不代理)，将作用于HOST主机的 :ref:`curl_proxy` 以及大多数符合Linux代理规范的应用
- 启用 :ref:`docker` 客户端代理(部分docker获取META信息需要翻墙，因为docker.com已经完整被墙)
- 启用 :ref:`docker` 服务端代理(包括 :ref:`docker` 控制服务和 :ref:`containerd` 运行时服务)，这样Docker可以从官方镜像仓库下载镜像
- 启动 :ref:`docker` 容器内部操作系统代理，这样Docker容器能够通过Docker NAT网络的网关(也就是HOST物理主机)代理访问外部世界(注意代理地址从回环地址 ``127.0.0.1`` 改为Docker NAT网关地址 ``172.17.0.1`` )

请读者根据自己的需求进行调整，可能有些步骤对于你的环境不是必要的

HOST物理服务器构建代理映射( :ref:`ssh_tunneling` )
====================================================

- 通过 :ref:`ssh_tunneling` 构建一个本地到远程服务器代理服务端口(服务器上代理服务器仅监听回环地址)的SSH加密连接，方法是配置 ``~/.ssh/config`` ( ``<SERVER_IP>`` 以实际地址配置) **端口转发要设置允许Docker NAT网关地址** :

.. literalinclude:: ../../container/colima/colima_proxy_archive/ssh_config
   :caption: ``~/.ssh/config`` 配置 :ref:`ssh_tunneling` 构建一个本地到远程服务器Proxy端口加密连接
   :emphasize-lines: 13

- 执行以下命令构建SSL Tunnel:

.. literalinclude:: ../../container/colima/colima_proxy_archive/ssh
   :caption: 通过SSH构建了本地的一个SSH Tunneling到远程服务器的 :ref:`proxy` 服务

HOST物理服务器apt代理
======================

- :ref:`ubuntu_linux` 设置 ``/etc/apt/apt.conf.d/01-vendor-ubuntu`` ; :ref:`debian` 设置 ``/etc/apt/apt.conf.d/70debconf`` / :ref:`raspberry_pi_os` 设置 ``/etc/apt/apt.conf.d/50raspi`` (其实配置目录下任何文件应该都可以) 添加 :ref:`apt` 代理配置:

.. literalinclude:: ../../container/colima/colima_proxy_archive/apt_proxy
   :caption: 在 apt 配置中添加代理设置

HOST物理服务器全局配置代理
==============================

- 修订 ``/etc/environment`` 添加代理配置(该配置对HOST物理服务器上 :ref:`curl_proxy` 以及大多数符合Linux代理规范的应用起作用):

.. literalinclude:: ../../container/colima/colima_proxy/environment
   :caption: ``/etc/environment`` 设置代理环境变量

- 登陆系统使上述代理环境变量生效

:ref:`docker` 客户端(容器内部)代理
========================================

- 我在 :ref:`install_docker_linux` 都是采用普通用户账号(如 ``admin`` )允许直接运行docker，所以，在这个 ``admin`` 管理账号登陆下配置 ``~/.docker/config.json`` :

.. literalinclude:: docker_proxy_quickstart/config.json
   :caption: 配置HOST物理服务器 ``admin`` 用户(管理docker)客户端使用代理 ``~/.docker/config.json``
   :emphasize-lines: 6,7

.. note::

   在 ``config.json`` 中配置的环境变量将在Docker容器启动时自动注入容器内部，实际生效是在容器内部生效

   **一定要** 配置为 ``172.17.0.1`` ，这个地址对应前述 :ref:`ssh_tunneling` 端口映射绑定Docker NAT网关的地址

.. warning::

   错误配置容器内部的代理服务器，会导致非常异常的容器无响应问题。例如，我错误配置 ``127.0.0.1:3128`` 作为注入地址，在 :ref:`install_docker_raspberry_pi_os` 遇到 :ref:`debian_tini_image` 执行 ``RUN apt install tini`` 出现找不到软件包，导致 ``docker build`` 失败，并且使用简化的Dockerfile构建的容器运行时，容器内部执行任何命令都会无响应。

HOST物理服务器 :ref:`docker` 服务端代理
=========================================

在HOST物理服务器上执行以下两个步骤分别设置 :ref:`docker` 控制服务代理 和 :ref:`containerd` 运行时服务代理

:ref:`docker` 控制服务代理
---------------------------

- 执行以下脚本为docker服务添加代理配置:

.. literalinclude:: docker_proxy/create_http_proxy_conf_for_docker
   :language: bash
   :caption: 生成 /etc/systemd/system/docker.service.d/http-proxy.conf 为docker服务添加代理配置
   :emphasize-lines: 7-9

:ref:`containerd` 运行时服务代理
----------------------------------

- 执行以下脚本为containerd服务添加代理配置:

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/containerd_proxy/create_http_proxy_conf_for_containerd
   :language: bash
   :caption: 生成 /etc/systemd/system/containerd.service.d/http-proxy.conf 为containerd添加代理配置
   :emphasize-lines: 7-9

现在
======

现在可以执行 :ref:`debian_tini_image` 来验证代理是否正确工作
