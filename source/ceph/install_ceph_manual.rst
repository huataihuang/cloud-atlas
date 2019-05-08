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

安装Ceph软件
==============

安装环境准备
-----------------

Ceph安装依赖系统软件包如下:

- libaio1
- libsnappy1
- libcurl3
- curl
- libgoogle-perftools4
- google-perftools
- libleveldb1

安装ceph-deploy(可选)
-------------------------

- 安装 ``ceph-deploy`` 工具::

   sudo apt-get update && sudo apt-get install ceph-deploy

.. note::

   ``ceph-deploy`` 是一个设置或拆除Ceph集群的工具，用于开发、测试和验证项目概念。 ``ceph-deploy`` 可以使用一条命令方便地在多个服务器上安装ceph软件。

安装Ceph存储集群
-------------------------

.. note::

   为了能够完整了解Ceph集群部署过程，本文档没有使用 ``ceph-deploy`` 工具，而是采用手工通过APT包管理工具进行部署。

- 安装Ceph软件包（在每个节点上执行）::

   sudo apt-get update && sudo apt-get install ceph ceph-mds

.. note::

   对于通过对象存储模式使用Ceph，需要安装 ``Ceph Object Gateway`` ，我将另外撰写文章；对于虚拟化平台使用Ceph块设备则需要通过 ``librdb`` 驱动，我也会另外撰写实践文章。

部署Ceph集群
=================

Ceph集群要求至少1个monitor，以及至少和对象存储的副本数量相同（或更多）的OSD运行在集群中。 monitor部署是整个集群设置的重要步骤，例如存储池的副本数量，每个OSD的placement groups数量，心跳间隔，是否需要认证等等。这些配置都有默认值，但是在部署生产集群需要仔细调整这些配置。

本案例采用3个节点：

.. figure:: ../_static/ceph/simple_3nodes_cluster.png

   Figure 1: 三节点Ceph集群

监控引导(monitor bootstrapping)
-----------------------------------

引导启动一个监控器（理论上就是Ceph存储集群）需要一系列要求：

- 唯一标识符(Unique Identifier)：对于每个集群 ``fsid`` 是唯一标识符，这个命名有些类似 ``filesystem id`` ，这是因为早期Ceph存储集群主要用于Ceph文件系统。Ceph现在支持原生接口，块设备以及对象存储网关接口等等，所以 ``fsid`` 现在显得有些取名不当。
- 集群名称(Cluster Name)：Ceph集群有一个集群名字，命名集群名时候需要使用没有空格的字符串。默认Ceph集群名是 ``ceph`` ，显然，对于不同用途的多个Ceph集群，起一个明确易懂的集群名非常重要。例如在 `multisite configuration <http://docs.ceph.com/docs/master/radosgw/multisite/#multisite>`_ 配置模式，可以通过集群名 ``us-west`` 和 ``us-east`` 来表示集群的地理位置，相应的指定Ceph集群配置可以使用集群名，例如 ``ceph.conf`` , ``us-west.conf`` ， ``us-east.conf`` 等等。命令行可以指定集群，例如 ``ceph --cluster {cluster-name}`` 。
- 监控名(Monitor Name)：在集群中的每个监控实例都有一个唯一命名。根据经验，Ceph监控名通常是主机名（建议每个host主机只配置一个Ceph监控，并且不要混合部署Ceph OSD服务和Ceph Monitor）。通过 ``hostname -s`` 可以获得主机的简短主机名。
- 监控映射(Monitor Map)：启动引导初始化监控需要生成一个监控映射。这个监控映射需要 ``fsid`` 以及集群名字，以及至少一个主机名和它的IP地址。（注：这表示每个监控对应一个集群，即对应一个 ``fsid`` ）
- 监控密钥环(Monitor Keyring)：监控进程相互之间通过一个安全密钥加密通讯。你必须生成一个用于监控安全的密钥环并在引导启动时提供给初始化监控。
- 管理员密钥环(Administrator Keyring)：为了使用ceph命令行工具，需要具备一个 ``client.admin`` 用户，所以必须生成一个管理员用户和密钥环，并且必须将 ``client.admin`` 用户添加到监控密钥环。

参考
======

- `Ceph document - Installation (Manual) <http://docs.ceph.com/docs/master/install/>`_
