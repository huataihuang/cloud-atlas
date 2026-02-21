.. _install_docker_linux:

======================
Linux环境安装Docker
======================

模拟环境的Docker
===================

为了能够在测试环境中不断模拟各种实验，我采用两种模式运行Docker:

- 在KVM虚拟机中运行Docker
  
:ref:`clone_vm` 构建了一个名为 ``dockerstack`` 的KVM虚拟机，在KVM虚拟机内部测试各种Docker的功能。这种方式可以保持Host物理主机纯净，不容易搞坏基础环境。虚拟机可以不断clone重建，即使偶尔失误异常也能快速恢复测试环境。

- 在物理主机MacBook Pro上运行Docker

在MacBook Pro笔记本上，在 :ref:`ceph_docker_in_studio` ，主要原因是获得接近物理主机运行性能，并且轻量级易维护。这种Docker运行基础服务，保持稳定减少折腾。

.. note::

   大多数Docker测试都在 ``dockerstack`` 中完成。

RHEL/CentOS平台安装Docker
===========================

- 通过发行版安装docker::

   sudo yum install docker

- 启动docker服务::

   sudo systemctl start docker

- 设置docker在操作系统启动时启动::

   sudo systemctl enable docker

.. note::

   :ref:`install_docker_centos8` 方法略有不同。

Debian/Ubuntu平台安装Docker
===============================

使用Ubuntu发行版的软件仓库安装Docker
-----------------------------------------

Ubuntu默认发行版本 ``docker.io`` 是可以兼容在Ubuntu主推的LXD系统中，但是版本会较Docker官方低一些。安装非常简便:

.. literalinclude:: install_docker_linux/ubuntu_install
   :caption: 在Ubuntu中安装发行版提供的docker

安装完成后docker服务就已经启动，此时可以使用以下命令查看docker容器::

   docker ps

使用Docker官方提供的Docker CE安装Docker
-----------------------------------------

- Docker官方提供了 `Docker CE for Ubuntu <https://docs.docker.com/install/linux/docker-ce/ubuntu/>`_ ，需要删除掉Ubuntu系统自带 ``docker.io`` 软件之后才可以安装::

   sudo apt-get remove docker docker-engine docker.io

.. note::

   Docker CE on Ubuntu支持 ``overlay2`` 和 ``aufs`` 存储驱动

- 设置软件仓库::

   sudo apt-get update
   # 设置apt使用HTTPS访问软件仓库
   sudo apt-get install \
       apt-transport-https \
       ca-certificates \
       curl \
       software-properties-common

- 添加Docker官方GPG key::

   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

- 设置Docker官方的 ``stable`` 仓库::

   sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

- 安装Docker CE::

   sudo apt-get update
   sudo apt-get install docker-ce

- 验证Docker CE::

   sudo docker run hello-world

Arch Linux安装Docker
=======================

Arch Linux发行版的 ``docker`` 软件包就是Docker CE版本，可以直接安装::

   sudo pacman -S docker

- 安装完成后检查::

   docker info

.. note::

   Docker支持不同的 :ref:`docker_storage_driver` ，不同的存储驱动一个影响到容器镜像的存储层(多个镜像共享存储层)性能。

   ``devicemapper`` 性能较弱，特别在传统磁盘上，所以不建议在生产环境使用 ``devicemapper`` 。

   由于Arch Linux使用了较新的内核，所以不需要使用兼容选线，通常的较好选项是 ``overlay2`` 。

.. note::

   使用 ``docker info`` 可以看到存储驱动类型，例如::

       Storage Driver: overlay2
         Backing Filesystem: extfs
         Supports d_type: true
         Native Overlay Diff: false

.. note::

   注意，这里 ``storage driver`` 不是Docker用于数据持久化存储的 :ref:`docker_volume` ，而是用于存储容器镜像的层次型文件系统。

   我在 :ref:`ubuntu_linux` 上采用 :ref:`docker_btrfs_driver` (虽然现在我更倾向于生产环境使用XFS) ；在 :ref:`arch_linux` 我采用 :ref:`lvm_xfs_in_studio` 文件系统，所以对应Docker的storage driver是 :ref:`docker_overlay_driver` 。

使用Docker官方脚本安装Docker-CE
==================================

- Docker官方提供了便捷的官方安装脚本快速安装:

.. literalinclude:: install_docker_linux/install_docker_ce_by_script
   :language: bash
   :caption: 使用Docker官方安装脚本安装Docker-CE

.. _run_docker_without_sudo:

无需sudo运行docker
======================

使用 ``docker`` 指令连接docker服务默认是通过sock，所以用户需要有对 ``/var/run/docker.sock`` 读写的权限。

- 检查操作系统中 ``docker.sock`` 文件权限:

.. literalinclude:: install_docker_linux/docker.sock
   :caption: 检查 ``docker.sock`` 的属主
   :emphasize-lines: 2

可以看到 ``/var/run/docker.sock`` 属于 ``docker`` 用户组（ubuntu系统），如果你使用的操作系统不同，可能是其他用户组，如 ``root`` ，则对应加入到相应用户组:

.. literalinclude:: install_docker_linux/usermod
   :caption: 将当前用户添加到 ``docker`` 用户组

.. note::

   注意修订用户组之后需要用户退出重新登录才能生效，如果ssh远程访问并且使用了 :ref:`ssh_multiplexing` ，则需要kill掉本地ssh客户端连接重新登录才行

快速起步
===========

当你安装完docker运行环境，我们就可以开始快速 :ref:`docker_run` ，体验docker神奇的魔力。当然，如果你使用的操纵系统比较特殊，例如macOS，或者你使用了最新的CentOS 8操作系统，请参考对应环境的安装:

- :ref:`install_docker_macos`
- :ref:`install_docker_centos8`

参考
======

- `Get Docker CE for Ubuntu <https://docs.docker.com/install/linux/docker-ce/ubuntu/>`_
- `How To Install Docker on Ubuntu 16.04 <https://medium.com/@Grigorkh/how-to-install-docker-on-ubuntu-16-04-3f509070d29c>`_
- `Docker Engine on Ubuntu <https://www.ubuntu.com/containers/docker-ubuntu>`_ - Ubuntu主推LXC容器(LXD)，不过也同时支持Docker Engine
