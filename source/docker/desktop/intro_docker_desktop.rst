.. _intro_docker_desktop:

=========================
Docker Desktop简介
=========================

`Docker Desktop <https://www.docker.com/products/docker-desktop/>`_ 是Docker公司面向 :ref:`windows` / :ref:`linux` / :ref:`macos` 桌面推出的集成多项开源技术的虚拟机运行docker容器的OneBox技术。也就是说，不需要在Host主机操作系统中安装 :ref:`container_runtimes` 以及各种复杂的软件堆栈，只需要Host主机能够运行虚拟化(通常已经内置)，就可以得到一个完整的已经预先配置的Docker运行环境以及一键安装 :ref:`kubernetes` (简化单机版)。非常适合对底层技术了解不多且专注于应用开发的程序员。

.. note::

   2023年底，我尝试采用开源的 :ref:`colima` 来代替 Docker Desktop，以便能够深入学习:

   - :ref:`lima` 实现在 :ref:`macos` 平台使用 :ref:`apple_virtualization` 构建底层虚拟化
   - 开源的 :ref:`colima` 结合了很多工具可以参考学习

Docker Desktop on Mac vs. Docker Toolbox
=========================================

Docker Toolbox
----------------

早期在Mac OS X上运行Docker实际上是先在OS X上安装运行VirtualBox，然后在VirtualBox中运行一个Linux虚拟机，最后Docker实际上是运行在Linux虚拟机中。而在Mac OS X上执行的 ``docker`` 指令则通过虚拟网络访问远程虚拟机内的Docker服务来实现管理。这种运行模式，在Mac上 ``/usr/local/bin`` 目录下安装了 ``docker`` ， ``docker-compose`` 和 ``docker-machine`` 。Toolbox会使用 ``docker-machine`` 来提供VirtualBox VM，虚拟机命名为 ``default`` ，并运行一个 ``boot2docker`` 的Linux发行版。

在执行 ``docker`` 和 ``docker-compose`` 命令之前，通常已经执行了环境设置命令 ``eval $(docker-machine env default)`` ，这样 ``docker`` 或 ``docker-compose`` 就知道如何与VirtualBox中的Docker Engine通讯。

.. figure:: ../../_static/docker/desktop/toolbox-install.png
   :scale: 50

Docker Desktop on Mac
------------------------

现在推荐采用Docker Desktop on Mac模式来运行Mac-native模式的Docker，也就是安装在 ``/Applications`` 中，实际上是创建了一个完整的application bundle，位于 ``/Applications/Docker.app/Contents/Resources/bin`` 。

Docker Desktop on Mac的关键技术:

- 使用 `Docker HyperKit <https://github.com/docker/HyperKit/>`_ 代替了 VirtualBox。Hyperkit是轻量级的macOS虚拟化解决方案，基于macOS 10.10 Yosemite或更高版本的Hypervisor.framework。
- Docker Desktop不再使用 ``docker-machine`` 来构建VM，而Docker Engine API是直接在Mac主机的 ``/var/run/docker.sock`` 提供socket
  这也是默认的Docker和Docker Compose客户端使用连接到Docker dameon的连接。

.. figure:: ../../_static/docker/desktop/docker-for-mac-install.png
   :scale: 50

.. note::

   现在已经全面使用 Docker Desktop ，当前在 :ref:`apple_silicon_m1_pro` MacBook Pro笔记本上的 macOS 运行Docker Desktop实际上是一个 :ref:`qemu` 虚拟机中 ``qemu-system-aarch64``

