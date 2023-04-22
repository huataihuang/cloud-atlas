.. _mobile_cloud_infra:

============
移动云架构
============

硬件和OS
============

我在 **移动云计算** 中采用笔记本电脑来构建云:

- 采用 :ref:`apple_silicon_m1_pro` MacBook Pro 16" ，运行 :ref:`asahi_linux` 系统:

  - 通过 :ref:`kvm` 来运行虚拟机，借鉴 :ref:`priv_cloud_infra` 部署一个full :ref:`kubernetes`
  - 实践发现对于内存有限的笔记本电脑(32GB)运行5个KVM虚拟机依然内存捉襟见肘，所以后来在 :ref:`mbp15_late_2013` 笔记本我追求轻量级运行，不再强求KVM虚拟化模拟，而是采用纯容器的 :ref:`kind`
  - 启用域名 ``cloud-atlas.io`` 模拟构建 ``dev.cloud-atlas.io`` 开发和持续集成环境

- 一台非常古老的 :ref:`intel_core_i7_4850hq` :ref:`mbp15_late_2013` 笔记本，已经快10年历史了，不过我 :ref:`macbook_nvme` 还能再打:

  - 采用纯容器运行 :ref:`kind`
  - 专注模拟 :ref:`kubernetes` 并进行相关开发
  - 更为复杂的云计算(考虑到性能消耗，特别是海量内存需求)，还是采用数据中心服务器(二手) :ref:`hpe_dl360_gen9` 来实现(最高支持 768GB RDIMM内存)

.. note::

   使用Linux来构建移动云计算，其实是非常hard的工作，你必须解决很多底层的技术难题，包括但不限于 :ref:`kernel` / :ref:`linux_storage` / :ref:`kubernetes` ( :ref:`kind` )等等组合的技术堆栈。这是一个充满挑战和乐趣的过程。

   不过，如果你更侧重于软件开发，或者想一步跨国底层各种 :ref:`kvm` / :ref:`docker` 虚拟化和容器技术的障碍，那么采用 :ref:`macos_studio` 或许是一个更方便的选择: 快速构建Kubernetes平台，学习和实践上层的容器调度技术以及 :ref:`devops` (持续集成)，将自己开发的软件推送到生产环境。(这样也不错哦)

   Anyway，成为全栈工程师!!!

模拟集群
===========

- X86架构 :ref:`mbp15_late_2013` 笔记本: 采用 :ref:`kind` 构建本地容器化 :ref:`kubernetes` 集群，作为个人开发环境 ``dev.cloud-atlas.io``
- ARM架构 :ref:`apple_silicon_m1_pro` MacBook Pro 16": 采用 :ref:`arm_kvm` 构建本地运行的虚拟化服务器集群，进一步部署 :ref:`kubernetes` 和 :strike:`openshift`

  - 探索 :ref:`arm_neve`

虚拟服务器分布
===================

.. csv-table:: acloud服务器部署多层虚拟化虚拟机分配
   :file: mobile_cloud_infra/hosts.csv
   :widths: 10, 10, 10, 10, 10, 10, 30
   :header-rows: 1

实践
=========

我将按照不同的硬件环境(X86和ARM)分为两部分分别整理:

- :ref:`mobile_cloud_arm`
- :ref:`mobile_cloud_x86`
