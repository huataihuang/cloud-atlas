.. _centos_8_replacement:

=========================
CentOS 8已死:选择替代
=========================

我在 :ref:`nerdctl` 尝试部署CentOS 8容器镜像失败，原因是2021年底CentOS 8已经终止更新，已经无法直接使用官方镜像。通过 :ref:`centos_8_convert_stream` 虽然能够继续使用CentOS，但是CentOS Stream滚动更新模式，作为Red Hat Enterprise Linux上游，相对而言稳定性差一些，所以可能需要寻找可行的替代发行版。

目标: 稳定、长期支持基础镜像
=============================

对于熟悉CentOS系统运维的使用者来说，会选择rpm兼容的社区版本。对于在容器运行环境，可选择Docker镜像有:

- `AlmaLinux镜像 <https://hub.docker.com/_/almalinux>`_ 基于CentOS制作的社区版本镜像
- `Oracle Linux镜像 <https://hub.docker.com/_/oraclelinux>`_ 基于RedHat Enterprise Linux的商业化发行版镜像(可以免费使用)
- `RockyLinux镜像 <https://hub.docker.com/_/rockylinux>`_ 由CentOS创始人发起的社区版本

此外，RedHat也提供了自己的免费基础Docker镜像，称为 `Universal Base Image(UBI) <https://developers.redhat.com/products/rhel/ubi>`_

参考
======

- `CentOS 8 is dead: choosing a replacement Docker image <https://pythonspeed.com/articles/centos-8-is-dead/>`_
