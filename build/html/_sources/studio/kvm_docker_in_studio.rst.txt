.. _kvm_docker_in_studio:

=======================
Studio环境KVM和Docker
=======================

安装KVM
===========

- 安装软件包::

   sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst libguestfs-tools

.. note::

   - ``qemu-kvm`` QEMU核心
   - ``libvirt-*`` libvirtd用于管理QEMU
   - ``virtinst`` 安装Guest的工具
   - ``libguestfs-tools`` 是Guest文件系统工具，包含了初始化虚拟机的工具命令 ``virt-sysprep``

- (可选) 将 ``自己`` 的账号添加到 ``libvirt`` 用户组（18.04版本可能是 ``libvirtd`` 用户组），以便可以直接运行虚拟机::

   sudo adduser `id -un` libvirt

.. note::

   在最新的Ubuntu 18.10中安装libvirt，安装执行命令的用户已经自动被加入 ``libvirt`` 用户组

- 检查验证::

   virsh list --all

.. note::

   Ubuntu安装libvirt时已经自动激活启动

嵌套虚拟化
================

在使用 ``一台`` 物理主机(MacBook Pro)模拟多个物理服务器来组成集群，部署基于KVM虚拟化的云计算，需要使用 :ref:`nested_virtualization_in_studio` 来实现。在后续 :ref:`kvm` 实践中，会详介绍如何在一台物理主机上运行支持hypervisor的虚拟机，以实现物理服务器集群模拟。 

Docker
========

在MacBook Pro的Host环境，不仅要运行嵌套虚拟户的KVM实现OpenStack的集群模拟，而且要运行Docker来支撑一些底层服务。这是因为，底层服务需要更高的性能，而且要具备隔离以实现模拟分布式集群。

- 安装Docker::

   sudo apt install docker.io

- (可选) 将 ``自己`` 的账号添加到 ``docker`` 用户组::

     sudo adduser `id -un` docker

.. note::

   用户加入docker组还是需要重启主机操作系统才能直接使用 ``docker ps``

下一步
==========

由于KVM和Docker会占用大量的磁盘空间来存储镜像，所以我准备采用 Btrfs 存储来实现（ :ref:`btrfs_in_studio` ）。

参考
===========

- 详细的Ubuntu中安装KVM环境请参考 `Ubuntu环境 <https://github.com/huataihuang/cloud-atlas-draft/tree/master/virtual/kvm/kvm_on_ubuntu/installation.md>`_
- `CentOS7的嵌套虚拟化(nested virtualization)部署实践 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/kvm/nested_virtualization/nested_virtualization_kvm_centos7.md>`_
