.. _priv_cloud_infra:

============
私有云架构
============

私有云拓扑架构图
==================

2021年10月，我购买了 :ref:`hpe_dl360_gen9` 来实现完整的云计算模拟，规划是采用一台二手服务器:

- 物理服务器安装 :ref:`ubuntu_linux`

  - 其实我更倾向于底层物理服务器采用高度定制精简的 :ref:`gentoo_linux` 甚至 :ref:`lfs` ，但是由于经费紧张，我需要采用 :ref:`vgpu` 构建 :ref:`gpu_k8s` ， :strike:`只能` 采用商业化较好的 :ref:`ubuntu_linux` 为好(或者 :ref:`redhat_linux` )
  - 如果有多块物理GPU卡，可以考虑采用 :ref:`gentoo_linux` 来构建自己定制的底层操作系统(希望有一天我有充足的GPU卡来完成这个构想实践)
  - 另一种激进的方法我构思采用 :ref:`gentoo_linux` 上 :ref:`docker` 运行 :ref:`ubuntu_linux` 来实现 :ref:`vgpu` (CRAZY，只是我的YY)

- 通过 :ref:`kvm_nested_virtual` 运行大量的一级KVM虚拟机，一级KVM虚拟机作为运行 :ref:`openstack` 的物理机，部署一个完整的OpenStack集群

  - 物理服务器运行 :ref:`cockpit` 可以集成 :ref:`stratis` 存储，以及 :ref:`ovirt` ，所以在第一层虚拟化上，可以不用自己手工部署 :ref:`kvm` ，而是集成到 oVirt
  - 通过oVirt来管理第一层虚拟机，虚拟机开启嵌套虚拟化，这样可以同时学习oVirt的管理，体验不同于OpenStack的轻量级虚拟化管理平台
    
    - oVirt支持 :ref:`gluster` 管理，可以方便在底层部署 GlusterFS

- 在一级虚拟机中运行 :ref:`kubernetes` 模拟裸机的K8S集群
- 在OpenStack中部署运行大量二级虚拟机，按需运行，模拟云计算的弹性以及计费和监控
- OpenStack中的二级虚拟机内部再部署一个 :ref:`kubernetes` 集群，模拟云计算之上的K8S集群，结合 HashiCorp 的 Terraform 来实现全链路的自动化部署
- 附加：在DL360物理服务器上运行一个精简的Docker容器来做日常开发学习

.. figure:: ../../_static/real/priv_cloud/real_cloud.png
   :scale: 80

多层次虚拟化服务器分布
------------------------

.. csv-table:: zcloud服务器部署多层虚拟化虚拟机分配
   :file: priv_cloud_infra/hosts.csv
   :widths: 10, 10, 10, 10, 10, 10, 10, 30
   :header-rows: 1

.. note::

   虚拟机的内存最为关键，作为 :ref:`z-k8s` 工作节点，实践发现配置4G内存非常容易触发oom，所以目前统一改为8G，并且可能随着测试压力增大还需要调整::

      <memory unit='KiB'>16777216</memory>
      <currentMemory unit='KiB'>8388608</currentMemory>

   当前配置改为8G，并且预留可扩展到16G

.. note::

   保留 ``192.168.6.21 ~ 192.168.6.50`` 作为DHCP段IP，用于验证PXE以及无线网络段动态IP地址分配

主机命名规则
~~~~~~~~~~~~~

- 物理主机: 单字段命名

- 物理主机集群(树莓派): 主机名分为 3 段，以 ``-`` 作为分隔符

  - 第一个字段 表示服务器层次

    - ``pi`` 树莓派

  - 第二字段 表示服务器节点身份

    - ``master`` 管控服务器
    - ``worker`` 工作节点服务器

  - 第三字段 表示节点序号数字

- 单用途虚拟机: 主机名分为 2 段，以 ``-`` 作为分隔符

  - 第一个字段 表示服务器层次(见下文)，目前只有 ``z``
  - 第二个字段 表示用途 ，如 ``dev`` ``numa`` 等

- 虚拟集群: 主机名分为 4 段，以 ``-`` 作为分隔符

  - 第一个字段 表示服务器层次， ``z`` 表示在 :ref:`hpe_dl360_gen9` 物理服务器( ``zcloud`` )上部署的第一层虚拟化; ``a`` 表示 ``第二层`` 虚拟化，主要是在OpenStack之上运行虚拟机，模拟大规模 :ref:`openstack` 集群 (你也可以将这个字段理解为数据中心，今后部署多地冗灾体系)
  - 第二字段 表示集群 ，目前主要在第一层虚拟化部署集群:

    - ``b`` : base 基础服务
    - ``o7k`` : OpenStack (模仿Kubernetes缩略方法，将中间7个字母简写为 ``7`` ，所以 OpenStack 缩写成 ``o7k``)
    - ``k8s`` : Kubernetes
    - ``o7t`` : OpenShift

  - 第三字段 表示节点身份:

    - ``m`` : 集群管控节点 (manager)
    - ``n`` : 集群工作节点 (node)
    - ``store`` : 基础服务存储 

      - :ref:`gluster`

    - ``data`` : 基础服务数据服务:

      - :ref:`ceph`
      - :ref:`redis`
      - :ref:`etcd`
      - :ref:`kafka`
      - :ref:`rabbitmq`
      - :ref:`mysql`
      - :ref:`pgsql`

  - 第四字段 表示节点序号数字

