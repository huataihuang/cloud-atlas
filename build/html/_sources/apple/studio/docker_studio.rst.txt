.. _docker_studio:

=====================
Docker运行Studio容器
=====================

基于Docker构建快速启用的开发环境，结合 github 保存的初始化配置以及脚本，来实现跨平台studio。

Docker镜像
===============

`fedoraproject Dockerfile <https://fedoraproject.org/wiki/Docker#Dockerfiles>`_ 在GitHub上提供的 `fedora-cloud/Fedora-Dockerfiles <https://github.com/fedora-cloud/Fedora-Dockerfiles>`_ 现在已经不在持续开发。不过提供的Dockerfile可以作为参考(实际也不复杂)。

.. note::

   现在Fedora的容器构建都是通过 `containerbuildsystem <https://github.com/containerbuildsystem>`_ 实现的，需要在 :ref:`openshift` 中部署OpenShift Build System(基于koji)实现容器构建。

Fedora项目提供的Dockerfile可以方便我们快速部署不同的运行环境，你可以通过  `fedora-cloud/Fedora-Dockerfiles <https://github.com/fedora-cloud/Fedora-Dockerfiles>`_ git仓库clone，也可以直接安装软件包::

   sudo dnf -y install fedora-dockerfiles
   ls /usr/share/fedora-dockerfiles

- 快速启动::

   cd /usr/share/fedora-dockerfiles/ssh
   docker build -t fedora-ssh .

   docker run --name fedora-ssh --detach -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro fedora-ssh /usr/sbin/init

初始化镜像
==============

- 先部署一个最基础的镜像fedora，验证运行，只包含最小化运行环境：

.. literalinclude:: docker_studio/fedora/Dockerfile
   :language: dockerfile
   :emphasize-lines: 4
   :linenos:
   :caption:

解析:

  - ``ENV container docker`` 提供了容器内环境变量 ``container=docker`` ，容器内运行的 ``systemd`` 需要根据这个环境变量来判断知道自身运行在容器中，才能使得systemd能够在容器中正常运行。

- 构建镜像::

   docker build -t fedora .

.. note::

   上述Dockerfile采用了 ``systemd`` 作为进程管理器，为后续通过容器运行ssh服务提供基础。这个环境是用来作为统一开发环境，所以并没有采用精简的容器运行模式。

   后续作为持续集成，将代码推送到运行容器中，将采用完全原生精简的Dockerfile

- 运行容器::

   docker run --name fedora --detach -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro fedora /usr/sbin/init

.. note::

   这个容器中没有常用的维护工具，所以我们下一步开始自己定制，然后将所有定制命令转换成Dockerfile配置，以便能够复用。

   软件包安装参考 :ref:`init_centos`

ssh服务容器(ssh)
=================

- 由于fedora的容器镜像默认使用了systemd，安装和启动sshd服务非常容易:

.. literalinclude:: docker_studio/ssh/Dockerfile
   :language: dockerfile
   :emphasize-lines: 4
   :linenos:
   :caption:

.. note::

   ssh容器安装了系统工具，方便维护

- 构建带有ssh服务的镜像::

   docker build -t fedora-ssh .

访问虚拟机ssh
-----------------

在macOS上运行的Docker容器实际上是运行在 :ref:`xhyve` 虚拟机中，这个虚拟机所运行的精简Linux操作系统 :ref:`alpine_linux` ，使得在macOS主机上无法直接ssh到容器内部(需要通过虚拟机操作系统转发)。

这是比直接在Linux主机上运行docker容器要麻烦一些(多隔离了一层虚拟机)，不能像Linux主机上，能够直接看到一个NAT网络接口在Linux物理主机(Linux端IP通常是 ``172.17.0.1`` )，这个NAT网络接口现在在 :ref:`xhyve` 虚拟机的Linx系统上，所以如果要实现macOS能够访问到容器，需要做一个端口映射(Port Mapping)。

