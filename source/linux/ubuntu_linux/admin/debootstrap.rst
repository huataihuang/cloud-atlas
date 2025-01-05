.. _debootstrap:

==================
debootstrap
==================

``debootstrap`` 是一个在已经安装的操作系统中，使用某个子目录来安装Debian基础系统的工具。 ``debootstrap`` 工具不需要安装光盘，只需要一个Debian仓库。 ``debootstrap`` 工具是跨发行版的工具，可以在 :ref:`arch_linux` 或者 :ref:`gentoo_linux` 系统中运行Debian，也可以用来创建不同架构的 ``rootfs`` 系统(称为 ``cross-debootstrapping`` )。

``debootstrap`` 可以用来取代 ``chroot`` ，提供更为方便便捷的部署容器方式。而且，结合 :ref:`systemd-nspawn` 可以非常容易运行一个轻量级容器，方便进行测试或者部署CI/CD构建系统。

- 我在 ``zcloud`` 服务器上使用 :ref:`btrfs` 来提供 :ref:`docker_btrfs_driver` ，所以这里借用 ``/var/lib/docker`` 这个Btrfs存储痴来构建子卷:

.. literalinclude:: ../../storage/btrfs/btrfs_subvolume/ubuntu-dev
   :language: bash
   :caption: 创建 btrfs subvolume ``ubuntu-dev``

- 使用 ``debootstrap`` 构建容器子系统:

.. literalinclude:: debootstrap/debootstrap_jammy
   :language: bash
   :caption: 使用 ``debootstrap`` 构建 Ubuntu 22.04 (代码名 ``jammy`` )

.. note::

   ``debootstrap`` 可以用来构建 ``debian`` 系的子系统，既包括 ``debian`` 也包括 ``ubuntu`` 

参考
=====

- `Debian Wiki: Debootstrap <https://wiki.debian.org/Debootstrap>`_
