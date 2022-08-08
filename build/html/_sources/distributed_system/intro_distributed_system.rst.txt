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


