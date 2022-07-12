.. _ha_k8s_kubeadm:

===============================
高可用Kubernetes集群kubeadm
===============================

.. note::

   本文实践基于 :ref:`kubeadm` (单机部署版本)改进，运行环境是 :ref:`priv_cloud_infra` ，同样安装部署 ``kubeadm`` 作为自举kubernetes集群工具，集合kubelet/kubectl构建集群

准备工作
=========

- :ref:`z-k8s_env` 准备就绪，现在具备服务器列表如下:

.. csv-table:: z-k8s高可用Kubernetes集群服务器列表
   :file: ../prepare_z-k8s/z-k8s_hosts.csv
   :widths: 20, 20, 60
   :header-rows: 1

- 关闭所有Kubernetes服务器上swap::

   sudo swapoff -a
   sudo sed -i 's/\/swapfile/#\/swapfile/g' /etc/fstab

- 所有Kubernetes服务器部署 :ref:`priv_docker` : 使用 :ref:`docker_btrfs_driver` ，详细过程见前文 :ref:`prepare_z-k8s` 。完成后在所有节点上验证 ``docker ps`` 正常工作

网络
-----

虚拟机运行环境是 :ref:`ubuntu_linux` ，我对比了默认安装iptables规则::

   sudo iptables -L

可以看到 ``INPOUT`` 和 ``OUTPUT`` 链默认是空的，所以没有任何阻塞::

   Chain INPUT (policy ACCEPT)
   target     prot opt source               destination

   ...
   Chain OUTPUT (policy ACCEPT)
   target     prot opt source               destination

   ...

为了简化部署，特别是对于内部系统，可以忽略防火墙配置。

.. warning::

   Kubernetes系统极其复杂，不应该直接面对外部网络，而且在网络边缘应该部署强限制的防火墙进行防护。

.. note::

   生产环境，特别是现在 ``零信任网络`` ，应该在每个服务器节点部署 :ref:`iptables` 安全规则。我可能后续再改进这方面部署

如果服务器启用防火墙，需要配置防火墙满足以下要求:

.. csv-table:: 管控平台节点防火墙开启端口
   :file: ha_k8s_kubeadm/control_firewall.csv
   :widths: 10, 10, 10, 35,35
   :header-rows: 1

.. csv-table:: 工作节点防火墙开启端口
   :file: ha_k8s_kubeadm/node_firewall.csv
   :widths: 10, 10, 10, 35,35
   :header-rows: 1

:strike:`为了方便配置，采用 ufw 配置防火墙，配置方法如下:` ( :ref:`ufw` 类似 :ref:`redhat_linux` 平台的 :ref:`firewalld` ) 

.. literalinclude:: ha_k8s_kubeadm/ufw
   :language: bash
   :caption: 使用ufw配置kubernetes节点防火墙

- :strike:`为防火墙部署，可以采用iptables增加允许访问的TCP端口到管控和工作节点:`

  - :ref:`iptables_open_ports`
  - :ref:`iptables_persistent`

- 实际上，在安装Kubernetes集群有一个最大的障碍是 ``GFW`` ，Google的软件仓库(完全屏蔽)以及GitHub仓库(半屏蔽)都需要搭建梯子才能正常访问，对于本文实践采用 :ref:`ubuntu_linux` 体系，所以需要构建 :ref:`apt_proxy_arch` ，就能够进行下一步安装。

容器运行时( :ref:`container_runtimes` )
========================================

.. note::

   这是非常关键的步骤，特别是Kubernetes最新版本 1.24 移除了Docker支持直接采用类似 :ref:`containerd` 这样的容器运行时，就要求容器运行时配置完整的CNI plugins才能自举Kubernetes的管控平面

   详细步骤见: :ref:`install_containerd_official_binaries`

- 执行 :ref:`container_runtimes_startup` 为每个节点安装好容器运行时

安装kubeadm, kubelet 和 kubectl
==================================

在所有节点上需要安装以下软件包:

- ``kubeadm`` 启动cluster的命令工具
- ``kubelet`` 运行在集群所有服务器节点的组件，用于启动pod和容器
- ``kubectl`` 和集群通讯的工具

.. note::

   本文实践为 Ubuntu 20.04 ，采用 :ref:`apt` 安装软件包

- 安装Kubernetes软件仓库需要的 ``apt`` 包:

.. literalinclude:: ha_k8s_kubeadm/apt_install_k8s_need
   :language: bash
   :caption: apt安装k8s仓库所需软件包

- 下载Google云公钥:

.. literalinclude:: ha_k8s_kubeadm/install_google_key
   :language: bash
   :caption: 安装Google云公钥

- 添加Kubernetes ``apt`` 仓库:

.. literalinclude:: ha_k8s_kubeadm/add_k8s_repository
   :language: bash
   :caption: apt添加k8s仓库

- ``apt`` 更新并安装 ``kubelet`` , ``kubeadm`` , ``kubectl`` ，然后将版本锁定:

.. literalinclude:: ha_k8s_kubeadm/apt_install_k8s_soft
   :language: bash
   :caption: apt安装kubelet/kubeadm/kubectl

容器运行时
=============

对于Kubernetes运行的容器运行时需要按照 :ref:`container_runtimes` 进行调整

参考
======

- `Installing kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/>`_
- `Troubleshooting kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/>`_
