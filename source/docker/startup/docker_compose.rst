.. _docker_compose:

=================
Docker Compose
=================

Compose是一个定义运行多个容器Docker应用程序，通过Compose，可以使用一个YAML文件来配置应用程序的服务，然后通过一个单一命令，可以根据配置创建和启动所有服务。

.. note::

   有点类似Kubernetes的Pod，可以定义一组容器相互关联。

Compose可以工作在所有环境：production, staging, development, testing, 类似的CI工作流。

使用Compose有3个基本步骤：

- 使用一个 ``Dockerfile`` 定义应用程序环境，这样它能够在任何地方重新运行
- 在 ``docker-compose.yml`` 文件中定义服务来启动app，这样这些应用可以在一个隔离环境中一起运行
- 使用 ``docker-compose up`` 启动和运行完整的应用组合

``docker-compose.yml`` 案例如下::

   version: '3'
   services:
     web:
       build: .
       ports:
       - "5000:5000"
       volumes:
       - .:/code
       - logvolume01:/var/log
       links:
       - redis
     redis:
       image: redis
   volumes:
     logvolume01: {}

安装Docker Compose
===================

Docker Compose依赖Docker Engine工作，所以需要先确保Docker Engine已经在本地或者远程服务器上安装好。

- 在 :ref:`install_docker_macos` Desktop for Mac 或者 for Windows，则Docker Compose已经作为安装的程序组件一起安装了
- 在Linux系统中，首先通过发行版安装 ``docker`` ，然后再按照下面介绍的步骤安装Compose
- 在Linux系统中，可以设置 :ref:`run_docker_without_sudo` Compose

在macOS中安装Compose
----------------------

参考 :ref:`install_docker_macos` 就可以获得Compose

在Linux中安装Compose
----------------------

Linux平台下，需要从 `Compose repository release page on GitHub <https://github.com/docker/compose/releases>`_ 下载安装，使用 ``curl`` 命令::

   sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   
   sudo chmod +x /usr/local/bin/docker-compose

- :ref:`arch_linux` 通过 :ref:`pacman` 可以从仓库安装:

   sudo pacman -S docker-compose

升级Compose
------------

::

   docker-compose migrate-to-labels

卸载Compose
--------------

::

   sudo rm /usr/local/bin/docker-compose

参考
======

- `Overview of Docker Compose <https://docs.docker.com/compose/>`_
- `Install Docker Compose <https://docs.docker.com/compose/install/>`_
