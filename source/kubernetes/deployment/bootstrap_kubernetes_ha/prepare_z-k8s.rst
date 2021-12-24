.. _prepare_z-k8s:

================================
z-k8s高可用Kubernetes集群准备
================================

KVM虚拟机运行环境已经按照 :ref:`z-k8s_env` 准备就绪，现在具备服务器列表如下:

.. csv-table:: z-k8s高可用Kubernetes集群服务器列表
   :file: prepare_z-k8s/z-k8s_hosts.csv
   :widths: 20, 20, 60
   :header-rows: 1

安装Docker运行时
====================

在 ``z-k8s`` 集群的管控节点和工作节点，全面安装 Docker 运行时

- 基础数据存储服务器 ``z-b-data-X`` :

  - 直接运行软件，不安装Docker容器化，也不运行Kubelet
  - 独立运行，不纳入K8s，仅作为基础服务提供( :ref:`etcd` )

- 管控节点 ``z-k8s-m-X`` :

  - 安装Docker/Kubelet/Kubeadm

- 工作节点 ``z-k8s-n-X`` :

  - 安装Docker/Kubelet/Kubeadm

安装 :ref:`container_runtimes` Docker 以及 ``kubectl / kubeadm / kubelet`` ::

   sudo apt update
   sudo apt upgrade -y

   
