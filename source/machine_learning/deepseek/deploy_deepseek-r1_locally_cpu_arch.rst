.. _deploy_deepseek-r1_locally_cpu_arch:

=================================
本地化部署DeepSeek-R1 CPU架构
=================================

安装llama.cpp
=================

我在 :ref:`install_llama.cpp_cpu` 按照以下方式完成编译安装:

- :ref:`ubuntu_linux` / :ref:`debian` 编译环境:

.. literalinclude:: ../llm/llama.cpp/install/install_llama.cpp_cpu/debian_dev
   :caption: 编译环境准备

- 下载 ``llama.cpp`` 源代码:

.. literalinclude:: ../llm/llama.cpp/install/install_llama.cpp_cpu/download_llama
   :caption: 下载 ``llama.cpp`` 源代码

- 针对CPU架构编译:

.. literalinclude:: ../llm/llama.cpp/install/install_llama.cpp_cpu/cmake_cpu
   :caption: 针对CPU架构编译

下载模型
= =========

``unsloth`` 在 huggingface.co 提供了8位量化 ``DeepSeek-R1-Q8_0`` ，可以通过以下方式下载:

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch/downlaod_model.py
   :caption: 下载 8位量化 ``DeepSeek-R1-Q8_0``

.. warning::

   实际选择应该根据自己的服务器内存规格来选择量化模型，必须确保模型文件大小不超过服务器内存(CPU架构)。

   我挥泪出血满配了 :ref:`hpe_dl360_gen9` **768GB内存** 尝试采用8位量化 ``DeepSeek-R1-Q8_0``

.. note::

   实际上墙内下载huggingface的模型文件非常吃力，我没有采用直接下载方法，而是通过阿里云租用的ECS虚拟机下载，然后再搬运回本地。代价是花费了2天时间以及约200RMB带宽和虚拟磁盘费用!

运行模型
===========

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch/run_model
   :caption: 运行模型

参数:

- ``--threads 16`` 表示 ``llama-server`` 在回答问题时会并发动用多少个线程，也就是占用多少个CPU core，这里设置 ``16`` ，则后续 ``prompt`` 问题后，就会看到服务器上有16个cpu繁忙计算推理，负载会达到 ``16``
- ``--port 8081`` : ``llama-server`` 默认端口是 ``8080`` ，不过 ``8080`` 端口也是 ``open-webui`` 使用的，所以采用错开配置
- 如果使用GPU，可以再添加如下参数:

  - ``--ctx-size 1024`` 上下文长度，也就是token数量，根据硬件的RAM或VRAM使用量确定
  - ``--n-gpu-layers`` 卸载到GPU上的层数量，加快推理速度，这个参数也取决于GPU内存，需要参考 Unsloth 的规格表格

.. note::

   由于没有资金购买大容量GPU，所以采用满配 :ref:`hpe_dl360_gen9` **768GB内存** 尝试采用8位量化 ``DeepSeek-R1-Q8_0``

   这里采用的参数非常简单，我还在学习摸索中，目前仅仅是运行起来...

   模型文件非常巨大，SSD磁盘加载到内存需要很长时间

- 启动后 ``llama-server`` 内存使用大约 ``680G``

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch/top
   :caption: 内存使用量

交互
========

简单交互可以使用 :ref:`curl` :

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch/llama_test.sh
   :caption: 使用curl检查验证 

上述prompt要求DeepSeek编写一个简单的bash脚本，实际测试下来 **当然非常缓慢** 可以看到 ``llama.cpp`` 终端的统计:

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch/llama_test_console
   :caption: ``llama.cpp`` 终端显示的日志显示了推理的消耗
   :emphasize-lines: 10

可以看到最终这个简单的脚本问答花费了 ``55.38 分钟`` ，消耗了 ``2194 tokens`` ，平均只有 ``0.66 token/s`` 

得到的输出结果如下(已经整理格式获取实际结果):

.. literalinclude:: deploy_deepseek-r1_locally_cpu_arch/llama_test_output
   :caption: 要求DeepSeek编写脚本输出结果内容

下一步
========

由于自己的资金有限，不可能购买昂贵的GPU设备，所以我准备继续用这套CPU架构的二手服务器来做探索:

- 通过软件配置和部署来优化性能，力争能够达到每秒5个tokens(对上述问题可能在5分钟内完成)
- 必要时准备升级到更好一点的 E5v4 处理器

参考
=======

- `unsloth/DeepSeek-R1-GGUF: README.md <https://huggingface.co/unsloth/DeepSeek-R1-GGUF/blob/main/README.md>`_
- `Running LLaMA Locally with Llama.cpp: A Complete Guide <https://medium.com/hydroinformatics/running-llama-locally-with-llama-cpp-a-complete-guide-adb5f7a2e2ec>`_
