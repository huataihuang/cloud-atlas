.. _gluster_underlay_filesystem:

=======================
Gluster存储底层文件系统
=======================

GlusterFS底层需要采用操作系统提供的文件系统，有以下推荐方案:

- 直接使用 :ref:`xfs` 
- 结合 :ref:`linux_lvm` 使用 :ref:`xfs`

  - 对多磁盘采用 :ref:`mdadm` 组建 :ref:`linux_software_raid` ，然后在软RAID之上构建 :ref:`linux_lvm`
  - 或者采用 ref:`lvmraid` 实现 :ref:`linux_software_raid`

- 采用 :ref:`zfs` 同时兼具卷管理和文件系统功能

为何需要卷管理
================

现代服务器的存储规模惊人， :ref:`nvme` 释放了服务器端的存储能力，可以高密度部署大量的存储磁盘，这也为 GlusterFS 带来的维护挑战:

- Gluster是基于服务器来实现文件分布的: 对于一个服务器上多块磁盘，虽然可以通过指定 ``brick`` 顺序来构建 :ref:`distributed_replicated_glusterfs_volume` ( :ref:`deploy_centos7_gluster11` 中使用了每个服务器12块磁盘 )，但是如果一个分布式多副本GlusterFS卷在一个服务器上有过个 ``brick`` 会导致难以扩展也难以收缩:

  - 文件副本是按照 ``brick`` 的顺序来分布的， :ref:`add_centos7_gluster11_server` 的多块 ``brick`` 会 **堆积** 在 ``Bricks`` 最后，意味着文件hash之后，有可能多个副本落在同一台服务器上带来容灾隐患
  - 如果某个服务器宕机，删除服务器也存在相似问题，如果服务器数量减少，执行 ``gluster volume rebalance`` 以及后续文件副本的分布都可能落在同一个物理服务器

- 从GlusterFS的精简的hash设计来看，最理想的状态是: 每个GlusterFS Volume在每个服务器上只有一个 ``brick`` ，以确保文件副本hash能够分布到不同的服务器上获得高可用

  - 随着存储技术发展，单台服务器的 :ref:`nvme` 数量突飞猛进，如果不使用 :ref:`linux_lvm` 将大量的磁盘整合成存储池，就会面对需要人工来规划和管理 GlusterFS volume 和磁盘的对应关系
  - 如果GlusterFS volume卷数量有限，甚至不及服务器上的磁盘数量，那么直接使用 :ref:`xfs` 就会导致要么不能充分使用存储磁盘，要么就是限制了GlusterFS的伸缩性(见上文分析)

实践
=======

- :ref:`deploy_centos7_gluster11_lvm_mdadm_raid10`
