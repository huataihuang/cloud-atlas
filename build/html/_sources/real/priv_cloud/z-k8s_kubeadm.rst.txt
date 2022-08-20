.. _z-k8s_kubeadm:

==============================
Kubernetes集群(z-k8s)kubeadm
==============================

部署 :ref:`ha_k8s_dnsrr` 准备工作如下

- 关闭所有Kubernetes服务器上swap::

   sudo swapoff -a
   sudo sed -i 's/\/swapfile/#\/swapfile/g' /etc/fstab

.. note::

   如果服务器默认已经安装和启用了防火墙，请务必参考 :ref:`ha_k8s_kubeadm` 配置正确的端口开放访问

- 在安装Kubernetes集群有一个最大的障碍是 ``GFW`` ，Google的软件仓库(完全屏蔽)以及GitHub仓库(半屏蔽)都需要搭建梯子才能正常访问，对于本文实践采用 :ref:`ubuntu_linux` 体系，所以需要构建 :ref:`apt_proxy_arch` ，就能够进行下一步安装

.. warning::

   安装完毕后务必去除 :ref:`apt_proxy_arch` 的本地代理配置，否则会影响 ``kubectl`` 访问

安装kubeadm, kubelet 和 kubectl
==================================

在所有节点上需要安装以下软件包:

- ``kubeadm`` 启动cluster的命令工具
- ``kubelet`` 运行在集群所有服务器节点的组件，用于启动pod和容器
- ``kubectl`` 和集群通讯的工具

- 安装Kubernetes软件仓库需要的 ``apt`` 包:

.. literalinclude:: ../../kubernetes/deployment/bootstrap_kubernetes_ha/ha_k8s_dnsrr/ha_k8s_kubeadm/apt_install_k8s_need
   :language: bash
   :caption: apt安装k8s仓库所需软件包

- 下载Google云公钥:

.. literalinclude:: ../../kubernetes/deployment/bootstrap_kubernetes_ha/ha_k8s_dnsrr/ha_k8s_kubeadm/install_google_key
   :language: bash
   :caption: 安装Google云公钥

- 添加Kubernetes ``apt`` 仓库:

.. literalinclude:: ../../kubernetes/deployment/bootstrap_kubernetes_ha/ha_k8s_dnsrr/ha_k8s_kubeadm/add_k8s_repository
   :language: bash
   :caption: apt添加k8s仓库

- ``apt`` 更新并安装 ``kubelet`` , ``kubeadm`` , ``kubectl`` ，然后将版本锁定:

.. literalinclude:: ../../kubernetes/deployment/bootstrap_kubernetes_ha/ha_k8s_dnsrr/ha_k8s_kubeadm/apt_install_k8s_soft
   :language: bash
   :caption: apt安装kubelet/kubeadm/kubectl
