.. _archlinux_docker:

=====================
arch linux运行docker
=====================

在 :ref:`mobile_cloud_infra` 采用 :ref:`asahi_linux` 作为物理主机操作系统。Asahi Linux的核心是 :ref:`arch_linux` ，所以整个部署过程参考Arch Linux进行。

:ref:`install_docker_linux` 概述了常用Linux安装Docker的方法，也包括了 :ref:`arch_linux` 。本文在此基础上进一步探索针对 :ref:`arch_linux` 的技术细节。

安装Docker
===========

- 在Arch Linux上主要有稳定版本 ``docker`` 和开发版本 ``docker-git`` (通过 :ref:`archlinux_aur` 安装) ，通常安装稳定版本即可，步骤包括:

  - :ref:`pacman` 安装docker
  - 并启动和激活docker
  - 将 自己的账号(huatai)添加到该用户分组，这样就可以无需sudo操作docker

.. literalinclude:: archlinux_docker/archlinux_install_docker
   :language: bash
   :caption: 在arch linux上安装稳定版本docker

下一步
========

我为 :ref:`kind` 构建底层docker采用 :ref:`docker_zfs_driver`

参考
======

- `arch linux: Docker <https://wiki.archlinux.org/title/docker>`_
