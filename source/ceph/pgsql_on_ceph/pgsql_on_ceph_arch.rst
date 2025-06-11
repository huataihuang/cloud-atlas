.. _pgsql_on_ceph_arch:

=================================
Ceph 上运行PostgreSQL架构
=================================

.. warning::

   不建议在分布式存储上运行数据库:

   - 现代数据库有内置的replica模式提供了数据灾备和并发查询扩展能力，所以不需要依赖底层的数据冗余来提供安全保障
   - 分布式存储天然的网络和同步副本开销使得IOPS性能比直连存储有数量级的降低，浪费了裸存储的性能

   所以，我推荐采用更为成熟和更好性能的数据库原生replica模式。

   不过，对于没有能力维护数据库集群的个人和小企业用户，在分布式存储上运行单机版数据库还是有价值的。所以，我还是准备参考网上的一些资料，自己来完成分布式存储上数据库运行的部署、调优和监控等工作。

我偶然看到在Ceph上运行MySQL的提问，想到自己在部署实践中可以挑战和验证，所以先挖坑，待后续环境就绪后实践。待续...

参考
=====

- `Reddit讨论: MySQL on Ceph RBD <https://www.reddit.com/r/ceph/comments/12m218e/comment/jgo8b0m/>`_ 其中的建议以及验证测试方法可以参考
- `Massive MySQL® database performance on Ceph RBD <https://www.micron.com/about/blog/company/insights/massive-mysql-database-performance-on-ceph-rbd>`_ micron公司做了一个验证Ceph IOPS的实验可以参考参考，我觉得有优化的空间(以现在飞速发展的存储技术)
- `Ceph RBD is plenty fast for having a database on... was able to get better performance than fibre channel or NFS to a NetApp using Ceph, ran some nice large Oracle instances on VM's on top of OpenStack backed by Ceph RBD. <https://news.ycombinator.com/item?id=13240323>`_ Hacker News讨论中有人介绍了Supermicro的 「IOPS optimized Ceph storage SKU's」，不过这个链接现在转跳到 `Supermicro Software-Defined Storage and Memory Solutions <https://www.supermicro.org.cn/en/solutions/software-defined-storage>`_ 集中了不同厂商的分布式存储解决方案(可以借鉴参考)

