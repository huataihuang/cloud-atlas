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

.. note::

   这里有一个问题，就是在 :ref:`docker_desktop` for mac 容器中运行squid，启用了 ``cache_dir`` 配置之后，squid出现报错::

      2023/01/31 17:03:09| FATAL: Failed to make swap directory /var/cache/squid: (13) Permission denied

   原因看起来是因为 squid 使用了 ``proxy`` 用户账号来运行，一旦需要缓存目录，该目录必须是 ``proxy`` ( ``id=13`` ) 来读写。

   我发现在macOS的host主机，实际目录属主是 ``huatai`` ，但是映射到容器内部后这个目录属主是 ``root`` 

   但是，即使我不映射host的磁盘目录到 ``/var/spool/squid`` 也依然无法在容器中配置squid的 ``cache_dir`` 功能，迷惑

运行
========

- 执行运行命令:

.. literalinclude:: docker_squid/docker_run_squid
   :language: bash
   :caption: docker run运行squid容器，注意取消了 ``--network kind`` 参数(见上文)，采用默认网络

.. csv-table:: ubuntu/squid镜像参数
   :file: docker_squid/docker_squid_parameter.csv
   :widths: 80,20
   :header-rows: 1

后期配置(关键点)
==================

.. note::

   我最初考虑将这个 ``squid`` 容器连接到 :ref:`macos_studio` 构建的 :ref:`kind` 内置的 ``kind`` bridge网络，这样就可以同时为整个 ``dev`` kind 集群提供代理。但是我发现 ``docker build`` 不能指定具体网络( ``docker run`` 可以)，而只能指定网络模式( ``bridge`` 或 ``host`` )，这导致将 ``squid`` 容器运行在 ``kind`` 代理后就不能给默认网路进行代理。

   标准方法，对于 ``kind`` 网络上的 ``node`` 以及 ``conatiner`` 还是采用标准的 :ref:`k8s_deploy_squid_startup` 构建的 ``pod`` ，将Kubernetes化的 :ref:`squid` 来提供 ``kind`` 网络代理加速。

   我想了一下，可以在这个docker化的 ``squid`` 容器中插入多个网络接口，为 docker 所有网络提供代理服务。但是由于每个docker网络的网段不同，分配IP不同，所以配置代理的时候不使用IP地址，而是采用域名解析:

   - 发现Docker的DNS解析也比较复杂，需要研究 :ref:`coredns`
   - 比较简单的方法是将 ``/etc/hosts`` 文件bind到容器内部，这样可以控制容器主机名解析不同网段 ``squid`` 的对应IP

   当然，在 Kubernetes 集群，采用静态 ``/etc/hosts`` 维护繁琐易出错，所以采用 :ref:`coredns` 来构建解析

参考 :ref:`fix_kind_restart_fail` 相似方法，设置 ``squid`` 容器固定IP地址:

- 首先获取docker容器的所有IP地址:

.. literalinclude:: ../../kubernetes/kind/fix_kind_restart_fail/get_docker_container_ip
   :language: bash
   :caption: 获取docker容器的IP地址

- 我尝试以下命令将 ``squid`` 容器的IP地址固定为当前动态分配的IP地址::

   docker stop squid
   docker network connect --ip 172.17.0.3 "bridge" "squid"

但是这里会报错::

   Error response from daemon: user specified IP address is supported on user defined networks only

但是考虑到这个容器 ``squid``` 绑定了 ``0.0.0.0:3128`` ，是否可以作为通用的访问代理呢？类似在 :ref:`kind_local_registry` 通过 ``localhost:5001`` 访问本地的 ``registry`` ，是否可以在容器中通过访问 ``localhost:3128`` 访问代理服务器呢？

**验证不行**

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
- 结合 :ref:`squid_ssl_bumping` 改进squid部署
- :ref:`k8s_deploy_squid_startup`
- :ref:`k8s_deploy_gitlab` (准备从 :ref:`deploy_gitlab_from_source` 学习，再迁移到 :ref:`k8s_deploy_gitlab` )

参考
========

- `ubuntu/squid Docker Image <https://hub.docker.com/r/ubuntu/squid>`_
- `arch linux官方文档 - Squid <https://wiki.archlinux.org/index.php/Squid>`_
- `How to Setup Squid Proxy Docker Container Image <https://cloudinfrastructureservices.co.uk/how-to-setup-squid-proxy-docker-container-image/>`_ 使用 :ref:`docker_compose` 部署 :ref:`squid`
