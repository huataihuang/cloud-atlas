.. _mobile_cloud_infra:

============
移动云架构
============

硬件和OS
============

采用 :ref:`apple_silicon_m1_pro` MacBook Pro 16" ，运行 :ref:`asahi_linux` 系统:

- 通过 :ref:`kvm` 来运行虚拟机，借鉴 :ref:`priv_cloud_infra` 部署一个full :ref:`kubernetes`
- 启用域名 ``cloud-atlas.io`` 模拟构建 ``dev.cloud-atlas.io`` 开发和持续集成环境

