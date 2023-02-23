.. _intro_ceph:

===================
Ceph存储介绍
===================

Ceph提供了统一的存储解决方案:

- 对象存储
- 块设备
- 文件系统

Ceph存储集群的组成:

- Ceph Monitor
- Ceph Manager
- Ceph OSD(Object Storage Daemon)
- Ceph MDS(Metadata Server): 对外提供Ceph文件系统需要MDS

组件功能说明
================

- 监控器(Monitors): ``ceph-mon`` 维护集群状态地图(map)，包括监控地图(monitor map)，管理器地图(manager map), OSD地图，MDS地图，以及 ``CRUSH`` 地图。这些地图是Ceph daemons相互协作所需的关键集群状态。Monitors也负责管理daemon和client之间的认证。为了满足冗灾和高可用，通常需要至少 ``3个`` monitors。
- 管理器(Managers): ``ceph-mgr`` 是负责跟踪运行时metrics以及当前Ceph集群状态，包括存储使用，当前性能metrics以及系统负载。Ceph Manager daemons也承载基于python的模块来管理和输出Ceph集群信息，包括一个Ceph Dashboard的WEB和REST API。为了满足管理和高可用，至少需要 ``2个`` managers。
- Ceph OSDs: ``ceph-osd`` 是对象存储服务，存储了数据，处理数据复制，恢复，重平衡，以及通过检查其他Ceph OSD服务的心跳来提供一些监控信息给Ceph Monitors和Managers。为了满足冗灾和高可用，至少需要 ``3个`` Ceph OSDs。
- MDSs: ``ceph-mds`` 存储了Ceph File System的元数据信息(Ceph块设备和对象存储不需要MDS)。Ceph元数据服务器允许POSIX文件系统用户执行基本命令(例如 ``ls`` , ``find`` 等)

Ceph是使用逻辑资源池的对象来存储数据。通过 ``CRUSH`` 算法，Ceph可以计算出在哪里存储对象，以及计算出使用哪个Ceph OSD服务来存储 ``palcement group`` 。这个 ``CRUSH`` 算法确保了Ceph存储集群伸缩性，重平衡以及动态恢复。

进一步
=========

- :ref:`ceph_recommend`
- :ref:`ceph_arch`

参考
=======

- `INTRO TO CEPH <https://docs.ceph.com/en/pacific/start/intro/>`_
