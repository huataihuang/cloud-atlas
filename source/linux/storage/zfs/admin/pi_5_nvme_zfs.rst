.. _pi_5_nvme_zfs:

========================
树莓派5 NVMe存储ZFS
========================

.. _pi_5_nvme_zfs_prepare:

树莓派5 NVMe存储ZFS磁盘准备
================================

我在 :ref:`pi_soft_storage_cluster` 方案中采用了3台 :ref:`pi_5` ，每台 :ref:`pi_5` 配置了一个 :ref:`kioxia_exceria_g2` ``2TB`` 规格存储，按照 :ref:`pi_soft_storage_cluster` 规划划分磁盘:

.. csv-table:: 树莓派5模拟集群NVMe存储分区
   :file: ../../../../raspberry_pi/pi_cluster/pi_soft_storage_cluster/parted.csv
   :widths: 5, 15, 20, 30, 30
   :header-rows: 1

- 使用 ``fdisk`` 对当前磁盘分区进行检查，可以看到目前只有 :ref:`raspberry_pi_os` 使用的2个分区(之所以使用 ``fdisk`` 而没有使用 :ref:`parted` 是因为 ``fdisk`` 默认使用 ``MiB/GiB/TiB`` 来计算容量，也就是 ``1024`` 为 **1k** 计算；而 :ref:`parted` 默认使用 ``MB/GB/TB`` 计算容量，即以 ``1000`` 为 **1k** 计算。我纯粹是为了更贴近程序员习惯，轻度强迫症):

.. literalinclude:: pi_5_nvme_zfs/fdisk_print
   :caption: ``fdisk -l`` 显示当前分区信息

.. literalinclude:: pi_5_nvme_zfs/fdisk_print_output
   :caption: 可以看到当前分区
   :emphasize-lines: 10,11

Docker处理
============

我的实践案例在这里有一个插入步骤，是因为我已经在 :ref:`install_docker_raspberry_pi_os` ，所以需要先备份导出镜像，然后停止docker，移除 ``/var/lib/docker`` 目录。这样能够为后续 :ref:`docker_zfs_driver` 腾出 ``zpool`` 挂载目录。

:ref:`transfer_docker_image_without_registry` 步骤一: 备份
------------------------------------------------------------

我后续准备 :ref:`k8s_deploy_registry` ，所以当前Docker环境没有部署镜像仓库。这种情况下，切换 :ref:`docker_zfs_driver` 要保障镜像和容器能够恢复，需要使用 :ref:`transfer_docker_image_without_registry` :

.. literalinclude:: pi_5_nvme_zfs/docker_image_save
   :caption: 导出docker中需要保存的容器镜像

docker挂载分区卸载
--------------------

- 停止Docker:

 .. literalinclude:: ../../../../docker/storage/docker_zfs_driver/systemctl_stop_docker
    :language: bash
    :caption: 停止Docker服务，为存储驱动修改做准备

- 将 ``/var/lib/docker`` 备份并清理该目录下所有内容:

.. literalinclude:: ../../../../docker/storage/docker_zfs_driver/backup_docker_dir
   :language: bash
   :caption: 备份/var/lib/docker目录

.. note::

   切换 :ref:`docker_zfs_driver` 后实际镜像数据需要通过类似 :ref:`transfer_docker_image_without_registry` 进行备份和恢复

磁盘分区
------------

.. warning::

   我再次强调一下:

   为了节约磁盘，只在我的 :ref:`pi_soft_storage_cluster` 构建了一个 ``zpool-data`` 存储池，提供给 :ref:`docker` / :ref:`kvm` 以及本地数据存储。这个存储磁盘划分是基于以前的实践 :ref:`gentoo_zfs_xcloud`

.. note::

   有一点强迫症: 为了能够完整分出 ``1 TiB`` 分区，我使用了 ``fdisk`` 来处理磁盘(我暂时不知道如何在 :ref;`parted` 中精确划分出 ``1024 GiB`` 这样的空间)

.. literalinclude:: pi_5_nvme_zfs/fdisk
   :caption: ``fdisk`` 磁盘分区，为 :ref:`ceph` 和 :ref:`zfs` 分别准备分区
   :emphasize-lines: 5,13,27,31-34,38,52,56,59-60,64,80

现在再次执行 ``fdisk -l /dev/nvme0n1`` 可以看到增加了2个分区:

.. literalinclude:: pi_5_nvme_zfs/fdisk_output_4
   :caption: ``fdisk`` 检查可以看到增加了2个分区，分别用于 :ref:`ceph` 和 :ref:`zfs`
   :emphasize-lines: 12,13

- 使用 :ref:`parted` 检查是否满足 :ref:`4k_alignment` :

.. literalinclude:: pi_5_nvme_zfs/parted_align-check
   :caption: 检查各个分区是否4k对齐

输出显示每个分区都已经实现对齐( ``aligned`` ):

.. literalinclude:: pi_5_nvme_zfs/parted_align-check_output
   :caption: 检查各个分区是否4k对齐

ZFS存储构建
===============

- ZFS存储池和挂载构建非常简单:

.. literalinclude:: pi_5_nvme_zfs/zfs
   :caption: 构建 ``zpool-data`` 存储池并挂载

- 完成后检查 ``df -h`` :

.. literalinclude:: pi_5_nvme_zfs/zfs_df
   :caption: 检查ZFS存储挂载
   :emphasize-lines: 9

设置 :ref:`docker_zfs_driver`
=====================================

- 修改 ``/etc/docker/daemon.json`` 添加zfs配置项(如果该配置文件不存在则创建并添加如下内容):

.. literalinclude:: ../../../../docker/storage/docker_zfs_driver/docker_daemon_zfs.json
   :language: json
   :caption: /etc/docker/daemon.json 添加ZFS存储引擎配置

- 启动Docker并检查Docker配置:

.. literalinclude:: ../../../../docker/storage/docker_zfs_driver/start_docker_info
   :language: bash
   :caption: 启动Docker并检查 docker info

``docker info`` 输出显示如下:

.. literalinclude:: pi_5_nvme_zfs/docker_info
   :caption: ``docker info`` 输出
   :emphasize-lines: 20-27

``docker info`` 警告 **解决方法** :ref:`docker_post_install_quickstart`

:ref:`transfer_docker_image_without_registry` 步骤二: 恢复
============================================================

- 备份的镜像复制到需要恢复的主机上进行加载

.. literalinclude:: pi_5_nvme_zfs/docker_image_load
   :caption: 加载保存的容器镜像

- 恢复容器运行:

.. literalinclude:: ../../../../container/colima/images/debian_tini_image/dev/run_acloud-dev_container
   :language: bash
   :caption: 运行包含开发环境的ARM环境debian镜像
