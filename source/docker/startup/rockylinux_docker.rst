.. _rockylinux_docker:

=============================
Rocky Linux 环境运行Docker
=============================

Rocky Linux作为CentOS的后继者，部署 Docker Engine 方法和 :ref:`install_docker_centos8` 类似。我的实践环境是阿里云的Rocky Linux 9.4，目标如下:

- 在云计算厂商的云服务器(虚拟机)使用最基本的操作系统，通过Docker容器化运行一个远程开发环境，方便我在任何时间任何地点都能够远程移动进行开发学习
- 通过容器化部署来实现一些服务部署，逐步逐步开始落实 :ref:`real` 中曾经设想过得方案

.. note::

   对于数字游牧，，一个一致都随时可用都工作环境非常重要。我的工作中使用了非常多的不同二手设备，所以我一直在探索如何能够达到远程和本地、租用VPS和自建服务器的性能和经济性平衡。

添加Docker仓库
================

- 使用 :ref:`dnf`  工具在Rocky Linux系统中添加Docker软件仓库:

.. literalinclude:: rockylinux_docker/add_docker_repo
   :caption: 添加Docker软件仓库

- 执行以下命令安装最新版本的 Docker Engine, :ref:`containerd` 以及Docker Compose:

.. literalinclude:: rockylinux_docker/install_docker
   :caption: 安装docker相关软件

对于中国大陆用户， ``不出意外`` 的 **意外** 会看到如下无法访问 ``*.docker.com`` 报错:

.. literalinclude:: rockylinux_docker/install_docker_err
   :caption: 由于GFW阻塞，安装docker相关软件报错
   :emphasize-lines: 3

请参考 :ref:`colima_proxy` 使用 :ref:`dnf_proxy` :ref:`across_the_great_wall` 。

另外，阿里云提供的rocky linux直接将软件仓库设置为阿里云自己的镜像网站，一旦配置 :ref:`dnf_proxy` 会导致反向访问阿里云仓库过于缓慢甚至无法正常使用的问题，所以需要修订 ``/etc/yum.repos.d`` 目录下的仓库配置，将阿里云相关的 ``baseurl`` 注释掉，恢复默认的 ``mirrorlist`` (以下是 ``rocky.repo`` 配置修改案例:

.. literalinclude:: rockylinux_docker/rocky.repo
   :caption: 修订仓库配置，恢复默认的 ``mirrorlist``
   :emphasize-lines: 3,4

可以通过以下脚本命令批量修改:

.. literalinclude:: rockylinux_docker/fix_repo.sh
   :language: bash
   :caption: 批量修订仓库配置，恢复默认的 ``mirrorlist``

这样使用官方仓库配置(通过mirrorlist找到最匹配仓库服务器)就能够同时满足翻墙访问Docker和RockyLinux仓库的要求了

运行Docker
============

通过 :ref:`systemd` 启动并配置Docker在操作系统启动时启动:

.. literalinclude:: rockylinux_docker/start_docker
   :language: bash
   :caption: 启动docker

(可选)配置非root用户管理docker
==================================

为了方便维护，可以设置非root用户来管理docker，即将该用户账号添加到 ``docker`` 用户组:

.. literalinclude:: rockylinux_docker/docker_user
   :language: bash
   :caption: 设置非root用户管理docker

完成后用户重新登陆，即使是普通用户账号也能够管理docker

下一步
========
 
- 请参考 :ref:`colima_proxy` 排斥代理(解决无法访问docker官方镜像仓库问题)
- 请参考 :ref:`debian_tini_image` 完成镜像制作和容器运行

参考
=======

- `Rocky Linux Documentation: Containers > Docker - Install Engine <https://docs.rockylinux.org/gemstones/containers/docker/>`_
