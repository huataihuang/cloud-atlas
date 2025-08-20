.. _intro_distributed_system:

============================
分布式系统简介
============================

MIT6.824: Distributed System课程
=================================

:ref:`csdiy` 参考了 `CS自学指南 <https://csdiy.wiki>`_ ，其中介绍 ``分布式系统`` 有一个非常经典的 ``MIT6.824`` 课程，是由传奇黑客 `Robert Morris <https://zh.wikipedia.org/wiki/罗伯特·泰潘·莫里斯>`_ (互联网第一个蠕虫病毒 ``Morris`` 开发者，曾经创办Viaweb，也是YCombinator联合创始人) 在麻省理工主讲的明星课程。

该课程有20节课，4个实验，实验基于 :ref:`golang` 完成。每节课都精读一篇分布式领域的经典论文，并由此传授分布式系统设计与实现的重要原则和关键技术。同时其课程 Project 也是以其难度之大而闻名遐迩，4 个编程作业循序渐进带你实现一个基于 Raft 共识算法的 KV-store 框架，让你在痛苦的 debug 中体会并行与分布式带来的随机性和复杂性。( 参考 `MIT6.824: Distributed System 课程简介 <https://csdiy.wiki/并行与分布式系统/MIT6.824/>`_ )

由于我现今工作围绕 :ref:`kubernetes` ，其关键组件 :ref:`etcd` 即是 Raft KV存储，所以理解分布式系统对于工作会有比较大的帮助。 :ref:`distributed_system` 将基于 ``MIT6.824`` 课程学习和实践来完成。

`肖宏辉 <https://www.zhihu.com/people/xiao-hong-hui-15>`_ 翻译了 `MIT 6.824 Distributed Systems (Spring 2020) <https://www.youtube.com/watch?v=cQP8WApzIQQ&list=PLrw6a1wE39_tb2fErI4-WkMbsvGQk9_UB>`_ 课程视频 `MIT6.824中文文字版 <https://mit-public-courses-cn-translatio.gitbook.io/mit6-824/>`_ ，可以方便对照学习。

学习思路
==========

- 先阅读 `MIT6.824中文文字版 <https://mit-public-courses-cn-translatio.gitbook.io/mit6-824/>`_ ，对课程内容有一个初步 "中文化" 理解
- 然后观看油管上的 `MIT 6.824: Distributed Systems <https://www.youtube.com/@6.824>`_ 原版课程，通过英文学习(视频CC英文字幕)，以便能够加深理解(视频以及英文能够帮助我更好理解技术)
- 结合 :ref:`golang` 学习，对课程作业进行编程，一方面加深分布式原理理解，一方面加深go语言编程能力

分布式系统的驱动力和挑战
==========================

我们使用分布式的原因(驱动力):

- 需要更高的计算性能(并行计算相当于有更多的cpu、内存和存储)
- 分布式系统能够提供容错(tolerate faults)
- 有些计算天然具备空间物理分布
- 分布式系统能够提供安全隔离(限制出错域)

分布式系统的问题(挑战):

- 并发执行带来并发编程和复杂交互的问题，以及时间依赖问题(同步、异步)
- 分布式系统带来故障的分散以及复杂的组成，故障难以排查;并且规模带来了罕见问题的放大(硬件故障概率)

  - 系统容错性(availability)

    - 使用非易失存储(non-volatile storage)来避免电力故障的数据丢失: 使用checkpoint或log，以便电力恢复能够从系统最新状态继续推进计算
    - 使用数据复制(replication)

  - 系统自我可恢复性(recoverability)

- 分布式系统实际上很难达到性能的优化(需要极其小心设计和构建，否则性能很难达到理想的状态)
- 分布式系统的可扩展性(Scalability): 当web服务器扩展达到一定规模后，系统的瓶颈可能转转移到数据库或者存储，通过数据库分片和分布式存储来提升性能
- 分布式系统带来数据一致性(Consistency)的问题

  - 强一致性的代价很高: 通讯代价(特别是需要构建跨地区的分布式系统，确保强一致性会带来系统性能的急剧下降)
  - 弱一致性特别适合现实中超长距离的分布式系统

MapReduce
=============
