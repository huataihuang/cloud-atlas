.. _kvm_docker_in_studio:

=======================
Studio环境KVM和Docker
=======================

安装KVM
===========

Ubuntu安装KVM
---------------

- 安装软件包::

   sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst libguestfs-tools ovmf

.. note::

   - ``qemu-kvm`` QEMU核心
   - ``libvirt-*`` libvirtd用于管理QEMU
   - ``virtinst`` 安装Guest的工具
   - ``libguestfs-tools`` 是Guest文件系统工具，包含了初始化虚拟机的工具命令 ``virt-sysprep``
   - ``ovmf`` 是模拟EFI firmwarre的功能，请参考 `Using UEFI with QEMU <https://fedoraproject.org/wiki/Using_UEFI_with_QEMU>`_

- (可选) 将 ``自己`` 的账号添加到 ``libvirt`` 用户组（18.04版本可能是 ``libvirtd`` 用户组），以便可以直接运行虚拟机::

   sudo adduser `id -un` libvirt

.. note::

   在最新的Ubuntu 18.10中安装libvirt，安装执行命令的用户已经自动被加入 ``libvirt`` 用户组

- 检查验证::

   virsh list --all

.. note::

   Ubuntu安装libvirt时已经自动激活启动

Arch Linux安装KVM
-------------------

- 安装::

   sudo pacman -S qemu libvirt virt-install \
      dnsmasq ebtables firewalld bridge-utils

   sudo systemctl start firewalld
   sudo systemctl enable firewalld
   sudo systemctl start libvirtd
   sudo systemctl enable libvirtd

.. note::

   - 安装 ``bridge-utils`` 才能具备 ``brctl`` 工具，这样才能建立virtbr0这个NAT旺桥
   - libvirt需要dnsmasq, ebtables, firewalld 来分配NAT网络IP地址和设置netfilter防火墙规则，否则也启动不了NAT网络。详见 :ref:`libvirt_nat_network`

   参考 `How to Create and use Network Bridge on Arch Linux and Manjaro <https://computingforgeeks.com/how-to-create-and-use-network-bridge-on-arch-linux-and-manjaro/>`_

- 安装完qemu之后，如果没有重启系统，则此时还没有加载kvm内核模块，可以通过以下命令手工加载::

   modprobe kvm_intel

- 加载virtio模块::

   modprobe virtio

嵌套虚拟化
================

在使用 ``一台`` 物理主机(MacBook Pro)模拟多个物理服务器来组成集群，部署基于KVM虚拟化的云计算，需要使用 :ref:`nested_virtual` 来实现。在后续 :ref:`kvm` 实践中，会详介绍如何在一台物理主机上运行支持hypervisor的虚拟机，以实现物理服务器集群模拟。 

.. _install_docker_in_studio:

Docker
========

在MacBook Pro的Host环境，不仅要运行嵌套虚拟户的KVM实现OpenStack的集群模拟，而且要运行Docker来支撑一些底层服务。这是因为，底层服务需要更高的性能，而且要具备隔离以实现模拟分布式集群。

.. note::

   安装Docker CE方法参考 Kubernetes 文档 `CRI installation <https://kubernetes.io/docs/setup/cri/>`_ 

- 安装Docker CE::

   # remove all previous Docker versions
   sudo apt remove docker docker-engine docker.io

   # Install packages to allow apt to use a repository over HTTPS
   apt-get update && apt-get install apt-transport-https ca-certificates curl software-properties-common

   # add Docker official GPG key
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

   # Add Docker repository (for Ubuntu Bionic) 注意：nvidia-docker会检查docker-ce版本，强制要求 ubuntu-bionic
   # 所以这里必须采用 bionic 仓库安装 docker-ce
   sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

   sudo apt update
   sudo apt install docker-ce

注意，由于我使用 :ref:`docker_btrfs` 并且 :ref:`minikube_debug_cri_install` 要求，需要设置 ``btrfs`` 存储驱动和  ``systemd`` 作为cgroup驱动，所以执行以下命令::

   # Setup daemon
   cat > /etc/docker/daemon.json <<EOF
   {
     "exec-opts": ["native.cgroupdriver=systemd"],
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "100m"
     },
     "storage-driver": "btrfs"
   }
   EOF

   mkdir -p /etc/systemd/system/docker.service.d

然后重启docker::

   # Restart docker.
   systemctl daemon-reload
   systemctl restart docker

.. note::

   由于 :ref:`nvidia-docker` 依赖Docker官方最新版本的docker，所以这里不使用发行版提供的docker，而是 :ref:`install_docker-ce` 。如果没有这个需求，也可以安装Ubuntu发行版的 ``docker.io`` ::

      sudo apt install docker.io

- (可选) 将 ``自己`` 的账号添加到 ``docker`` 用户组::

     sudo adduser `id -un` docker

.. note::

   用户加入docker组还是需要重启主机操作系统才能直接使用 ``docker ps``

参考
===========

- 详细的Ubuntu中安装KVM环境请参考 `Ubuntu环境 <https://github.com/huataihuang/cloud-atlas-draft/tree/master/virtual/kvm/kvm_on_ubuntu/installation.md>`_
- `CentOS7的嵌套虚拟化(nested virtualization)部署实践 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/kvm/nested_virtualization/nested_virtualization_kvm_centos7.md>`_
- `Arch Linux文档 - KVM <https://wiki.archlinux.org/index.php/KVM>`_
- `Arch Linux文档 - QEMU <https://wiki.archlinux.org/index.php/QEMU>`_
- `Arch Linux文档 - Libvirt <https://wiki.archlinux.org/index.php/Libvirt>`_
