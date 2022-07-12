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

.. code:: bash

   wget https://github.com/containerd/containerd/releases/download/v1.6.6/containerd-1.6.6-linux-amd64.tar.gz
   
   sudo tar Cxzvf /usr/local containerd-1.6.6-linux-amd64.tar.gz

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

从 `containerd github仓库containerd.service <https://github.com/containerd/containerd/blob/main/containerd.service>`_ 下载 ``containerd.service`` 保存为 ``/usr/local/lib/systemd/system/containerd.service`` ，然后执行以下激活命令::

   sudo systemctl daemon-reload
   sudo systemctl enable containerd

这里可能会有报错::

   Failed to enable unit: Unit file /etc/systemd/system/containerd.service is masked.

原因是原先有一个软连接指向 ``/dev/null`` ::

   /etc/systemd/system/containerd.service -> /dev/null

移除上述空软链接，再次执行激活

安装runc
==========

从 `containerd github仓库runc <https://github.com/opencontainers/runc/releases>`_ 下载 ``runc`` 存储到 ``/usr/local/sbin/runc`` ，然后执行以下命令安装::

   sudo install -m 755 runc.amd64 /usr/local/sbin/runc

安装CNI plugins
==================

从 `containernetworking github仓库 <https://github.com/containernetworking/plugins/releases>`_ 下载安装包，然后执行以下命令安装::

   wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
   sudo mkdir -p /opt/cni/bin
   tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz

创建默认containerd网络配置
=============================

- 执行以下命令创建containerd的默认网络配置:

.. literalinclude:: install_containerd_official_binaries/generate_containerd_config_k8s
   :language: bash
   :caption: 生成Kuberntes自举所需的默认containerd网络配置

这个步骤非常重要，实际上生成了能够让容器运行的默认网络，现在这个步骤完全依赖于 ``containerd`` 这样的运行时完成，k8s已经移除了配置功能。不过没有这步操作，kubernetes自举 :ref:`ha_k8s_kubeadm` 无法正常运行容器。

.. note::

   吐槽一下，Kubernetes官方文档真是 "博大精深" ，每个细节可能就是一个关键点，但是真的如同说明书一样味同嚼蜡。

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
