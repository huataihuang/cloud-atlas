.. _spark_vs_flink:

================
Spark vs. Flink
================

Flink(Blink)
============

综合各方信息来看:

- Flink(Blink)在流式数据处理上有很大但性能优势，并且随着数据量的增大优势更为明显。
- Blink的性能比Flink更为优化，但是由于Blink主要是在阿里内部使用，和公司业务紧密结合
- Flink注重流处理能力，通过流水线数据传输实现了低延迟的流处理
- Flink使用经典的Chandy-Lamport算法，能够在满足低延迟和低failover开销基础上，完美解决exactly once的目标
- Flink提供SQL/tableAPI两种API，统一了批和流的query层

阿里的Flink(Blink)
-------------------

每年阿里的双十一大促，实时销售数据GMV大屏就是实时计算的典型案例。阿里的Blink针对存储、调度等底层优化做了定制，也对Runtime做了个性化优化，称为Blink Runtime。目前基于Blink SQL，阿里推出了streamCompute流计算平台，当前阿里的搜索、推荐、广告等大部分核心流计算业务都是通过streamCompute平台来提供服务。

阿里的Flink优化：

- 大规模部署: 将Flink每个集群一个JobMaster改造成每个Job拥有自己的Master，增强了Job隔离
- 引入ResourceManager和JobMaster协作，实时动态调整资源
- 改进Flink的checkpoint方式提供Incremental Checkpoint，只需要存储增量的state变化数据，使得每次checkpoinit的数据量大幅减少，降低了failover延迟

- 异步IO数据读取框架，允许异步多线程读取数据，提高CPU资源利用率提升计算吞吐：

  - 当数据请求从外部存储返回后，计算系统会调用callback方法处理数据

    - 如果数据计算不需要保序，数据返回之后就会快速经过计算发出
    - 如果用户需要数据的计算保序时，使用buffer暂时保存先到的数据，等前部数据全部到达后再批量地发送

Spark
=======

Spark当前正在快速向AI方向发展，包括内置的mllib。深度学习起来之后，Spark立即在2.2.x之后发力,开发了一套生态辅助系统，比如Spark deep Learning,Tensorframes, GraphFrames等等。目前发布的Spark 3.0对AI更加友好，包括CPU/GPU的管理，k8s backend，数据交换(Spark - AI框架)的提速，内部Barrier API的等进一步的完善，显然让Spark在AI领域进一步保持优势。

Flink依然聚焦总流、批处理，Flink的AI主要是集成而不是自身实现，所以瓶颈主要存在数据交换和AI框架上。

参考
=====

- `漫谈加持Blink的Flink和Spark <https://www.jianshu.com/p/db706102f313>`_
- `一文揭秘阿里实时计算 Blink 核心技术：如何做到唯快不破？ <https://toutiao.io/posts/bnjiuk/preview>`_ - 阿里巴巴高级技术专家大沙分享
