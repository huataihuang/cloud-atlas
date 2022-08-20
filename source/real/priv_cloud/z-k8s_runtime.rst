.. _z-k8s_runtime:

====================================
准备Kubernetes集群(z-k8s)容器运行时
====================================

.. note::

   在部署 :ref:`ha_k8s` 之前，首先需要部署高可用的 :ref:`priv_etcd` 。在高可用 :ref:`etcd` 基础上，才能部署高可用Kubernetes。

安装 :ref:`containerd` 运行时
================================

.. note::

   所有Kuberntest节点都需要安装 :ref:`containerd` 容器运行时，替代 :ref:`docker` 

XFS存储目录切换
------------------

.. note::

   文件系统改为常规 :ref:`xfs` 避免不成熟的 :ref:`containerd_btrfs`

- 卸载 ``docker`` :

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/containerd_xfs/uninstall_docker
   :language: bash
   :caption: 卸载docker.io

- 新格式化成 :ref:`xfs` :

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/containerd_xfs/convert_btrfs_to_xfs
   :language: bash
   :caption: 将btrfs磁盘转换成xfs

安装containerd
----------------

采用 :ref:`install_containerd_official_binaries` 完成以下 ``containerd`` 安装:   

- 从 `containernetworking github仓库 <https://github.com/containernetworking/plugins/releases>`_ 下载安装包，并从 从 `containerd github仓库containerd.service <https://github.com/containerd/containerd/blob/main/containerd.service>`_ 下载 ``containerd.service`` :

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/install_containerd_official_binaries/install_containerd
   :language: bash
   :caption: 安装最新v1.6.6 containerd官方二进制程序

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/install_containerd_official_binaries/containerd_systemd
   :language: bash
   :caption: 安装containerd的systemd配置文件

安装runc
----------

- 从 `containerd github仓库runc <https://github.com/opencontainers/runc/releases>`_ 下载 ``runc`` 安装:

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/install_containerd_official_binaries/install_runc
   :language: bash
   :caption: 安装runc

安装cni-plugins
------------------

- 从 `containernetworking github仓库 <https://github.com/containernetworking/plugins/releases>`_ 下载安装cni-plugins:

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/install_containerd_official_binaries/install_cni-plugins
   :language: bash
   :caption: 安装cni-plugins

- 执行以下命令创建containerd的默认网络配置(该步骤可以提供kubernetes集群节点自举所依赖的网络):

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/install_containerd_official_binaries/generate_containerd_config_k8s
   :language: bash
   :caption: 生成Kuberntes自举所需的默认containerd网络配置

转发IPv4和允许iptables查看bridged流量
=======================================

- 执行以下脚本配置 sysctl :

.. literalinclude:: ../../kubernetes/deployment/bootstrap_kubernetes_ha/prepare_z-k8s/k8s_iptables
   :language: bash
   :caption: 配置k8s节点iptables

启用systemd的cgroup v2
==========================

内核调整
-----------

用于部署 ``z-k8s`` Kubernetes集群的虚拟机都采用了Ubuntu 20.04，不过，默认没有启用 :ref:`cgroup_v2` 。实际上Kubernetes已经支持cgroup v2，可以更好控制资源分配，所以，调整内核参数 :ref:`enable_cgroup_v2_ubuntu_20.04` 。

- 修改 ``/etc/default/grub`` 配置在 ``GRUB_CMDLINE_LINUX`` 添加参数::

   systemd.unified_cgroup_hierarchy=1

- 然后执行更新grup::

   sudo update-grub

- 重启系统::

   sudo shutdown -r now

- 重启后登陆系统检查::

   cat /sys/fs/cgroup/cgroup.controllers

可以看到::

   cpuset cpu io memory pids rdma

表明系统已经激活 :ref:`cgroup_v2`

.. note::

   所有 ``z-k8s`` 集群节点都这样完成修订

配置 :ref:`systemd` cgroup驱动
================================

- 修订 ``/etc/containerd/config.toml`` 的 ``systemd`` cgroup 驱动使用 ``runc`` (参见 :ref:`install_containerd_official_binaries` ):

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/install_containerd_official_binaries/config.toml_runc_systemd_cgroup
   :language: bash
   :caption: 配置containerd的runc使用systemd cgroup驱动

重启 containerd ::

   sudo systemctl restart containerd
