.. _glusterfs_crash_test:

====================
GlusterFS崩溃测试
====================

部署GlusterFS是非常轻而易举的，甚至是最容易部署的分布式文件系统。然而，像所有看似简单却功能强大的 :ref:`distributed_system` 一样，在 `rabbit hole <https://www.zhihu.com/question/268877435>`_ 中是无数艰辛的技术组合。

在 :ref:`deploy_centos7_gluster6` 生产环境是否能够满足苛刻的性能和稳定性要求，我们需要精心设计测试和验证方案，并通过迭代测试来不断完善部署和运维方案。

冗灾测试思路
===============

- 任何 ``单个`` 节点的重启都需要保证集群正常工作，数据读写正常
- 多个节点重启不出现数据丢失
- 当出现内存泄漏，Gluster集群不因出现crash - 验证
- 模拟磁盘撑爆情况下，Gluster集群异常情况下不出现数据损坏
- 模拟网络异常(阻塞、拥堵)情况下Gluster集群不应出现数据损坏

.. note::

   `Glusterfs crash test. Our experience <https://cloud.croc.ru/en/blog/stay-tuned/glusterfs-crash-test-our-experience/>`_ 介绍了其方案使用的参数组合，但是实际使用需要对每个参数意义进行核对并做实际验证。后续我在性能优化部分将详述我的实践经验。

   有关加速客户端故障恢复，可能需要部署负载均衡来实现客户同步卷信息。


参考
======

- `Glusterfs crash test. Our experience <https://cloud.croc.ru/en/blog/stay-tuned/glusterfs-crash-test-our-experience/>`_
