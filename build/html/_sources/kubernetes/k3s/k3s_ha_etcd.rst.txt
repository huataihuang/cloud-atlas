.. _k3s_ha_etcd:

================
K3s高可用etcd
================

.. note::

   ``K3s`` 还支持一种内嵌 ``etcd`` 模式，对应 :ref:`ha_k8s_stacked`

   本文采用的是 exteneral etcd 模式，对应 :ref:`ha_k8s_external`

:ref:`etcd` 是Kuberntes主流的持久化数据存储，提供了分布式存储能力。在 ``K3s`` 的高可用部署环境，使用 ``external etcd`` 是最稳定可靠的部署模型。

在 :ref:`pi_stack` 环境采用3台 :ref:`pi_3` 硬件部署3节点 :ref:`etcd` 集群:

.. csv-table:: 树莓派k3s管控服务器
   :file: k3s_ha_etcd/hosts.csv
   :widths: 40, 60
   :header-rows: 1

下载etcd
==========

- `etcd-io / etcd Releases <https://github.com/etcd-io/etcd/releases/>`_ 提供了最新版本，当前 ``3.5.2`` :

.. literalinclude:: ../deployment/etcd/install_run_local_etcd/install_etcd.sh
   :language: bash
   :caption: 下载并安装etcd脚本 install_etcd.sh

生成和分发证书
=================

使用 ``cfssl`` 签发证书，不过 :ref:`alpine_linux` 只在 ``edge`` 仓库提供了 ``cfssl`` 。当前我使用alpine linux的stable仓库，不能同时激活stable和edge。

``cfssl`` 官方提供了linux amd64版本，也可以在 macOS 上通过 brew 安装。不过我为了能够独立在 :ref:`pi_stack` 环境完成所有工作，采用:

- 在 :ref:`alpine_linux` 环境节点 ``x-k3s-a-0`` 

  - 建立容器运行一个开发环境 ``x-dev`` 
  - 然后 :ref:`alpine_cfssl`
  - 再按照 :ref:`etcd_tls` 方法完成 ``cfssl`` 安装

.. note::

   Red Hat :ref:`openshift` 所使用的 etcd 镜像就是采用上游 etcd镜像 (基于 Alpine Linux OS) `install: use origin-v4.0 etcd image #511 <https://github.com/openshift/machine-config-operator/pull/511>`_

- 初始化证书授权:


参考
=======

- `Setting up Etcd Cluster with TLS Authentication Enabled <https://medium.com/nirman-tech-blog/setting-up-etcd-cluster-with-tls-authentication-enabled-49c44e4151bb>`_
- `etcd Security Guide <https://github.com/ericchiang/etcd-security-guide>`_
- `Generate self-signed certificates <https://github.com/coreos/docs/blob/master/os/generate-self-signed-certificates.md>`_ CoreOS官方(etcd开发公司)提供的指导文档
