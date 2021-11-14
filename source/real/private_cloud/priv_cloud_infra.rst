.. _priv_cloud_infra:

============
私有云架构
============

私有云拓扑架构图
==================

2021年10月，我购买了 :ref:`hpe_dl360_gen9` 来实现完整的云计算模拟，规划是采用一台二手服务器:

- 通过 :ref:`kvm_nested_virtual` 运行大量的一级KVM虚拟机，一级KVM虚拟机作为运行 :ref:`openstack` 的物理机，部署一个完整的OpenStack集群

  - 物理服务器运行 :ref:`cockpit` 可以集成 :ref:`stratis` 存储，以及 :ref:`ovirt` ，所以在第一层虚拟化上，可以不用自己手工部署 :ref:`kvm` ，而是集成到 oVirt
  - 通过oVirt来管理第一层虚拟机，虚拟机开启嵌套虚拟化，这样可以同时学习oVirt的管理，体验不同于OpenStack的轻量级虚拟化管理平台
    
    - oVirt支持 :ref:`gluster` 管理，可以方便在底层部署 GlusterFS

- 在一级虚拟机中运行 :ref:`kubernetes` 模拟裸机的K8S集群
- 在OpenStack中部署运行大量二级虚拟机，按需运行，模拟云计算的弹性以及计费和监控
- OpenStack中的二级虚拟机内部再部署一个 :ref:`kubernetes` 集群，模拟云计算之上的K8S集群，结合 HashiCorp 的 Terraform 来实现全链路的自动化部署
- 附加：在DL360物理服务器上运行一个精简的Docker容器来做日常开发学习

.. figure:: ../../_static/real/private_cloud/real_cloud.png
   :scale: 80

多层次虚拟化服务器分布
------------------------

.. csv-table:: zcloud服务器部署多层虚拟化虚拟机分配
   :file: priv_cloud_infra/hosts.csv
   :widths: 10, 10, 10, 10, 10, 10, 10, 30
   :header-rows: 1

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

    - ``data`` : 技术服务数据服务:

      - :ref:`ceph`
      - :ref:`redis`
      - :ref:`etcd`
      - :ref:`kafka`
      - :ref:`rabbitmq`
      - :ref:`mysql`
      - :ref:`pgsql`

  - 第四字段 表示节点序号数字

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

