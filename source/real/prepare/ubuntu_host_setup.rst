.. _ubuntu_host_setup:

======================
Ubuntu物理主机设置
======================

底层物理主机上安装的Linux操作系统追求最精简的部署，只运行 :ref:`kvm` 虚拟化

操作系统准备
=============

- 首先进行 :ref:`ubuntu_server_init` ，使得操作系统精简
- 操作系统默认采用 :ref:`systemd_timesyncd` 进行时钟同步，但是需要注意默认配置UTC时间(格林威治)，所以我们需要调整到本地时区::

   unlink /etc/localtime
   ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

远程管理准备
===============

由于我使用的服务器是 :ref:`hpe_dl360_gen9` ，提供了 :ref:`hp_ilo` ，所以配置管理IP以及验证。

网络设置
===========

Ubuntu Server采用 :ref:`netplan` 配置网络，需要实现以下架构:

- 服务器实现交换功能，采用 :ref:`hpe_dl360_gen9` 板载4口broadcom网卡以及附加的4口intel网卡，构建连接多台 :ref:`pi_cluster` 的网络，实现SDN软交换以及网络流量监控
- 详细的服务器物理改造见 :ref:`dl360+pi_one_machine`

存储磁盘
==========

在 :ref:`priv_docker` 和 :ref:`priv_kvm` 采用不同的存储方式:

- Docker采用 :ref:`docker_btrfs_driver` ，可以提高存储性能，并且实现较好的存储卷隔离
- :strike:`KVM(libvirt)采用 stratis 而不是Btrfs，原因是对于虚拟化存储访问Btrfs的缓存以及COW影响性能，不能充分发挥出virtio的性能，而采用 XFS + LVM 的Stratis可以兼有卷管理的优势以及XFS的稳定性，这也是 Red Hat 推荐的存储方案` (由于 :ref:`stratis` 存储技术和 :ref:`redhat_linux` 平台紧密结合，目前尚未看到有移植到 Debian/Ubuntu 体系的解决方案，所以我暂时放弃在物理主机上部署Stratis，而采用 :ref:`libvirt_lvm_pool` ，希望通过减少存储层次来提升性能
