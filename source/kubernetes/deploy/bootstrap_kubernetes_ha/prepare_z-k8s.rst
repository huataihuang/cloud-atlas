.. _prepare_z-k8s:

================================
z-k8s高可用Kubernetes集群准备
================================

KVM虚拟机运行环境已经按照 :ref:`z-k8s_env` 准备就绪，现在具备服务器列表如下:

.. csv-table:: z-k8s高可用Kubernetes集群服务器列表
   :file: prepare_z-k8s/z-k8s_hosts.csv
   :widths: 20, 20, 60
   :header-rows: 1

在 ``z-k8s`` 集群的管控节点和工作节点，全面安装 :strike:`Docker` :ref:`containerd` 运行时

- 基础数据存储服务器 ``z-b-data-X`` :

  - 直接运行软件，不安装Docker容器化，也不运行Kubelet
  - 独立运行，不纳入K8s，仅作为基础服务提供( :ref:`etcd` )

- 管控节点 ``z-k8s-m-X`` :

  - 安装containerd/Kubelet/Kubeadm

- 工作节点 ``z-k8s-n-X`` :

  - 安装containerd/Kubelet/Kubeadm

.. note::

   Kubernetes 1.24 移除了Docker直接支持，推荐使用 :ref:`containerd` 作为运行时，不仅可以节约资源而且更为安全(减少攻击面)。不过 ``containerd`` 文档资料较少，不如 :ref:`docker` 有较为丰富的文档。例如，我 :ref:`docker_btrfs_driver` 存储容器镜像，但是 :ref:`containerd_btrfs` 支持非常有限(不成熟)，无法充分发挥 :ref:`btrfs` 的优秀特性(实际依然是 :ref:`overlayfs` on btrfs)，性能和稳定性不佳。

.. note::

   我原先在 :ref:`bootstrap_kubernetes_single` 部署 :ref:`kubeadm` 有详细步骤，本文是再次实践，以完成 :ref:`bootstrap_kubernetes_ha`

安装 :ref:`containerd` 运行时(最新部署)
=========================================

- ``containerd`` 轻量级原生支持Kubernetes规范，所以重点实践
- 文件系统改为常规 :ref:`xfs` 避免不成熟的 :ref:`containerd_btrfs`
- 实践 :ref:`estargz_lazy_pulling`

首先采用 :ref:`containerd_xfs` 将containerd所使用的存储目录文件系统，由之前 :ref:`docker_btrfs_driver`  切换为 :ref:`xfs` :

- 卸载 ``docker`` :

.. literalinclude:: ../../container_runtimes/containerd/containerd_xfs/uninstall_docker
   :language: bash
   :caption: 卸载docker.io

- 新格式化成 :ref:`xfs` :

.. literalinclude:: ../../container_runtimes/containerd/containerd_xfs/convert_btrfs_to_xfs
   :language: bash
   :caption: 将btrfs磁盘转换成xfs

然后采用 :ref:`install_containerd_official_binaries` 完成以下 ``containerd`` 安装:

- 从 `containernetworking github仓库 <https://github.com/containernetworking/plugins/releases>`_ 下载安装包，并从 从 `containerd github仓库containerd.service <https://github.com/containerd/containerd/blob/main/containerd.service>`_ 下载 ``containerd.service`` :

.. literalinclude:: ../../container_runtimes/containerd/install_containerd_official_binaries/install_containerd
   :language: bash
   :caption: 安装最新v1.6.6 containerd官方二进制程序

.. literalinclude:: ../../container_runtimes/containerd/install_containerd_official_binaries/containerd_systemd
   :language: bash
   :caption: 安装containerd的systemd配置文件

然后安装 ``runc`` :

- 从 `containerd github仓库runc <https://github.com/opencontainers/runc/releases>`_ 下载 ``runc`` 安装:

.. literalinclude:: ../../container_runtimes/containerd/install_containerd_official_binaries/install_runc
   :language: bash
   :caption: 安装runc

- 从 `containernetworking github仓库 <https://github.com/containernetworking/plugins/releases>`_ 下载安装cni-plugins:

.. literalinclude:: ../../container_runtimes/containerd/install_containerd_official_binaries/install_cni-plugins
   :language: bash
   :caption: 安装cni-plugins

- 执行以下命令创建containerd的默认网络配置(该步骤可以提供kubernetes集群节点自举所依赖的网络):

.. literalinclude:: ../../container_runtimes/containerd/install_containerd_official_binaries/generate_containerd_config_k8s
   :language: bash
   :caption: 生成Kuberntes自举所需的默认containerd网络配置

.. note::

   完成了 :ref:`container_runtimes` 安装后，需要进一步完成 :ref:`kubeadm` 中网络和cgroup配置，见下文

安装Docker运行时(归档)
========================

- 安装 :ref:`container_runtimes` Docker ::

   sudo apt update
   sudo apt upgrade -y

   sudo apt install docker.io -y

- 将个人用户账号 ``huatai`` 添加到 ``docker`` 用户组方便执行docker命令::

   sudo usermod -aG docker $USER

docker存储驱动btrfs
----------------------

VM数据盘( ``/var/lib/docker`` )准备
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

