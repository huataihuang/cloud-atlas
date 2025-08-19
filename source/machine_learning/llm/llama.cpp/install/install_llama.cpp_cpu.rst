.. _install_llama.cpp_cpu:

=====================
CPU架构LLaMA.cpp安装
=====================

二进制安装
===============

`llama.cpp release <https://github.com/ggerganov/llama.cpp/releases>`_ 提供了多个版本适配不同的硬件:

以下是windows环境下适配CPU和GPU的版本案例

- AVX (llama-bin-win-avx-x64.zip): For older CPUs with AVX support.
- AVX2 (llama-bin-win-avx2-x64.zip): For Intel Haswell (2013) and later.
- AVX-512 (llama-bin-win-avx512-x64.zip): For Intel Skylake-X and newer.
- CUDA (llama-bin-win-cuda-cu11.7-x64.zip): If using an NVIDIA GPU.

不过，对于Linux版本较少版本，只提供了 ``ubuntu`` 下的 ``vulkan`` 和 通用cpu版本，所以一般需要编译。

编译安装
==========

为 :ref:`deploy_deepseek-r1_locally_cpu_arch` 准备，本地编译 ``llama.cpp`` 

- :ref:`ubuntu_linux` / :ref:`debian` 编译环境:

.. literalinclude:: install_llama.cpp_cpu/debian_dev
   :caption: 编译环境准备

- 下载 ``llama.cpp`` 源代码:

.. literalinclude:: install_llama.cpp_cpu/download_llama
   :caption: 下载 ``llama.cpp`` 源代码

- 针对CPU架构编译:

.. literalinclude:: install_llama.cpp_cpu/cmake_cpu
   :caption: 针对CPU架构编译

这里完成编译生成的3个执行程序:

.. literalinclude:: install_llama.cpp_cpu/llama
   :caption: 编译生成的llama执行程序

都被复制到 ``llama.cpp`` 目录下待用，并且执行程序是静态编译程序，可以复制到其他相同操作系统环境使用。



参考
======

- `unsloth/DeepSeek-R1-GGUF/README.md <https://huggingface.co/unsloth/DeepSeek-R1-GGUF/blob/main/README.md>`_
- `Build llama.cpp locally <https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#hip>`_
- `Running LLaMA Locally with Llama.cpp: A Complete Guide <https://medium.com/hydroinformatics/running-llama-locally-with-llama-cpp-a-complete-guide-adb5f7a2e2ec>`_
