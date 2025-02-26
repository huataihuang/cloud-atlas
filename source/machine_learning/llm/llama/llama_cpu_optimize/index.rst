.. _llama_cpu_optimize:

=========================
LLaMA在CPU架构上优化
=========================

:ref:`install_llama_cpu` 支持基于CPU的优化，探索这项技术主要目标:

- 利用廉价的(二手淘汰服务器)CPU和大内存来实现基本能够运行的大模型
- 学习如何优化大模型运行的基础设施部署

我初步完成 :ref:`deploy_deepseek-r1_locally_cpu_arch_lfs` ，能够在廉价二手硬件上运行"满血" DeepSeek R1大模型之后，得到的性能结果却差强人意:

- 完成一个简单的 :ref:`bash` 脚本问答需要花费50分钟时间甚至更久
- 速率只有可怜的 ``0.637 token/s`` （ 另一个在标准 :ref:`debian` 12上部署的 :ref:`deploy_deepseek-r1_locally_cpu_arch` 也只有 ``0.66 token/s`` )，几乎没有实用价值

所以，我尝试通过不同软硬件手段来提高推理速度:

- 不增加或很少增加硬件投入来提高推理速度
- 每一个优化步骤分步进行，并记录提升百分比，同时学习优化的原理
- 同步学习业界的经验和技能

.. toctree::
   :maxdepth: 1

   llama_tunning_disable_ht


.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`

参考
======

- `Optimizing and Running LLaMA2 on Intel CPU <https://www.intel.com/content/www/us/en/content-details/791610/optimizing-and-running-llama2-on-intel-cpu.html>`_