为了提升性能和存储效率，采用 :ref:`docker_btrfs_driver` ，所以执行:

- 在虚拟机中添加独立的10GB :ref:`ceph_block_device` ，此步骤 :ref:`ceph_rbd_libvirt` 所以执行以下命令::

   virsh vol-create-as --pool images_rbd --name z-k8s-m-1.docker --capacity 10GB --allocation 10GB --format raw

.. note::

   数据磁盘用于docker，所以命名是 ``<vm-name>.<disk-name>`` ，这里案例是用于 ``z-k8s-m-1`` 虚拟机的 ``docker`` 磁盘，所以命名为 ``z-k8s-m-1.docker``

- 创建磁盘完成后检查::

   virsh vol-list images_rbd

可以看到::

   Name               Path
   ---------------------------------------------------
   z-k8s-m-1          libvirt-pool/z-k8s-m-1
   z-k8s-m-1.docker   libvirt-pool/z-k8s-m-1.docker
   ...

- 准备设备XML文件

.. literalinclude:: prepare_z-k8s/z-k8s-m-1.docker-disk.xml
   :language: xml
   :linenos:
   :caption: rbd磁盘设备XML

- 添加磁盘文件::

   virsh attach-device z-k8s-m-1 z-k8s-m-1.docker-disk.xml --live --config

- 此时在虚拟机 ``z-k8s-m-1`` 内部可以看到新磁盘设备 ``fdisk -l`` ::

   Disk /dev/vdb: 9.32 GiB, 10000000000 bytes, 19531250 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes

这个磁盘设备将用于docker

- 脚本 ``vm_docker-disk.sh`` 帮助完成上述自动化过程 

.. literalinclude:: prepare_z-k8s/vm_docker-disk.sh
   :language: bash
   :linenos:
   :caption: rbd磁盘(用于docker)注入脚本

- 执行方法::

   ./vm_docker-disk.sh z-k8s-m-2

btrfs存储驱动
~~~~~~~~~~~~~~~

在虚拟机内部配置 :ref:`docker_btrfs_driver` :

- 在虚拟机内部安装 ``btrfs`` 管理软件包 ``btrfs-progs`` ::
  
   sudo apt install btrfs-progs -y

- 磁盘分区::

   sudo parted /dev/vdb mklabel gpt
   sudo parted -a optimal /dev/vdb mkpart primary 0% 100%

- 创建 ``btrfs`` ::

   sudo mkfs.btrfs -f -L docker /dev/vdb1

- 添加 ``/etc/fstab`` 配置::

   echo "/dev/vdb1    /var/lib/docker    btrfs   defaults,compress=lzo    0 1" | sudo tee -a /etc/fstab

- 停止Docker::

   sudo systemctl stop docker.socket
   sudo systemctl stop docker

- 备份 ``/var/lib/docker`` 目录内容，并清空该目录::

   sudo cp -au /var/lib/docker /var/lib/docker.bk
   sudo rm -rf /var/lib/docker/*

- 挂载btrfs文件系统::

   sudo mount /var/lib/docker

- 检查挂载::

   mount | grep vdb1

- 将 ``/var/lib/docker.bk`` 内容恢复回 ``/var/lib/docker/`` ::

   sudo su -
   cp -au /var/lib/docker.bk/* /var/lib/docker/

- 创建 ``/etc/docker/daemon.json`` :

.. literalinclude:: prepare_z-k8s/create_daemon_jston.sh
   :language: bash
   :linenos:
   :caption: 创建Docker btrfs配置脚本
   
- 启动docker::

   sudo systemctl start docker

- 检查docker 是否使用btrfs::

   docker info

转发IPv4和允许iptables查看bridged流量
=======================================

- 执行以下脚本配置 sysctl :

.. literalinclude:: prepare_z-k8s/k8s_iptables
   :language: bash
   :caption: 配置k8s节点iptalbes

配置Cgroup v2
=================

在 :ref:`container_runtimes_startup` 详细说明了 Kubernetes 可以使用 :ref:`cgroup_v2` 来更精细化管控资源。配置方法是在内核参数传递 ``systemd.unified_cgroup_hierarchy=1`` 。当时我配置采用修订 ``/etc/default/grub`` 在 ``GRUB_CMDLINE_LINUX`` 行添加上述参数，然后再执行 ``sudo update-grub`` 更新启动。

另外一种常用的修订内核参数方法是使用 :ref:`grubby` 工具:

.. literalinclude:: prepare_z-k8s/k8s_cgroupv2
   :language: bash
   :caption: 配置k8s节点cgroup v2

配置 :ref:`systemd` cgroup驱动
================================

- 修订 ``/etc/containerd/config.toml`` 的 ``systemd`` cgroup 驱动使用 ``runc`` (参见 :ref:`install_containerd_official_binaries` ):

.. literalinclude:: ../../container_runtimes/containerd/install_containerd_official_binaries/config.toml_runc_systemd_cgroup
   :language: bash
   :caption: 配置containerd的runc使用systemd cgroup驱动

重启 containerd ::

   sudo systemctl restart containerd

参考
======

- `Container Runtimes <https://kubernetes.io/docs/setup/production-environment/container-runtimes/>`_
