.. _systemd-nspawn:

=====================
systemd-nspawn
=====================

``systemd-nspawn`` 是一个容器管理器，可以在一个目录结构中运行一个完整操作系统或命令，类似于 ``chroot`` 但是提供了更多安全性。例如， ``chroot`` 只提供了文件系统隔离，但是没有提供 :ref:`cgroup` 和 ``namespaces`` 。

当创建容器是， ``systemd-nspawn`` 需要一个root文件系统以及可以选的 JSON 容器配置文件，这个文件提供了一个 OCI runtime bundle 。 ``systemd-nspawn`` 是一个完全OCI兼容实现，就像类似于 :ref:`runc`

安装
========

- 在 :ref:`ubuntu_linux` 系统中可以通过如下方式安装 ``systemd-nspawn`` (包含在 ``systemd-container`` 默认已经安装):

.. literalinclude:: systemd-nspawn/install_systemd-container
   :caption: 安装 ``systemd-container`` 获得 ``systemd-nspawn``

配置
========

``systemd-nspawn`` 容器管理器默认会在以下目录查找配置::

   /etc/systemd/nspawn/
   /run/systemd/nspawn/
   /var/lib/machines/

需要持久化的配置需要存储在 ``/etc/systemd/nspawn/`` 目录

实践
=====

我在 :ref:`android_build_env_ubuntu` 参考 `How to build LineageOS inside a container <https://dzx.fr/blog/how-to-build-lineageos-inside-a-container/>`_ 发现 ``systemd-nspawn`` 结合 :ref:`debootstrap` 是一个非常轻量级的容器化运行 :ref:`ubuntu_linux` 的方案

- 执行容器启动:

.. literalinclude:: systemd-nspawn/systemd-nspawn_ubuntu-dev
   :language: bash
   :caption: 执行 ``systemd-nspawn`` 启动 ``ubuntu-dev`` 容器

实际为了方便编译，独立出android和ccache目录:

- 在 :ref:`zfs_startup_zcloud` 基础上 (已经构建了 ``zpool-data`` 的 zpool) 创建独立的卷:

.. literalinclude:: systemd-nspawn/zfs
   :caption: 在zfs上创建独立的子卷用于 ``android`` 和 ``ccache``

.. literalinclude:: systemd-nspawn/systemd-nspawn_ubuntu-dev_android_ccache
   :language: bash
   :caption: 执行 ``systemd-nspawn`` 启动 ``ubuntu-dev`` 容器(提供独立android和ccache目录)

- 此时位于容器内部，执行 ``df -h`` 检查可以看到如下挂载目录:

.. literalinclude:: systemd-nspawn/systemd-nspawn_ubuntu-dev_df_output
   :caption: 进入容器内部后检查磁盘卷挂载
   :emphasize-lines: 12-14

.. note::

   ``debootstrap`` 和 ubuntu 的docker容器镜像一样，默认只启用了 ``main`` 仓库，要访问安装所有依赖软件包，例如 :ref:`android_build_env_ubuntu` ，需要添加 ``jammy-updates`` 和 ``jammy-security`` 仓库以及 ``universe`` 分支

参考
======

- `archlinux: systemd-nspawn <https://wiki.archlinux.org/title/Systemd-nspawn>`_
- `On Running systemd-nspawn Containers <https://benjamintoll.com/2022/02/04/on-running-systemd-nspawn-containers/>`_
- `systemd-nspawn — Spawn a command or OS in a light-weight container <https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html>`_
- `How to build LineageOS inside a container <https://dzx.fr/blog/how-to-build-lineageos-inside-a-container/>`_