你可以将这个Port Mapping看成Linux主机的端口映射，将容器内部端口映射到Linux虚拟机对外的网络接口上，由于Linux虚拟机对外网络接口和macOS是互通的，我们就能够通过映射访问到容器::

   网络流量 => Linux虚拟机回环接口Port =端口映射=> 容器内部服务Port

- 我们修订以下运行容器命令，增加 ``-p 222:22`` 把端口从回环地址映射到容器上::

   docker run --name fedora-ssh -p 222:22 --detach -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro fedora-ssh /usr/sbin/init

完成启动后检查::

   docker ps

可以看到::

   CONTAINER ID   IMAGE        COMMAND            CREATED         STATUS         PORTS                                 NAMES
   b8b84a8fd4d9   fedora-ssh   "/usr/sbin/init"   4 minutes ago   Up 4 minutes   0.0.0.0:222->22/tcp, :::222->22/tcp   fedora-ssh

- 新创建容器就是能通过 ``222`` 端口访问到容器::

   ssh admin@127.0.0.1 -p 222

则通过密钥认证可以登陆容器系统

编译开发的软件安装(dev)
=========================

接下来我们在这个 ``fedora-ssh`` 基础上，添加各种常用的开发软件包，以便构成一个非常容易使用的开发环境，预计安装:

- gcc
- automake, autoconf
- openjdk
- python
- go
- swift

.. note::

   swift语言开发包安装参考 :ref:`swift_on_linux`

.. literalinclude:: docker_studio/dev/Dockerfile
   :language: dockerfile
   :linenos:
   :caption:

.. note::

   请注意，当前这个Dockerfile仅仅是安装了开发所需的一些软件包，并没有解决容器销毁以后数据的丢失，这样小心翼翼使用尚可，但是非常容易丢失数据。所以，我们需要通过 :ref:`docker_volume` 把开发环境的数据持久化，并且能够直接输出到物理主机(macOS环境)中，方便我们数据备份和在物理主机上同样共享数据。

容器持久化数据存储(dev-data)
===============================

为了能够在容器销毁并重建等常见操作情况下，不丢失自己辛苦开发工作的数据，我构想了一个方案:

- 在macOS操作系统上配置 :ref:`macos_nfs` ，将用户的 ``$HOME`` 目录下子目录 ``home_admin`` 作为NFS服务卷输出给Docker环境(注意配置内部网络IP访问确保安全)
- 在Docker中配置 :ref:`docker_container_nfs` ，将容器的 ``/home/admin`` 目录bind到NFS挂载的目录下，这样所有容器中数据都能够直接存储到物理主机的macOS系统的用户目录

  - 为了避免多个容器 ``数据踩踏`` ，需要每个容器单独创建一个子目录，分别映射，例如 ``dev1`` 容器使用的是 ``home_admin/dev1`` ； ``dev2`` 容器使用是 ``home_admin/dev2``
  - 如果是公用的数据目录，例如代码仓库，则采用共享的挂在目录

- 在物理主机上采用定时备份同步方法，能够实现数据不丢失



开发环境框架搭建(studio)
=========================

在开发环境中，还有非常重要的部署框架:

- 数据库运行环境 - :ref:`mysql` :ref:`postgresql` ，也通过上述持久化数据存储到物理主机
- web服务 - 构建 :ref:`nginx`
- 开发框架
  - :ref:`django`
  - nodejs相关开发框架

我希望能够快速完成很多我学习和使用的开发环境构建，这块我会不断补充

.. note::

   更为复杂的部署环境，可以集成到一个容器中，也可以分散到不同容器采用 :ref:`kubernetes` 实现，这块将不在studio段落展开，我将构建一个部署到生产环境到持续集成，并且结合:

   - 负载均衡
   - 反向代理
   - 缓存
   - 消息队列

参考
======

- `Docker+VSCode配置属于自己的炼丹炉 <https://zhuanlan.zhihu.com/p/102385239>`_
- `Fedora Container <https://www.dogtagpki.org/wiki/Fedora_Container>`_
- `Fedora Docker Official Images <https://hub.docker.com/_/fedora/>`_
- `Networking features in Docker Desktop for Mac <https://docs.docker.com/docker-for-mac/networking/>`_
