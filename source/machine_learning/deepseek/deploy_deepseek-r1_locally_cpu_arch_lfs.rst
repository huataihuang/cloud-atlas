.. _deploy_deepseek-r1_locally_cpu_arch_lfs:

=======================================
本地化部署DeepSeek-R1 CPU架构(LFS环境)
=======================================

在 :ref:`debian` 环境中初步验证了 :ref:`deploy_deepseek-r1_locally_cpu_arch` ，我将 :ref:`hpe_dl380_gen9` 物理主机上的Host操作系统切换到自己编译定制的 :ref:`lfs` 系统，从源代码重新编译 :ref:`install_llama.cpp_cpu_lfs` ，然后执行本地部署 DeepSeek-R1 CPU架构(LFS环境)。

安装llama.cpp
=================

我在 :ref:`install_llama.cpp_cpu` 按照以下方式完成编译安装:

.. literalinclude:: ../llm/llama.cpp/install/install_llama.cpp_cpu_lfs/cmake_cpu_again
   :caption: 删除 ``build`` 目录重新配置编译

运行
=====

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch_lfs/run_model_err
   :caption: 运行模型(不过缺少参数推理会报错,见下文修复)

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

**奔溃，运行了快2个小时，最后报错了**

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch/llama_test_error
   :caption: 客户端返回错误

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch/llama_server_error
   :caption: 服务端返回错误

仔细检查服务器端llama_server启动信息:

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch_lfs/llama_server_console_info
   :caption: 服务器端llama_server启动信息

解决方法是加上运行参数 ``--cache-type-k q8_0``

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch_lfs/run_model
   :caption: 运行模型,修正参数
   :emphasize-lines: 3

初步运行结果
==============

- 得到DeepSeek的返回结果

.. include:: deploy_deepseek-r1_locally_cpu_arch_lfs/result.md
   :parser: myst_parser.sphinx_

- 从服务器端可以看到消耗掉的 ``token`` 和时间:

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch_lfs/llama_token
   :caption: 消耗的token和时间
   :emphasize-lines: 11

可以看到推理非常缓慢，速度只有 ``0.637 token/s`` ，这个速度甚至还不如我在标准的 :ref:`ubuntu_linux` 环境下 :ref:`deploy_deepseek-r1_locally_cpu_arch` ( ``0.66 token/s`` )

从观察来看，没有控制参数，负载会随机落到超线程的cpu core，当两个超线程位于同一个cpu core产生竞争，甚至可能不如更少的线程数量计算。

另外，我的 :ref:`lfs` ``cpupower`` 没有调整，看起来并没有发挥出CPU最好性能。
