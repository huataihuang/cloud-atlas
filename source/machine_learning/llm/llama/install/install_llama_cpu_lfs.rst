.. _install_llama_cpu_lfs:

==========================
在LFS中CPU架构LLaMA安装
==========================

我的物理主机使用了 :ref:`lfs` / :ref:`blfs` 构建，力图对系统进行精简和性能优化。由于 :ref:`hpe_dl380_gen9` 满配了 ``768GB`` 物理能够，能够满血 :ref:`deploy_deepseek-r1_locally_cpu_arch` ，所以本文尝试在 :ref:`lfs` / :ref:`blfs` 编译安装 LLaMA

编译安装
==========

为 :ref:`deploy_deepseek-r1_locally_cpu_arch` 准备，本地编译 ``llama.cpp`` 

- 下载 ``llama.cpp`` 源代码:

.. literalinclude:: install_llama_cpu/download_llama
   :caption: 下载 ``llama.cpp`` 源代码

- 针对CPU架构编译:

.. literalinclude:: install_llama_cpu/cmake_cpu
   :caption: 针对CPU架构编译

这里 :strike:`完成编译生成的3个执行程序` :

.. literalinclude:: install_llama_cpu/llama
   :caption: 编译生成的llama执行程序

都被复制到 ``llama.cpp`` 目录下待用，并且执行程序是静态编译程序，可以复制到其他相同操作系统环境使用。

**我现在去除了目标文件，完整编译**

参考
======

- `unsloth/DeepSeek-R1-GGUF/README.md <https://huggingface.co/unsloth/DeepSeek-R1-GGUF/blob/main/README.md>`_
- `Build llama.cpp locally <https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#hip>`_
- `Running LLaMA Locally with Llama.cpp: A Complete Guide <https://medium.com/hydroinformatics/running-llama-locally-with-llama-cpp-a-complete-guide-adb5f7a2e2ec>`_
