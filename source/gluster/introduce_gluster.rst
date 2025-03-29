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

发布周期
==========

Gluster目前主发布(major release)周期约1年，次要更新(minor release)则每几个月发布一次。主发布版本通常包含新功能以及bug修复，而次要更新则通过bug修复为主版本提高稳定性。主版本每1年发布一次，并且在接下来12个月提供该主版本的次要更新，然后就不再维护(EOL, End-Of-Life)。强烈建议用户采用依然在维护的主版本，以便能够接收到bug修复。

.. note::

   详细的Gluster发布周期以及当前状态请参考 `Gluster Release Schedule <https://www.gluster.org/release-schedule/>`_

参考
========

- `Getting started with GlusterFS - Introduction <https://docs.gluster.org/en/latest/Administrator%20Guide/GlusterFS%20Introduction/>`_
- `Gluster Release Schedule <https://www.gluster.org/release-schedule/>`_
- `Planet Gluster <https://planet.gluster.org/>`_ 提供了不少技术文章，不过已经有2年没有更新了
