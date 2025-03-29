.. _btrfs_nfs:

===============
Btrfs NFS
===============

Network File System (NFS)是和底层文件系统无关的的分布式文件系统协议，所以实际上在 :ref:`btrfs` 上构建NFS输出和其他文件系统并没有差异(不像 :ref:`zfs_nfs` 提供了集成的NFS配置方法)。通常仅在发行版安装 NFS 相关的软件包上有一些方法差异，但是实际配置方法几乎一致:

- :ref:`setup_nfs_centos7`
- :ref:`setup_nfs_ubuntu20`
- :ref:`setup_nfs_archlinux`

我在 :ref:`asahi_linux` (基于 :ref:`arch_linux` )上构建NFS输出，提供给 :ref:`mobile_cloud_infra` 的本机模拟运行的 :ref:`kind` 作为 :ref:`k8s_volumes` 的NFS挂载，实现一种 :ref:`kind_run_simple_container`

参考
========

- `Using NFS on Btrfs <https://wiki.tnonline.net/w/Blog/NFS_on_Btrfs>`_
- `arch linux: NFS <https://wiki.archlinux.org/title/NFS>`_
