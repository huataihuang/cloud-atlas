.. _prepare_z-k8s:

================================
z-k8s高可用Kubernetes集群准备
================================

KVM虚拟机运行环境已经按照 :ref:`z-k8s_env` 准备就绪，现在具备服务器列表如下:

.. csv-table:: z-k8s高可用Kubernetes集群服务器列表
   :file: prepare_z-k8s/z-k8s_hosts.csv
   :widths: 20, 20, 60
   :header-rows: 1

在 ``z-k8s`` 集群的管控节点和工作节点，全面安装 Docker 运行时

- 基础数据存储服务器 ``z-b-data-X`` :

  - 直接运行软件，不安装Docker容器化，也不运行Kubelet
  - 独立运行，不纳入K8s，仅作为基础服务提供( :ref:`etcd` )

- 管控节点 ``z-k8s-m-X`` :

  - 安装Docker/Kubelet/Kubeadm

- 工作节点 ``z-k8s-n-X`` :

  - 安装Docker/Kubelet/Kubeadm

安装Docker运行时
====================

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

安装 ``kubectl / kubeadm / kubelet``
======================================

.. note::

   Debian/Ubuntu (Kubernetes官方方法) 完成 :ref:`kubeadm` 等基础软件安装

- 更新并安装 Kubernetes apt 仓库所需软件包::

   sudo apt update
   sudo apt upgrade -y
   sudo apt install -y apt-transport-https ca-certificates curl

- 下载 Google Cloud 公开签名秘钥::

   sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg -x "http://192.168.6.200:3128/"

.. note::

   这里使用 ``-x "http://192.168.6.200:3128/"`` 是为了使用 :ref:`squid_socks_peer` 翻墙

- 添加 Kubernetes ``apt`` 仓库::

   echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

- 安装::

   sudo apt update
   sudo apt install -y kubelet kubeadm kubectl
   sudo apt-mark hold kubelet kubeadm kubectl
