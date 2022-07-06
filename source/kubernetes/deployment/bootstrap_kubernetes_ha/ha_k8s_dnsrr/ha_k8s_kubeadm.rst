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

- 所有Kubernetes服务器部署 :ref:`priv_docker` : 使用 :ref:`docker_btrfs_driver` 。完成后在所有节点上验证 ``docker ps`` 正常工作

网络
-----

虚拟机运行环境是 :ref:`ubuntu_linux` ，默认启用防火墙，需要配置防火墙满足以下要求:

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

为简化netfilter链，依然采用 :ref:`iptables` 增加允许访问的TCP端口到管控和工作节点:
