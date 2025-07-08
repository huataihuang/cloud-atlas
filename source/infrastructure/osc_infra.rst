.. _osc_infra:

===============================
OSC(俄亥俄超算中心)架构
===============================

俄亥俄州立大学的超级计算机中心，简称 OSC (Ohio Supercomputer Center, 俄亥俄超算中心)，不仅提供教育使用，也对外提供商业服务。 `OSC官方网站 <https://www.osc.edu/>`_ 提供了

2022年OSC启用了 "Ascend" HPC，采用NVIDIA的GPU构建了 :ref:`machine_learning` 以及大数据分析的高性能计算机系统:

- Dell PowerEdge服务器，使用48个AMD EPYC处理器和96个NVIDIA A100 80GB Tensor Cores  GPU (NVIDIA NVLink 和 InfiniBand 连接)

  - 每个节点使用4个A100

OSC提供了非常详细的 `OSC快速起步HOWTO <https://www.osc.edu/resources/getting_started/howto>`_ 系列文章，从中可以了解超算中心提供的服务以及管窥底层使用的软硬件组合，为自己学习类似架构提供了指南。

操作系统
==========

俄亥俄超算中心使用的操作系统是 RHEL 9 (2025年4月24日-28日从RHEL 8升级到RHEL 9)

计算
======

根据 `OSC Cluster Computing <https://www.osc.edu/services/cluster_computing>`_ 可以了解超算中心的硬件构成和规模

.. note::

   其实OSC超算中心集群的规模还比不上我之前在支付宝参与运维的 :ref:`kubernetes` 集群规模，但是我觉得超算中心提供了一个很好的构建样本，特别是公开了使用到的硬件、软件堆栈，很有参考学习价值。

网络
=======

存储
============

.. note::

   `OCS Storage Documentation <https://www.osc.edu/supercomputing/storage-environment-at-osc/available-file-systems>`_ 提供了存储规划信息可以参考

- Home目录: ``/users/project/userID`` 使用NetApp
- 项目目录: ``/fs/ess`` 使用GPFS
- 本地磁盘: ``/tmp`` 本地磁盘通常速度快无数据安全冗余
- 临时目录(全局): ``/fs/scratch`` 使用GPFS
  
从 `OSC Storage Hardware <https://www.osc.edu/supercomputing/storage-environment-at-osc/storage-hardware>`_ 说明:

- 主要文件存储使用了NetApp公司的NAS，为用户提供 home 目录(1.9PB容量, 40GB/s带宽)

  - 这个架构类似我模拟实现 :ref:`freebsd_zfs_sharenfs` 为客户端提供home存储
  - :ref:`nfs_v4` 能够提供安全且高性能的网络存储，可以通过开源集成 :ref:`samba` AD结合 :ref:`nfs` 来实现认证用户的存储管理

- IBM Elastic Scale System(ESS)，即IBM Storage Scale提供项目和临时存储(project and scratch storage)，并提供了不同级别的数据保护(大约16PB容量)

  - IBM Storage Scale底层是IBM的GPFS，提供集群分布式存储

    - 支持多种协议NFS,SMB，即NAS服务
    - 提供HDFS?
    - 使用分布式metadata，包括目录树
    - 分布式锁，实现了POSIX文件系统语义
    - 分区感知: 当发生网络故障时，GPFS被分为ieduoge分区，能够保持最大分区依然提供服务以确保部分主机继续工作

  - 开源复刻方案:

    - 使用 :ref:`pnfs` 可以实现多头并发提供服务

      - pNFS支持不同存储后端(disk,fibre channel,iSCSI)以及对象存储: 实际的数据冗余由后端实现，比较简单的可以使用ZFS RAIDZ，复杂的就使用 :ref:`ceph` 提供对象存储同时提供多副本块容灾
      - 使用 :ref:`gluster` 实现文件级别分布式存储，也就是 :ref:`nfs-ganesha_over_glusterfs`

- 两台IBM磁带机机器人负责备份和归档(以下为2022年数据)

  - 总共 23.5 PB数据存储容量，大约在磁带中备份了14PB，
  - 通过使用下一代磁带介质和驱动器预计今后会扩容到141PB


虚拟化和容器
==============

由于超算目标是榨干计算机的每一丝计算能力，再加上现在 :ref:`machine_learning` ( :ref:`llm` )对GPU计算能力的渴求，所以超算通常直接使用裸机运行:

- 少量特定应用会使用虚拟机(也许是历史遗留软件?)
- 由于容器技术对性能损耗极少，我估计超算会引入类似 :ref:`kubernetes` 这样的容器调度系统(我猜)

参考
=======

- `OSC Storage Hardware <https://www.osc.edu/supercomputing/storage-environment-at-osc/storage-hardware>`_
- `reddit: 我们是俄亥俄超级计算机中心，欢迎提问！ <https://www.reddit.com/r/IAmA/comments/2mm3yb/we_are_the_ohio_supercomputer_center_ask_us/?tl=zh-hans>`_ 2012年reddit上OSC的一个问答讨论，虽然太旧了，不过也可以看看十多年前的超算中心
