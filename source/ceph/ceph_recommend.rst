.. _ceph_recommend:

======================
Ceph部署软硬件推荐
======================

硬件
==========

Ceph设计成使用通用硬件，可以用来构建和维护PE级别数据集群。但是，对于大型数据系统，需要进行设计硬件，保证各个硬件组件的平衡协调以及软件合理部署，这样才能避免故障失效以及潜在的性能问题。

CPU
-------

不同的Ceph角色需要不同的硬件:

- CephFS meta服务器是CPU敏感的，也就是需要部署较为强大的硬件(多核处理器或更好的CPU)，并且高主频可以提高性能。
- Ceph OSDs运行RADOS服务，用来计算CRUSH数据分发以及数据复制(维护集群地图副本)，所以需要大量的处理器能力

  - 刚开始阶段(轻量负载)可以采用每个OSD分配1个CPU core
  - 随着RBD提供给VM使用负载逐渐加大，则分配2个CPU core给OSD
  - 通过监控观察业务发展情况可以逐渐扩展OSD的CPU core

- Monitor/Manager节点不需要大量的CPU计算资源，所以可以采用低配置处理器

- 为了避免CPU资源竞争，建议使用分离的的服务器来运行CPU敏感的进程

内存
-------

简单来说，内存越多越好:

- 对于普通集群，Monitor/Manager节点最好配备 ``64GB`` 内存；对于大型的部署数百个OSDs的集群，则最好给Monitor/Manager节点分配128GB内存

  - Monitor/Manager节点需要使用内存和集群规模有关: 当发生拓扑变化或者需要recovery时，会消耗远比稳定状态操作更多的内存，所以需要为尖峰使用规划好内存:

    - 对于非常小的集群，32GB足够；
    - 随着集群扩展，例如300个OSDs则需要配备64GB；
    - 随着集群规模进一步增长，更多的OSDs会要求配置128GB内存
    - 需要考虑tunning设置: ``mon_osd_cache_size`` 或 ``rocksdb_cache_size``

- 对于典型的BlueStore OSDs，默认内存分配4GB; 对于长期运行的操作系统和管理任务(例如监控和metrics)会在故障恢复时消耗更多内存: 每个BlueStore OSD建议分配8GB以上内存

- 对于meatadata服务器( ``ceph-mds`` )，大多数情况下至少需要1GB内存，实际需要配置的内存和需要考虑缓存的数据有关

BlueStore内存
----------------

待完成

数据存储
------------

HDD硬盘
~~~~~~~~~

SSD
~~~~~~

网络
----------

- 应该至少使用 ``10Gbps+`` 网络 (我的测试环境远达不到，只能作为方案验证)

具体待完善

Ceph部署的最小硬件要求
-------------------------

操作系统建议
===============

Linux内核
----------

- 如果使用Ceph内核客户端来映射RBD块设备或者挂载CephFS，建议使用 ``稳定`` 或 ``长期维护`` 内核系列:

- RBD建议内核:

  - 4.19.z
  - 4.14.z
  - 5.x

- CephFS建议内核：至少 4.x ，建议使用最新的稳定Linux内核

.. note::

   - 从Luminous版本(12.2.Z)开始，建议采用 ``BlueStore`` ；早期版本则建议使用 :ref:`xfs` 作为 ``Filestore``
   - ``btrfs`` 可能没有严格测试，建议不要采用

参考
=====

- `Ceph Hardware Recommendations <https://docs.ceph.com/en/pacific/start/hardware-recommendations/>`_
- `Ceph OS Recommendations <https://docs.ceph.com/en/pacific/start/os-recommendations/>`_
