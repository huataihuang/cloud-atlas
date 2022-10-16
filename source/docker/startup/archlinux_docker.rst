.. _archlinux_docker:

=====================
arch linux运行docker
=====================

在 :ref:`mobile_cloud_infra` 采用 :ref:`asahi_linux` 作为物理主机操作系统。Asahi Linux的核心是 :ref:`arch_linux` ，所以整个部署过程参考Arch Linux进行。

:ref:`install_docker_linux` 概述了常用Linux安装Docker的方法，也包括了 :ref:`arch_linux` 。本文在此基础上进一步探索针对 :ref:`arch_linux` 的技术细节。

安装Docker
===========

- 在Arch Linux上主要有稳定版本 ``docker`` 和开发版本 ``docker-git`` (通过 :ref:`archlinux_aur` 安装) ，通常安装稳定版本即可::

   pacman -S docker

- 激活和启动docker::

   systemctl enable docker
   systemctl start docker

遇到一个问题，启动 docker 服务感觉有点缓慢

- 检查 ``/var/run/docker.sock`` 可以看到 ``docker`` 用户组可以读写，所以将自己的账号(huatai)添加到该用户分组，这样就可以无需sudo操作docker::

   sudo usermod -aG docker $USER


参考
======

- `arch linux: Docker <https://wiki.archlinux.org/title/docker>`_
