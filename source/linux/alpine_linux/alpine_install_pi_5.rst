.. _alpine_install_pi_5:

===========================
树莓派5安装Alpine Linux
===========================

概述
======

Alpine Linux现在已经能够很好支持树莓派，提供了 ``linux-rpi`` 打包的内核，采用树莓派基金会下游补丁以及 ``defconfig`` 文件，即等同 :ref:`raspberry_pi_os` 提供的内核功能。

``linux-firmware`` 软件包则绑定了提供树莓派基金会提供的wifi和蓝牙的firmeware的 ``linux-firmware-brcm`` ，这确保了和树莓派社区提供相同的无线支持。

其他则采用了 Alpine 发行版内 ``generic defconfigs`` 的上游提供的 ``linux-lts`` 通用内核， ``armv7`` 或 ``aarch64`` 实例可能用于相应的树莓派设备。

不过，仍有可能不支持所有的树莓派功能，并且可能需要不同或附加的配置，而且也不能得到支持。

我的实践
===========

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

我之前在 :ref:`alpine_install_pi` 方法沿用，但略有变化:

- 我当前使用的是 :ref:`raspberry_pi_os` ，启动采用了TF卡启动
- :ref:`pi_5` 安装了 :ref:`pi_5_pcie_m.2_ssd` 扩展卡，并且采用了 ``B型`` 支持两个NVMe SSD存储，所以我采用了2个 NVMe SSD:

  - 我最初想采用 :ref:`intel_optane_m10` 用于安装 :ref:`alpine_linux` 操作系统，但是之前反复验证无法作为常规存储启动树莓派，所以放弃这个方案
  - :ref:`kioxia_exceria_g2` 大约 ``1.8TB`` 作为存储

    - 划分32GB作为操作系统分区，安装 :ref:`alpine_linux`
    - 采用 :ref:`xfs` 来构建本地存储，运行性能要求较高的 :ref:`pgsql` 等基础应用(200G)
    - 基于 :ref:`ceph` 分布式存储(3个)，构建容器运行存储，以及可能的 :ref:`kvm` 虚拟化使用的存储环境

安装方法
=============

我是在原先 TF卡 安装并启动 :ref:`raspberry_pi_os` 后再将下载的 :ref:`alpine_linux` 

参考
======

- `Alpine Linux wiki: Raspberry Pi <https://wiki.alpinelinux.org/wiki/Raspberry_Pi>`_