网络规划
~~~~~~~~~

我所使用的 :ref:`hpe_dl360_gen9` 有2个4口网卡:

- 服务器主板板载 ``4口`` Broadcom BCM5719千兆网卡
- ``FlexibleLOM Bay`` ``4口`` Intel I350千兆网卡 - 支持 :ref:`sr-iov`

由于独立的 ``4口`` Intel I350千兆网卡 支持 SR-IOV ，所以我规划:

- 每个Intel I350 ( ``igb`` ) 支持 ``7个`` SR-IOV 的 VF，共计可以实现 ``32 个`` 网卡 ( ``4x8`` ) ，分配到 :ref:`kubernetes` 和 :ref:`openstack` :

  - 2块 Intel I350 ( ``igb``  ) 用于 ``z-k8s`` 集群(Kubernetes): k8s运行节点(VM) ``z-k8s-n-1`` 到 ``z-k8s-n-4`` ，每个node分配4个 sr-iov cni ，其余节点 ``z-k8s-n-5`` 到 ``z-k8s-n-10`` 则使用常规 ``virtio-net`` ； 通过标签区别节点能力 (此外 :ref:`vgpu` 也只分配2个node，以验证k8s调度)
  - 2块 Intel I350 ( ``igb``   ) 用于 ``z-o7k`` 集群(OpenStack): 同样也分配4个node

绝大多数虚拟机的网络都连接在 ``br0`` 上，通过内部交换机实现互联 ( 后续学习 Open vSwitch (OVS) )，以内核虚拟交换机实现高速互联:

- 所有虚拟机都通过 ``br0`` 访问 :ref:`ceph` 基础数据层，数据通路走内核，不经过外部交换机
- 少量外部物理硬件(如 :ref:`pi_cluster` 以及我用笔记本模拟都KVM节点)，通过 :ref:`cisco` 交换机访问 ``br0`` 连接的虚拟机，如 :ref:`ceph` 虚拟化集群

私有云域名规划
~~~~~~~~~~~~~~~~

私有云是我在一台 :ref:`hpe_dl360_gen9` 物理服务器( ``zcloud`` ) 上部署的云计算环境，我将这个环境作为 ``staging`` 环境来运行，所以域名设置为 ``staging.huatai.me`` ：

- 在最初部署环境中，为了快速完成整体架构，我采用 :ref:`dnsmasq` 和 :ref:`iptables_ics` 来实现 :ref:`priv_dnsmasq_ics`
- 后续不断完善迭代，我将会升级采用 :ref:`bind` 重构整个DNS系统

虚拟化的层级部署
=================

数据存储层(data)
----------------------

在 ``zcloud`` 底层虚拟化上，我采用完全手工方式构建最基础的存储数据的虚拟机:

- ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` 是通过 :ref:`ovmf` 虚拟机pass-through读写 :ref:`samsung_pm9a1` 的高性能存储虚拟机

  - 所有依赖高速存储的基础服务，如 :ref:`ceph` / :ref:`mysql` / :ref:`redis` 等都部署在这3个虚拟机内部
  - 这3个虚拟机只依赖 :ref:`kvm` 和 :ref:`libvirt` ，并且在物理主机启动时自动启动运行，提供基础数据服务
  - :ref:`ceph` 是最关键的存储服务: 除了 ``数据存储层`` 这3台虚拟机直接存储数据之外，其他虚拟机(包括第一层虚拟化和第二层虚拟化)的磁盘镜像全部存储在 :ref:`ceph` 之中

    - 你可以将这个数据存储层 Ceph 看成类似于阿里云的 ``盘古`` 分布式存储，开天辟地: 这样所有其他虚拟机都不需要占用本地磁盘(事实上作为 ``zcloud`` 主机的系统盘 ``ssd`` 空间非常狭小)
    - 分布式存储提供了网络共享访问，同时提供了数据镜像容灾，这样运行的虚拟机可以在网络上不同的计算节点迁移: 例如，我可以在网络中加入我的笔记本或者台式机来模拟一个物理节点，共享访问Ceph存储，实现把虚拟机热迁移过去，从而减轻服务器的压力


  - 在磁盘上构建 :ref:`linux_lvm` LVM 卷用于存储数据 - ``vg-data`` (300G)

    - :ref:`etcd` 存储在 ``vg-data/lv-etcd``
      
      - :ref:`coredns` 采用 :ref:`etcd` 存储数据
      - :ref:`rook` 采用 :ref:`etcd` 存储配置，在 ``z-k8s`` 中实现微型 :ref:`ceph` / :ref:`cassandra` / :ref:`nfs`
      - :ref:`m3` 采用 :ref:`etcd` 存储数据，构建分布式 :ref:`prometheus` metrics 存储
      - :ref:`kubernetes` 采用 :ref:`etcd` 存储数据

- ``z-b-store-1`` / ``z-b-store-2`` / ``z-b-store-3`` 是直接访问服务器上3块 2.5" SSD，基于 :ref:`gluster` 的 :ref:`stratis` 存储，运行 :ref:`ovirt` 同时提供 :ref:`ceph` 的 geo-replication

  - 数据备份和恢复
  - 近线数据存储，后续考虑实现一个容灾系统模拟
  - 使用 :strike:`企业级SSD` 较好的消费级大容量SSD(2T)

- ``z-b-arch-1`` / ``z-b-arch-2`` / ``z-b-arch-3`` 是直接访问服务器上3块 2.5" 机械硬盘，提供 :ref:`gluster` 存储服务以及自动化归档备份 - 方案待定

  - 采用大容量机械硬盘(叠瓦盘)(8T)，存储为主，较少修改，作为归档数据
  - 双副本，实现基于磁盘的数据归档方案(磁带机维护成本高)
  - 采用 :ref:`linux_bcache` 来加速(利用SSD的部分容量)
  
第一层虚拟化
-----------------

- ``z-o7k`` 系列构建 :ref:`openstack` 集群

  - 采用 :ref:`ubuntu_linux` :strike:`20.04` 22.04 部署
  - 启用 :ref:`kvm_nested_virtual` 实现第二层虚拟化

- ``z-o3t`` 系列构建 :ref:`ovirt` 集群

  - 采用 :ref:`centos` 8 部署
  - 启用 :ref:`kvm_nested_virtual` 实现第二层虚拟化
  - 实现 :ref:`stratis` 存储

- ``z-k8s`` 系列构建 :ref:`kubernetes` 集群

  - 采用 :ref:`ubuntu_linux` 22.04 部署
  - 采用 :ref:`vgpu` 将 :ref:`tesla_p10` 输出到多个工作节点虚拟机，实现分布式 :ref:`machine_learning`
  - 采用 :ref:`rook` 来部署一个集成到Kubernetes的 :ref:`ceph` 集群

第一层虚拟化的虚拟机也采用手工方式部署，部署用于构建集群的虚拟机都采用 ``数据存储层`` 的 :ref:`ceph` ``RBD`` ，不使用任何本地磁盘: 虚拟机计算节点可以任意迁移。

第二层虚拟化
--------------

- 基于第一层虚拟化部署的 :ref:`openstack` 和 :ref:`ovirt` 实现自动化部署

Kubernetes私有云
==================

从集群稳定性和扩展性来说，推荐采用 :ref:`ha_k8s_external` 部署模式：

- kubernetes的管控组件和etcd分别部署在不同服务器，单节点故障影响从1/3降低到1/6
- 运维管理简化，拓扑清晰
- etcd和apiserver都是管控平面非常消耗资源的组件，通过分离etcd部署提升了管控平面整体性能

但是，我的私有云由于资源限制，只有3台物理服务器，所以我采用了一种混合虚拟化和容器的部署架构：

- 管控平面服务器(kubernetes master)运行在KVM虚拟机(每个物理服务器上运行一个虚拟机)

  - 共计3台KVM虚拟机，对外提供apiserver服务(直接通过 :ref:`libvirt` 运行KVM虚拟机，简单清晰)
  - 物理网络连接Kubernetes worker节点，管理运行在物理节点上的worker nodes
  - 可以节约服务器占用，同时KVM虚拟机可以平滑迁移

- etcd服务器运行在物理主机上

  - etcd是整个kubernetes集群的数据存储，不仅需要保障数据安全性，而且要保证读写性能

.. note::

   最初我考虑采用OpenStack来运行Kubernetes管控服务器，但是OpenStack构建和运行复杂，Kubernetes依赖OpenStack则过于沉重，一旦出现OpenStack异常会导致整个Kubernetes不可用。

   基础服务部署着重于稳定和简洁，依赖越少越好：并不是所有基础设施都适合云化(OpenStack)或者云原生(Kubernetes)，特别是BootStrap的基础服务，使用物理裸机来运行反而更稳定更不容易出错。

- Kubernetes的worker nodes直接部署在3台物理服务器上

  - 裸物理服务器运行Docker容器，可以充分发挥物理硬件性能
  - Ceph (:ref:`ceph`) 直接运行在物理服务器，提供OpenStack对象存储和Kubernetes卷存储，最大化存储性能
  - Gluster (:ref:`gluster`)直接运行在物理服务器，提供oVirt(:ref:`ovirt`)的虚拟化存储以及虚拟机和Kubernetes的NFS文件存储、数据归档
  - 网络直通，最大化网络性能

.. note::

   整个似有网络仅使用 ``3台物理服务器`` 。如果你缺少服务器资源，也可以采用KVM虚拟机来实践部署，即采用完全的OpenStack集群(单机或多机都可以)，在OpenStack之上运行Kubernetes。

OpenStack私有云
==================

OpenStack和Kubernetes共同部署在3台物理服务器上，底层的基础服务是共享的：

- :ref:`etcd`
- :ref:`vitess`
- :ref:`rabbitmq`
- :ref:`kafka`
- :ref:`ceph`
- :ref:`gluster`

