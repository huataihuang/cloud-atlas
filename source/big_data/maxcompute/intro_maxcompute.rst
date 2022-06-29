.. _intro_maxcompute:

======================
MaxCompute(ODPS)简介
======================

阿里云的MaxCompute，是大数据计算服务，原先名为 ODPS ，提供PB级别数据仓库，用于分析海量数据。可以对标开源的 MapReduce 解决方案 - Hadoop/Hive 

阿里云提供了 `MaxCompute学习途径 <https://www.alibabacloud.com/zh/getting-started/learningpath/maxcompute>`_ 指导用户使用阿里云的大计算产品，不过只是help的一些选择汇总，感觉帮助不大。如果需要感性一些的认识，不如参考 `MaxCompute 产品教程 <https://www.alibabacloud.com/help/zh/maxcompute/latest/tutorials>`_ 提供了一个网站运营分析的案例，方便理解MaxCompute的实现流程。

MaxCompute概述
=================

MaxCompute(ODPS)：

- 100GB以上规模数据存储和计算
- 用于数据仓库和BI分析，网站日志分析、电子商务交易分析、用户特征分析等场景
- 集成 :ref:`spark` 引擎
- 集成OSS(阿里云提供的分布式对象存储)和Hadoop HDFS访问
- 集成流计算数据写入(我理解是集成flink的数据)

.. note::

   我只选择了部分功能摘要，主要是能够结合开源大数据计算分析，以便将ODPS作为输入。我期望实现基于ODPS的数据进行spark计算，odps作为数据汇总，spark作为AI计算平台

   我的感觉是阿里云的工程集成能力较强，将多种开源技术结合到自研的底层产品上，这样用户能够使用熟悉的开源技术，同时底层数据由阿里云运维(极其耗费硬件资源和人力资源)，以达到云计算规模化的经济效益。



