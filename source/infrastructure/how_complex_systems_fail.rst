.. _how_complex_systems_fail:

==========================
复杂系统是如何失败的
==========================

.. note::

   在解析系统架构之前，我首先要当头棒喝一下 : "不要构建过分复杂、功能堆砌的系统!!!"

芝加哥大学认知技术实验室医学博士 richard I. Cook 有一篇关于复杂系统发生故障的评述，其实也是我们计算机基础架构的真实写照。

如果你在一家大型软件/硬件公司，或者互联网头部公司工作，你会见到或者参与过匪夷所思的故障发生，有些甚至是灾难性和毁灭性的(也许是企业、也许是个人)。

在网络漫画 `xkcd <https://www.explainxkcd.com/>`_ (Randall Munroe 绘制轻松、古怪的简笔幽默画)，有一幅描绘令人眼花缭乱、看似坚不可摧的现代数字基础架构其实依赖着( `2347: Dependency <https://www.explainxkcd.com/wiki/index.php/2347:_Dependency>`_ ) `阿喀琉斯之踵 <https://baike.baidu.com/item/阿喀琉斯之踵/340132>`_ 。

.. figure:: ../_static/infrastructure/dependency.png

在这幅 `2347: Dependency <https://www.explainxkcd.com/wiki/index.php/2347:_Dependency>`_ 漫画的原文和网友讨论中，我们会看到毫不起眼的基础架构组件小小失误 `直到大厦崩塌 <https://youtu.be/npHbCnf-Lpk>`_ 才被看见。

"庞大而复杂"的诱惑
===================

作为云计算的技术公司，我感觉可能有一种对"庞大而复杂"系统的冲动，毕竟很多技术leader对于规模有一种迷恋，信奉 "大就是好" 。这一定程度确实是一种技术挑战，毕竟把 :ref:`distributed_system` 规模做大，确实可能对于调度资源来说，理论上不容易出现分配浪费。不过，骨子里可能还是 "技术炫耀" ，做到业界第一的规模。

但是，从我的经验来看，规模大并不是一个分布式系统，或者说 :ref:`kubernetes` 应该片面追求的指标:

- 集群规模过大则在管控平面有极大的压力，使得很多动态功能效率降低且难以稳定:

  - 随着节点硬件的不断增强，单节点管理的资源(pods)急剧增加，并且引入了 :ref:`service_mesh` 之后，单个节点已经是非常复杂的微系统生态，叠加到整个集群以后，对 :ref:`etcd` 和 apiserver / scheduler 核心组件产生巨大的压力。而Kubernetes管控组件能否做到无限的横向扩展，以及扩展过程中控制数据交换的开销，是难度和成本骤增的挑战。
  - 中心化管理确实带来的管控开发和维护的便利，但是对于不断增长的集群规模，中心化管理存在瓶颈，并且可能在不断动态变化的任务(并发大规模创建和销毁)出现雪崩

参考
=====

- `How Complex Systems Fail <https://how.complexsystems.fail>`_ 芝加哥大学认知技术实验室医学博士 richard I. Cook 的著名短文
- `复杂系统是如何失败的？ <https://www.infoq.cn/article/sedyekczaqxv7edec7um>`_ InfoQ对 「How Complex Systems Fail」翻译，可快速阅读参考
