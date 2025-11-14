.. _alpine_install_pi_5:

===========================
树莓派5安装Alpine Linux
===========================

之前已经实践过 :ref:`alpine_install_pi` 以及 :ref:`alpine_install_pi_1` ，现在规划是在3台 :ref:`pi_5` 上安装最小化的Alpine Linux，以提供轻量级的底座。在这个基础上，进一步构建 :ref:`k3s` 集群；同时逐步将 :ref:`pi_4` 和 :ref:`pi_3` 的底层系统也推平为Alpine Linux，尽可能将硬件资源用于应用。

如 :ref:`alpine_install_pi` 实践，我准备采用: `alpine-rpi-3.22.2-aarch64.tar.gz <https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/aarch64/alpine-rpi-3.22.2-aarch64.tar.gz>`_ 来部署:

- 可以在存储上自由划分2个分区，以便将剩余空间(2个分区之外)保留给 :ref:`ceph`
- 保留空间采用 :ref:`zfs` 构建容器存储，来运行 :ref:`pgsql` 提供 :ref:`k3s` 管控数据库支持以及 :ref:`gitlab` 的数据库运行

安装规划
============

我一共有3套支持64位ARM系统的树莓派，分别是:

- :ref:`pi_3` : 安装Alpine Linux，以确保在最小化环境下能够运行 :ref:`k3s` 管控平面组件
- :ref:`pi_4` : 安装 :ref:`raspberry_pi_os` 以保留 ``glibc`` 运行环境，能够运行需要 ``glibc`` 支持的应用
- :ref:`pi_5` : 安装Alpine Linux，挑战在有限的硬件环境运行 :ref:`ceph` + :ref:`pgsql` + :ref:`gitlab` 完整的应用堆栈，并支持基本的 :ref:`k3s` 运行


