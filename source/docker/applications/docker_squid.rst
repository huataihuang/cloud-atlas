.. _docker_squid:

========================
Docker环境运行Squid
========================

Ubuntu的母公司Canonical在dockerhub官方维护了一个基于 Ubuntu LTS 的squid镜像 `ubuntu/squid Docker Image <https://hub.docker.com/r/ubuntu/squid>`_ ，并提供了长期安全维护。本文作为 :ref:`k8s_deploy_squid_startup` 的前奏，在本地docker环境运行 :ref:`squid` 测试。

准备工作
===========

- 准备物理主机上的squid缓存和日志目录，这样docker容器挂载卷可以加速IO性能，也能够保证缓存数据和日志不丢失:

.. literalinclude:: docker_squid/docker_squid_volume
   :language: bash
   :caption: 在物理主机创建squid容器的卷

- 准备配置文件 :ref:`squid_startup` :

.. literalinclude:: ../../web/proxy/squid/squid_startup/squid.conf
   :language: bash
   :caption: fedora默认初始squid配置: /etc/squid/squid.conf

运行
========

- 执行运行命令:

.. literalinclude:: docker_squid/docker_run_squid
   :language: bash
   :caption: docker run运行squid容器，注意我配置了绑定 "kind" 虚拟交换机以便给集群代理服务
   :emphasize-lines: 2

.. csv-table:: ubuntu/squid镜像参数
   :file: docker_squid/docker_squid_parameter.csv
   :widths: 80,20
   :header-rows: 1

后期配置
==========

参考 :ref:`fix_kind_restart_fail` 相似方法，设置 ``squid`` 容器固定IP地址:

- 首先获取docker容器的所有IP地址:

.. literalinclude:: ../../kubernetes/kind/fix_kind_restart_fail/get_docker_container_ip
   :language: bash
   :caption: 获取docker容器的IP地址

- 执行以下命令将 ``squid`` 容器的IP地址固定为当前动态分配的IP地址::

   docker stop squid
   docker network connect --ip 172.22.0.12 "kind" "squid"
   docker start squid

检查
========

一切运行正常，检查 ``docker ps`` 可以看到::

   CONTAINER ID   IMAGE                                COMMAND                  CREATED         STATUS         PORTS                       NAMES
   cc2e1ee10eba   ubuntu/squid:5.2-22.04_beta          "entrypoint.sh -f /e…"   4 minutes ago   Up 4 minutes   0.0.0.0:3128->3128/tcp      squid

- 检查squid日志::

   docker logs -f squid

- 进入容器内部检查::

   docker exec -it squid /bin/bash

在容器内部可以使用 :ref:`apt` 安装 :ref:`ubuntu_linux` 相关操作系统工具，方便排查一些问题，例如 ``apt install iproute2`` 工具可以帮助检查容器IP地址和路由等

.. note::

   我是在 :ref:`macos_studio` 上运行 Docker Desktop for macOS，测试不能使用本物理主机的系统级代理设置，会导致docker出去的http/https被反向代理回去(似乎)。采用chrome结合SwitchyOmega设置chrome自身代理来进程测试(因为chrome可以不依赖系统代理设置) ，就能够验证squid是否工作正常。

下一步
========

- :ref:`fedora_image` 使用本文部署的 squid Docker 容器进行缓存加速
- :ref:`k8s_deploy_squid_startup`

参考
========

- `ubuntu/squid Docker Image <https://hub.docker.com/r/ubuntu/squid>`_
- `arch linux官方文档 - Squid <https://wiki.archlinux.org/index.php/Squid>`_
- `How to Setup Squid Proxy Docker Container Image <https://cloudinfrastructureservices.co.uk/how-to-setup-squid-proxy-docker-container-image/>`_ 使用 :ref:`docker_compose` 部署 :ref:`squid`
