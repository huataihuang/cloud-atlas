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

嵌套虚拟化(Nested Virtualization)
====================================

.. note::

   为了能够在一台物理主机（MacBook Pro）上能够模拟出OpenStack集群，即同时运行多个hypervisor，需要使用嵌套虚拟化(Nested Virtualization)。虽然嵌套虚拟化会导致较大的性能损失，但是对于开发测试环境，依然是节约硬件的解决方案。

- 检查系统内核是否激活嵌套虚拟化::

   cat /sys/module/kvm_intel/parameters/nested

输入如果是 ``Y`` 就表示已经激活嵌套虚拟化，如果是 ``N`` 则执行下一步激活

- (根据需要执行这一步)激活嵌套虚拟化步骤是通过重新加载KVM intel内核模块实现::

   sudo rmmod kvm-intel
   sudo sh -c "echo 'options kvm-intel nested=y' >> /etc/modprobe.d/kvm_intel.conf"
   sudo modprobe kvm-intel

.. note::

   在Ubuntu 18.10上，已经不需要执行这步--因为默认已经有配置文件 ``/etc/modprobe.d/qemu-system-x86.conf`` 配置文件激活了 ``kvm_intel`` 模块的嵌套虚拟化（内容如下）::

      options kvm_intel nested=1

   并且通过检查 ``cat /sys/module/kvm_intel/parameters/nested`` 可以看到内核模块 ``kvm-intel`` 已经激活了嵌套虚拟化。

Docker
========

在MacBook Pro的Host环境，不仅要运行嵌套虚拟户的KVM实现OpenStack的集群模拟，而且要运行Docker来支撑一些底层服务。这是因为，底层服务需要更高的性能，而且要具备隔离以实现模拟分布式集群。

::

   sudo apt install docker.io

下一步
==========

由于KVM和Docker会占用大量的磁盘空间来存储镜像，所以我准备采用 Btrfs 存储来实现（ :ref:`btrfs_in_studio` ）。

参考
===========

- 详细的Ubuntu中安装KVM环境请参考 `Ubuntu环境 <https://github.com/huataihuang/cloud-atlas-draft/tree/master/virtual/kvm/kvm_on_ubuntu/installation.md>`_
- `CentOS7的嵌套虚拟化(nested virtualization)部署实践 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/kvm/nested_virtualization/nested_virtualization_kvm_centos7.md>`_
