.. _gentoo_docker:

===================
Gentoo Docker
===================

:ref:`docker` 作为容器化运行环境，可以方便开发和部署，并且由于不是 :ref:`kvm` 这样的完全虚拟化，直接使用了物理主机 :ref:`kernel` ，能够获得轻量级和高性能的优势。

.. note::

   我的Docker存储引擎采用 :ref:`docker_zfs_driver` ，所以部署会在 :ref:`gentoo_zfs` 完成之后进行

内核
======

.. note::

   我准备重新实践一次 :ref:`gentoo_mbp_kernel` 来构建使用容器化运行的内核(兼顾虚拟化)。目前实践采用通用内核

.. literalinclude:: gentoo_docker/docker_kernel
   :caption: 运行Docker的内核支持配置

- 检查兼容性: Docker提供了一个内核配置兼容性检查工具:

.. literalinclude:: gentoo_docker/docker_check_kernel
   :caption: Docker提供了一个检查内核配置兼容性工具

安装
=======

- 安装docker和docker-cli:

.. literalinclude:: gentoo_docker/install_docker
   :caption: 安装docker和docker-cli

配置
========

在 ``/etc/docker/daemon.json`` 配置 docker 服务使用 :ref:`docker_zfs_driver` :

.. literalinclude:: ../../docker/storage/docker_zfs_driver/docker_daemon_zfs.json
   :language: json
   :caption: /etc/docker/daemon.json 添加ZFS存储引擎配置

.. warning::

   我实际没有配置这个 ``/etc/docker/daemon.json`` 而是使用下文 OpenRC 配置参数文件 ``/etc/conf.d/docker``

服务
========

OpenRC
--------

OpenRC可以使用 ``DOCKER_OPTS`` 变量来设置docker的存储引擎以及docker引擎的根目录，这里举例配置成使用 :ref:`docker_btrfs_driver` 以及设置docker引擎的根目录为 ``/srv/vsr/lib/docker`` (不过我实际配置的是 :ref:`docker_zfs_driver` ):

.. literalinclude:: gentoo_docker/openrc_docker
   :caption: 配置 ``/etc/conf.d/docker`` 可以设置 OpenRC 的docker运行参数，这里案例是 :ref:`docker_btrfs_driver`

我的实际配置: :ref:`docker_zfs_driver`

.. literalinclude:: gentoo_docker/openrc_docker_zfs
   :caption: 配置 ``/etc/conf.d/docker`` 可以设置 OpenRC 的docker运行参数: :ref:`docker_zfs_driver`

- 启动docker服务(可选启动registry):

.. literalinclude:: gentoo_docker/openrc_docker_start
   :caption: ``openrc`` 启动docker
   :emphasize-lines: 2,3

Systemd
------------

如果使用 :ref:`systemd` 则使用如下命令启动Docker服务:

.. literalinclude:: gentoo_docker/systemd_start_docker
   :caption: ：:ref:`systemd` 中启动docker

权限
==========

- 将希望直接使用docker的用户加入 ``docker`` 分组，例如这里加上我自己 ``huatai`` :

.. literalinclude:: gentoo_docker/docker_add_user
   :caption: 将直接使用docker的用户加入 ``docker`` 分组

存储引擎
============

上面配置了 :ref:`zfs` 作为Docker的存储引擎，所以执行 ``docker info`` 可以看到 :ref:`docker_zfs_driver` 相关信息:

.. literalinclude:: gentoo_docker/docker_info
   :caption: 执行 ``docker info`` 可以看到 :ref:`docker_zfs_driver` 相关信息
   :emphasize-lines: 13-20

网络
=========

需要启用网络的 IP 转发功能，这样才能实现网络的端口转发:

- 临时启用 IP 转发功能:

.. literalinclude:: gentoo_docker/sysctl_ip_forward
   :caption: 临时启用 ``ip_forward``

- 配置操作系统启动时激活 IP 转发:

.. literalinclude:: gentoo_docker/sysctl_local.conf
   :caption: 配置sysctl的启动参数允许IP转发 配置文件 ``/etc/sysctl.d/local.conf``

镜像
========

在完成了上述主机配置之后，就可以继续执行 :ref:`gentoo_image` 

但是，我在后续容器内部 :ref:`upgrade_gentoo` 时遇到了 ``glibc`` 升级错误:

.. literalinclude:: gentoo_docker/glibc_ia32_error
   :caption: 由于物理主机内核没有配置32位兼容，导致Gentoo Linux镜像中glibc无法升级的报错
   :emphasize-lines: 2,9

实际上，我在 :ref:`install_gentoo_on_mbp` 特别采用了纯64位系统，所以内核配置去除了32位兼容。而Gentoo Linux官方提供的镜像默认是采用 ``multilib glibc`` ，需要32位内核兼容。

切换 multilib 和 no-multilib 是一个折腾的操作

参考
======

- `gentoo linux wiki: Docker <https://wiki.gentoo.org/wiki/Docker>`_
