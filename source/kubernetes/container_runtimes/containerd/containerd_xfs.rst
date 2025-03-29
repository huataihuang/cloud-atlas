.. _containerd_xfs:

==========================
containerd存储xfs文件系统
==========================

在 :ref:`priv_cloud_infra` 部署 :ref:`z-k8s` 最初选择 ``docker`` 作为运行时，并且采用了 :ref:`docker_btrfs_driver` 。但是，随着Kubernetes版本升级，从 1.24 开始已经不再建议采用Docker，而是采用 ``containerd`` 运行时。不过，由于 :ref:`containerd_btrfs` 还存在稳定性疑问，所以我在卸载了 ``docker`` 改为 :ref:`install_containerd_official_binaries` ，然后把之前 :ref:`btrfs` 存储卷删除，替换为 :ref:`xfs` 。

卸载和清理 :ref:`docker_btrfs_driver`
======================================

- 当前在 :ref:`priv_cloud_infra` 上安装的 ``docker`` 清理:

.. literalinclude:: containerd_xfs/uninstall_docker
   :language: bash
   :caption: 卸载docker.io

- 卸载 :ref:`docker_btrfs_driver` 挂载的 :ref:`btrfs` 并将磁盘重新格式化成 :ref:`xfs` :

.. literalinclude:: containerd_xfs/convert_btrfs_to_xfs
   :language: bash
   :caption: 将btrfs磁盘转换成xfs

.. note::

   :ref:`xfs_startup` 配置案例，在参考 `Docker installation on RHEL 7.2 and file system requirement <https://serverfault.com/questions/1029785/docker-installation-on-rhel-7-2-and-file-system-requirement/1029872#1029872>`_ 可以看到引用了Docker官方 `Use the OverlayFS storage driver <https://docs.docker.com/storage/storagedriver/overlayfs-driver/>`_ ，要求 XFS 文件系统格式化时使用 ``-n ftype=1`` 参数。


