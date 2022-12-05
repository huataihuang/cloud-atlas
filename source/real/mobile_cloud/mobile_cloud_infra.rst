.. _mobile_cloud_infra:

============
移动云架构
============

硬件和OS
============

采用 :ref:`apple_silicon_m1_pro` MacBook Pro 16" ，运行 :ref:`asahi_linux` 系统:

- 通过 :ref:`kvm` 来运行虚拟机，借鉴 :ref:`priv_cloud_infra` 部署一个full :ref:`kubernetes`
- 启用域名 ``cloud-atlas.io`` 模拟构建 ``dev.cloud-atlas.io`` 开发和持续集成环境

模拟集群
===========

- 采用 :ref:`kind` 构建本地容器化 :ref:`kubernetes` 集群
- 采用 :ref:`arm_kvm` 构建本地运行的虚拟化服务器集群，进一步部署 :ref:`kubernetes` 和 :ref:`openshift`

  - 探索 :ref:`arm_neve`

虚拟服务器分布
===================

.. csv-table:: acloud服务器部署多层虚拟化虚拟机分配
   :file: mobile_cloud_infra/hosts.csv
   :widths: 10, 10, 10, 10, 10, 10, 30
   :header-rows: 1
