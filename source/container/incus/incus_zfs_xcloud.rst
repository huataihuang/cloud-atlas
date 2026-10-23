.. _incus_zfs_xcloud:

==============================
Incus使用ZFS作为存储(xcloud)
==============================

由于我重新在 :ref:`nasse_c246` 组装机重新安装了 :ref:`ubuntu_linux` 26.04 LTS，重新部署Incus。这个主机上单独使用一块 :ref:`kioxia_exceria_g2` ，所以准备完整构建一个ZFS系统提供给Incus使用。主机 ``xcloud`` 部署如下:

- 首先使用 :ref:`parted` 对磁盘进行分区(抹除原分区，创建一个全新的GPT分区)

.. literalinclude:: incus_zfs_xcloud/parted
   :caption: 使用 ``parted`` 重建分区

此时该磁盘 **数据被抹除** ，将重新开始ZFS部署

- 安装 ``zfsutils-linux`` :

.. literalinclude:: ../../linux/storage/zfs/install/ubuntu_zfs/install_zfsutils
   :caption: 在Ubuntu环境安装 ``zfsutils-linux``

- 为Incus配置zpool:

.. literalinclude:: incus_zfs_xcloud/incus-zpool
   :caption: 创建  ``incus-zpool``

参数要点见 :ref:`incus_zfs`

- 执行Incus初始化:

.. literalinclude:: incus_zfs_xcloud/incus_admin_init
   :caption: 初始化incus
