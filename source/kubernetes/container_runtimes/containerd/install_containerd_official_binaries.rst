.. _install_containerd_official_binaries:

============================
安装containerd官方执行程序
============================

在 :ref:`k8s_dnsrr` ，由于Kubernetes 1.24移除了Docker支持，改为采用最新的 ``dockerd`` 运行时，以下为部署实践

- 首先停滞 ``kubelet`` 并卸载之前安装的Docker相关软件:

.. code:: bash

   sudo systemctl stop kubelet
   sudo systemctl stop docker docker.socket
   sudo systemctl stop containerd

   sudo apt remove docker.io containerd runc
   sudo apt autoremove

安装dockerd
==============

- 从 `containerd 官方发布 <https://github.com/containerd/containerd/releases>`_ 下载最新版本 v1.6.6 :

.. literalinclude:: install_containerd_official_binaries/install_containerd
   :language: bash
   :caption: 安装最新v1.6.6 containerd官方二进制程序

以上会获得如下执行文件::

   bin/containerd-shim
   bin/containerd
   bin/containerd-shim-runc-v1
   bin/containerd-stress
   bin/containerd-shim-runc-v2
   bin/ctr

.. note::

   对于Kubernetes， ``containerd`` 官方发行版执行程序已经包含了支持 Kubernetes CRI功能，已经不再需要早期单独的 ``cri-containerd-...`` 程序(旧版本已经废弃)

配置systemd启动脚本
=====================

从 `containerd github仓库containerd.service <https://github.com/containerd/containerd/blob/main/containerd.service>`_ 下载 ``containerd.service`` 保存为 ``/usr/local/lib/systemd/system/containerd.service`` 并激活:

.. literalinclude:: install_containerd_official_binaries/containerd_systemd
   :language: bash
   :caption: 安装containerd的systemd配置文件

这里可能会有报错::

   Failed to enable unit: Unit file /etc/systemd/system/containerd.service is masked.

原因是原先有一个软连接指向 ``/dev/null`` ::

   /etc/systemd/system/containerd.service -> /dev/null

移除上述空软链接，再次执行激活

安装runc
==========

从 `containerd github仓库runc <https://github.com/opencontainers/runc/releases>`_ 下载 ``runc`` 存储到 ``/usr/local/sbin/runc`` ，然后执行以下命令安装:

.. literalinclude:: install_containerd_official_binaries/install_runc
   :language: bash
   :caption: 安装runc

安装CNI plugins
==================

从 `containernetworking github仓库 <https://github.com/containernetworking/plugins/releases>`_ 下载安装包，然后执行以下命令安装:

.. literalinclude:: install_containerd_official_binaries/install_cni-plugins
   :language: bash
   :caption: 安装cni-plugins

上述方法也是 `How To Setup A Three Node Kubernetes Cluster For CKA: Step By Step <https://k21academy.com/docker-kubernetes/three-node-kubernetes-cluster/>`_ 提供的通过containerd内置工具生成默认配置(实际上这个方法是Kubernetes官方文档配置containerd默认网络的方法)

此外，从 `containerd安装CNI plugins官方文档 <https://github.com/containerd/containerd/blob/main/script/setup/install-cni>`_ ``install-cni`` 脚本中获取生成配置部分(但是该方法不是Kubernetes官方文档推荐，似乎没有成功):

.. literalinclude:: install_containerd_official_binaries/install-cni
   :language: bash
   :caption: 安装containerd CNI plugins脚本 install-cni 生成配置部分

.. note::

   在Kubernetes 1.24之前，CNI plugins可以通过 kubelet 使用 ``cni-bin-dir`` 和 ``network-plugin`` 命令参数来管理。但是在 Kubernetes 1.24 中，这些参数已经被移除，因为CNI管理已经不属于kubelet范围。

针对不同的 :ref:`container_runtimes` ，需要采用不同的方式安装CNI plugins:

- `containerd安装CNI plugins官方文档 <https://github.com/containerd/containerd/blob/main/script/setup/install-cni>`_
- `CRI-O安装CNI plugins官方文档 <https://github.com/cri-o/cri-o/blob/main/contrib/cni/README.md>`_

创建默认containerd网络配置
=============================

- 执行以下命令创建containerd的默认网络配置:

.. literalinclude:: install_containerd_official_binaries/generate_containerd_config_k8s
   :language: bash
   :caption: 生成Kuberntes自举所需的默认containerd网络配置

这个步骤非常重要，实际上生成了能够让容器运行的默认网络，现在这个步骤完全依赖于 ``containerd`` 这样的运行时完成，k8s已经移除了配置功能。不过没有这步操作，kubernetes自举 :ref:`ha_k8s_kubeadm` 无法正常运行容器。

.. note::

   吐槽一下，Kubernetes官方文档真是 "博大精深" ，每个细节可能就是一个关键点，但是真的如同说明书一样味同嚼蜡。

.. _containerd_systemdcgroup_true:

配置 :ref:`systemd` cgroup驱动
===============================

- 修改 ``/etc/containerd/config.toml`` 激活 :ref:`systemd` cgroup驱动 ``runc`` : 

.. literalinclude:: install_containerd_official_binaries/config.toml_runc_systemd_cgroup
   :language: bash
   :caption: 配置containerd的runc使用systemd cgroup驱动

参考
=======

- `Getting started with containerd <https://github.com/containerd/containerd/blob/main/docs/getting-started.md>`_
- `Kubernetes Documentation: Container Runtimes <https://kubernetes.io/docs/setup/production-environment/container-runtimes/>`_
