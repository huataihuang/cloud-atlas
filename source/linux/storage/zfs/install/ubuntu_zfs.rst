.. _ubuntu_zfs:

===================
Ubuntu上运行ZFS
===================

.. note::

   本文实践是为 :ref:`install_kubeflow_single_command` 准备NFS共享存储，借这个机会来完成ZFS的完整部署和输出服务

准备工作
=============

我在 :ref:`hpe_dl360_gen9` 二手服务器上安装了一块二手的 :ref:`sandisk_cloudspeed_eco_gen_ii_sata_ssd` ，虽然只是单块磁盘，但是可以用来作为测试环境的数据存储。构建全功能的ZFS，实现数据共享给 :ref:`machine_learning` 这样需要NFS的环境。

注意，我的物理服务器 ``zcloud`` 采用了 :ref:`ubuntu_linux` 22.04，可以采用OpenZFS官方仓库安装

安装
=========

在Ubuntu发行版中，ZFS是包含在默认的Linux内核包中，所以不需要像 :ref:`archlinux_zfs` 通过内核编译支持，只需要安装ZFS utilities。

- 配置 ``/etc/apt/sources.lists`` 确保已经激活了 ``universe`` (可能已经激活):

.. literalinclude:: ubuntu_zfs/sources.list
   :caption: 确保 ``/etc/apt/sources.lists`` 已激活 ``universe``
   :emphasize-lines: 3

- 安装 ``zfsutils-linux`` :

.. literalinclude:: ubuntu_zfs/install_zfsutils
   :caption: 在Ubuntu环境安装 ``zfsutils-linux``

So easy。现在我们可以开始配置

参考
======

- `OpenZFS: Getting Started - Ubuntu <https://openzfs.github.io/openzfs-docs/Getting%20Started/Ubuntu/index.html>`_

