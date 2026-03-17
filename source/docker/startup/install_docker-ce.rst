.. _install_docker-ce:

==============================
安装Docker Engine(docker-ce)
==============================

Docker Engine是Docker官方维护的软件包版本呢，比Unbutu维护的社区包通常更新，而且包含了现代的 :ref:`docker_compose` 插件命令。如果你只是单纯使用docker，或者结合 :ref:`kubernetes` 使用docker引擎，那么安装Ubuntu社区版本通常已经满足要求。不过，对于个人开发者，为了能够在单机上运行类似 :ref:`kubernetes` 的简单调度系统，使用Docker compose能够简化运维，专注于开发工作。

虽然继续使用Ubuntu社区维护的 ``docker.io`` 软件包也能够通过下载二进制文件来安装旧版的 ``docker-compose`` ，但是官方版 ``docker-ce`` 安装能够直接使用:

- ``docker compose`` 新版Go语言便携，集成在docker命令中
- ``docker buildx`` 用于构建多架构镜像，对于 :ref:`amd_gpu` / :ref:`nvidia_gpu` 异构环境很有用

安装
========

- 安装之前，需要先清理系统已经安装的docker.io:

.. literalinclude:: install_docker-ce/remove_docker.io
   :caption: 卸载docker.io

- 清理掉之前 ``docker.io`` 的目录(可选):

.. literalinclude:: install_docker-ce/rm_dir
   :caption: 清理残留目录

- 设置Docker官方apt仓库:

.. literalinclude:: install_docker-ce/apt_repo
   :caption: 设置Docker apt仓库

- 安装Docker软件包

.. literalinclude:: install_docker-ce/apt_install
   :caption: 安装Docker官方软件包

- 启动docker服务:

.. literalinclude:: install_docker-ce/start_docker
   :caption: 启动docker服务

或者采用重启方式(如果修改过docker配置):

.. literalinclude:: install_docker-ce/restart_docker
   :caption: 重新启动docker服务

- 将当前用户加入 ``docker`` 组，这样后续就无需 ``sudo`` 就可以管理

.. literalinclude:: install_docker_linux/usermod                                                                 
   :caption: 将当前用户添加到 ``docker`` 用户组 

参考
======

- `Install Docker Engine on Ubuntu <https://docs.docker.com/engine/install/ubuntu/>`_
