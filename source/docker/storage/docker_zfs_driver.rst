.. _docker_zfs_driver:

=========================
Docker ZFS 存储驱动
=========================

:ref:`zfs` 是(伟大的)Sun Microsystems创建并在CDDL许可下开源的下一代(超越同时代)文件系统( :ref:`zfs_history` )。在ZFS首次发布就支持众多高级 :ref:`zfs_features` ，并且不断持续开发，已经成为现有本地文件系统中最强大的一种。

Docker使用ZFS的先决条件
=========================

要求:

- Docker需要一个或多个 **专用** 块设备，建议使用固态存储器(SSD)
- Docker所使用的ZFS必须是独立的ZFS文件系统: ``/var/lib/docker/`` 目录是ZFS的zpool存储池
- ``警告`` : 更改 :ref:`docker_storage_driver` 会导致已经创建的任何容器都无法在本地系统访问。所以在执行本文实践前，务必将本地现有镜像保存备份(推送到镜像库)!!!

.. note::

   挂在磁盘参数不需要使用 ``MountFlags=slave`` ，原因是 ``dockerd`` 和 :ref:`containerd` 位于不同的挂载namespace。

部署
=======

- 首先完成 :ref:`zfs_admin_prepare`
- 并完成 :ref:`archlinux_docker`

.. note::

   :ref:`mobile_cloud_x86_zfs` 是我在X86_64 的 Macbook Pro 2013笔记本上部署，分区和挂载略有差异

- 停止Docker:

.. literalinclude:: docker_zfs_driver/systemctl_stop_docker
   :language: bash
   :caption: 停止Docker服务，为存储驱动修改做准备

- 将 ``/var/lib/docker`` 备份并清理该目录下所有内容:

.. literalinclude:: docker_zfs_driver/backup_docker_dir
   :language: bash
   :caption: 备份/var/lib/docker目录

- 在 :ref:`zfs_admin_prepare` 好的分区 ``/dev/nvme0n1p8`` 上构建 ``zpool`` 并挂载到 ``/var/lib/docker/`` 目录(开启 :ref:`zfs_compression` ):

.. literalinclude:: docker_zfs_driver/zpool_create_zpool-docker
   :language: bash
   :caption: zpool create创建名为zpool-docker存储池

- 此时检查zfs存储可以看到上述名为 ``zpool-docker`` 的存储池:

.. literalinclude:: docker_zfs_driver/zfs_list
   :language: bash
   :caption: zfs list检查存储

输出显示如下:

.. literalinclude:: docker_zfs_driver/zfs_list_output
   :language: bash
   :caption: zfs list检查存储显示zpool-docker

- 修改 ``/etc/docker/daemon.json`` 添加zfs配置项(如果该配置文件不存在则创建并添加如下内容):

.. literalinclude:: docker_zfs_driver/docker_daemon_zfs.json
   :language: json
   :caption: /etc/docker/daemon.json 添加ZFS存储引擎配置

- 启动Docker并检查Docker配置:

.. literalinclude:: docker_zfs_driver/start_docker_info
   :language: bash
   :caption: 启动Docker并检查 docker info

``docker info`` 输出显示如下:

.. literalinclude:: docker_zfs_driver/docker_info_output
   :language: bash
   :caption: docker info显示使用了ZFS存储(启用压缩)
   :emphasize-lines: 12-19

.. note::

   这里我遇到一个问题，主机断电后重启zfs没有恢复。解决方法: :ref:`config_zfs_auto_start`

维护
====

- 增加ZFS存储池容量(案例参考)::

   sudo zpool add zpool-docker /dev/xvdh

- 限制容器可写入存储quota(限制每个容器能够占用的写入层容量)，修订 ``/etc/docker/daemon.json`` 配置:

.. literalinclude:: docker_zfs_driver/docker_daemon_zfs_quota.json
   :language: json
   :caption: /etc/docker/daemon.json 配置ZFS存储引擎允许容器写入层大小

``zfs`` 存储驱动工作原理
==============================

待续...

参考
======

- `Use the ZFS storage driver <https://docs.docker.com/storage/storagedriver/zfs-driver/>`_
