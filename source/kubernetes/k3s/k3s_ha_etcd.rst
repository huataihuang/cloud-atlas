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

`etcd-io / etcd Releases <https://github.com/etcd-io/etcd/releases/>`_ 提供了最新版本，当前 ``3.5.2`` :

.. literalinclude:: k3s_ha_etcd/download_etcd.sh
   :language: bash
   :caption: 下载etcd的linux版本脚本

生成和分发证书
=================

使用 ``cfssl`` 签发证书，不过 :ref:`alpine_linux` 只在 ``edge`` 仓库提供了 ``cfssl`` 。当前我使用alpine linux的stable仓库，不能同时激活stable和edge。

``cfssl`` 官方提供了linux amd64版本，也可以在 macOS 上通过 brew 安装。由于签发证书是独立工作，我采用:

- :strike:`在 macOS 上` 在 :ref:`alpine_linux` 环境节点 ``x-k3s-a-0`` 

  - 建立容器运行一个开发环境 ``x-dev`` 
  - 然后 :ref:`alpine_cfssl`
  - 再按照 :ref:`etcd_tls` 方法完成 ``cfssl`` 安装



