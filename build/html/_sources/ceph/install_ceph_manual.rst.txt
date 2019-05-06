.. _install_ceph_manual:

=========================
手工安装Ceph
=========================

.. note::

   本文实践是在 :ref:`ceph_docker_in_studio` 环境实现Ceph集群，提供基础存储给 :ref:`openstack` 作为模拟集群部署。共有5个模拟节点，本文部署过程将先使用3个节点构建，后续再通过添加节点和删除节点方式来模拟故障切换::

      172.18.0.11 ceph-1
      172.18.0.12 ceph-2
      172.18.0.13 ceph-3
      172.18.0.14 ceph-4
      172.18.0.15 ceph-5

   Docker容器中运行的OS是Ubuntu 18.04，所以本实践笔记和官方安装手册有所不同，侧重于在Docker容器的Ubuntu环境中部署，今后有机会可能还会在CentOS系统中部署。本文略去了CentOS的安装介绍。

获取Ceph软件
=============

最简易获取软件的方法还是采用发行版的软件仓库，例如 ``apt`` (Debian/Ubuntu) 或 ``yum`` (RHEL/CentOS) ，如果使用非 ``deb`` 或 ``rpm`` 的软件包管理，则可以使用官方提供的tar包安装二进制可执行程序。

.. note::

   在多台服务器上同时操作，可以使用 `pssh <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/shell/utilities/pssh.md>`_

- 在主机上安装 ``release.asc`` 密钥::

   wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

.. note::

   需要先安装 ``gnupg`` 才能导入上述 ``release.asc`` 密钥::

      sudo apt -y install gnupg

- 添加软件仓库信息

首先需要找到Ceph包对应的 `CEPH RELEAS <http://docs.ceph.com/docs/master/releases/#>`_ ，则对应仓库信息为

Debian/Ubuntu::

   https://download.ceph.com/debian-{release-name}

例如，我使用最新的Ceph版本 ``nautilus`` 则组合成 ``https://download.ceph.com/debian-nautilus``

然后按照操作系统的版本codename添加配置::

   sudo apt-add-repository 'deb https://download.ceph.com/debian-{release_name}/ {codename} main'
   
例如我使用的 Ubuntu 18.04 系列，可以从配置文件 ``/etc/lsb-release`` 配置中找到对应的版本名字是 ``bionic`` 。所以执行如下命令添加仓库信息::

   sudo apt-add-repository 'deb https://download.ceph.com/debian-nautilus/ bionic main'

.. note::

   在Docker的Ubuntu镜像中没有包含 ``apt-add-repository`` 工具，参考 `apt-add-repository: command not found error in Dockerfile <https://stackoverflow.com/questions/32486779/apt-add-repository-command-not-found-error-in-dockerfile>`_ 使用以下命令安装::

      sudo apt install software-properties-common

安装环境准备
=================

Ceph安装依赖系统软件包如下:

- libaio1
- libsnappy1
- libcurl3
- curl
- libgoogle-perftools4
- google-perftools
- libleveldb1

安装ceph-deploy(可选)
=======================

- 安装 ``ceph-deploy`` 工具::

   sudo apt-get update && sudo apt-get install ceph-deploy

.. note::

   ``ceph-deploy`` 是一个设置或拆除Ceph集群的工具，用于开发、测试和验证项目概念。 ``ceph-deploy`` 可以使用一条命令方便地在多个服务器上安装ceph软件。

安装Ceph存储集群
==================

.. note::

   为了能够完整了解Ceph集群部署过程，本文档没有使用 ``ceph-deploy`` 工具，而是采用手工通过APT包管理工具进行部署。

- 安装Ceph软件包（在每个节点上执行）::

   sudo apt-get update && sudo apt-get install ceph ceph-mds

参考
======

- `Ceph document - Installation (Manual) <http://docs.ceph.com/docs/master/install/>`_
