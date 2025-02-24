.. _deploy_deepseek-r1_locally_cpu_arch_lfs:

=======================================
本地化部署DeepSeek-R1 CPU架构(LFS环境)
=======================================

在 :ref:`debian` 环境中初步验证了 :ref:`deploy_deepseek-r1_locally_cpu_arch` ，我将 :ref:`hpe_dl380_gen9` 物理主机上的Host操作系统切换到自己编译定制的 :ref:`lfs` 系统，从源代码重新编译 :ref:`install_llama_cpu_lfs` ，然后执行本地部署 DeepSeek-R1 CPU架构(LFS环境)。

安装llama.cpp
=================

我在 :ref:`install_llama_cpu` 按照以下方式完成编译安装:

.. literalinclude:: ../llm/llama/install/install_llama_cpu_lfs/cmake_cpu_again
   :caption: 删除 ``build`` 目录重新配置编译

运行
=====

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch_lfs/run_model
   :caption: 运行模型

交互
========

简单交互可以使用 :ref:`curl` :

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch/llama_test.sh
   :caption: 使用curl检查验证

这次运行没有指定线程数量，观察运行时大约消耗了一半cpu数量: Load 大约 23 ，也就是一半的cpu core(超线程是48)

比较奇怪，未指定并发线程数量，看起来也只是用了一半的cpu能力，这个cpu分布是怎么实现的？我下次验证准备关闭超线程看看能否真如网上所说提高性能。

以下是运行推理时的cpu运行情况:

.. figure:: ../../_static/machine_learning/deepseek/deepseek_r1_cpu.png

由于分布cpu负载随机，看起来确实会导致在同一个cpu core的两个超线程分发负载，这样会有资源竞争，可能降低效率。后续验证准备关闭超线程。

