.. _introduce_gluster:

======================
Gluster分布式存储简介
======================

Gluster
========

Gluster是一个提供了从多个服务器聚合磁盘存储资源成为一个单一全局命名空间的高度可伸缩、分布式文件系统。

GlusterFS作为一种兼容OpenStack和oVirt集成的分布式文件系统，可以作为IaaS的基础存储系统。GlusterFS具有大型和活跃的社区支持并且通过libgfapi接口可以原生支持QEMU。

Gluster优点
------------

- 可扩展到数PB
- 支持数以千计的客户端
- POSIX兼容
- 使用通用硬件
- 可以使用支持扩展属性的任何磁盘文件
- 可以通过工业标准协议，如NFS和SMB协议访问
- 提供了复制、限额、全局复制(geo-replication)、快照和数据腐败检测(bitrot detection)
- 支持不同负载的优化
- 开源

参考
========

- `Getting started with GlusterFS - Introduction <https://docs.gluster.org/en/latest/Administrator%20Guide/GlusterFS%20Introduction/>`_
