.. _install_llama.cpp_cpu_lfs:

==============================
在LFS中CPU架构LLaMA.cpp安装
==============================

我的物理主机使用了 :ref:`lfs` / :ref:`blfs` 构建，力图对系统进行精简和性能优化。由于 :ref:`hpe_dl380_gen9` 满配了 ``768GB`` 物理能够，能够满血 :ref:`deploy_deepseek-r1_locally_cpu_arch` ，所以本文尝试在 :ref:`lfs` / :ref:`blfs` 编译安装 LLaMA

编译准备
=========

:ref:`lfs` 部署中没有 ``cmake`` ，所以在 :ref:`blfs` 补全安装 CMake

编译安装
==========

为 :ref:`deploy_deepseek-r1_locally_cpu_arch` 准备，本地编译 ``llama.cpp`` 

- 下载 ``llama.cpp`` 源代码:

.. literalinclude:: install_llama.cpp_cpu/download_llama
   :caption: 下载 ``llama.cpp`` 源代码

准备阶段
----------------

- 针对CPU架构编译准备:

.. literalinclude:: install_llama.cpp_cpu_lfs/cmake_cpu_prepare
   :caption: 针对CPU架构编译

报错 ``gmake`` :

.. literalinclude:: install_llama.cpp_cpu_lfs/gmake_error
   :caption: 缺少 ``gmake`` 命令
   :emphasize-lines: 16,17

这是因为没有构建 ``gmake`` 软链接，参考 :ref:`debian` 环境:

.. literalinclude:: install_llama.cpp_cpu_lfs/gmake
   :caption: 创建 ``gmake`` 软链接

编译阶段
----------

- 针对CPU架构编译:

.. literalinclude:: install_llama.cpp_cpu_lfs/cmake_cpu
   :caption: 针对CPU架构编译

编译报错:

.. literalinclude:: install_llama.cpp_cpu_lfs/cmake_cpu_error_1
   :caption: 针对CPU架构编译错误1
   :emphasize-lines: 3

这个报错表明系统可能缺少 ``libgomp.cpp`` (参考 `error while loading shared libraries: libgomp.so.1: , wrong GCC version? <https://stackoverflow.com/questions/11949359/error-while-loading-shared-libraries-libgomp-so-1-wrong-gcc-version>`_ )，依赖库 ``libgomp`` ?

我在 :ref:`debian` 系统中可以找到 ``/usr/lib/x86_64-linux-gnu/libgomp.so.1`` ，但是我的 :ref:`lfs` 系统中缺少。所以寻找 ``libgomp`` (根据 :ref:`debian` 系统查询 ``libgomp.so.1`` 属于 ``libgomp1`` 包)

.. note::

   ``libgomp`` : GNU Offloading and Multi Processing Runtime Library

   `gomp <https://gcc.gnu.org/projects/gomp/>`_ :

   The GOMP project consists of implementation of OpenMP and OpenACC to permit annotating the source code to permit running it concurrently with thread parallelization and on offloading devices (accelerators such as GPUs), including the associated run-time library and API routines. Both OpenMP and OpenACC are supported with GCC's C, C++ and Fortran compilers.

   注意到这个 ``libgomp`` 是跟随 GCC 提供的: 参考 `libgomp > Enabling OpenMP <https://gcc.gnu.org/onlinedocs/libgomp/Enabling-OpenMP.html>`_ : 要激活 C/C++和Fortran的 OpenMP 扩展，需要在编译时使用 ``-fopenmp`` 

我忽然发现一个问题，报错信息中提示::

   No rule to make target '/usr/lib/gcc/x86_64-linux-gnu/12/libgomp.so', needed by 'bin/llama-gguf-hash'.

但是，只有 :ref:`debian` 系统目前使用的是 ``gcc-12`` ，而我在 :ref:`lfs` 中使用的是 ``gcc-14.2`` ，目前在我的 :ref:`lfs` 系统中， ``/usr/lib/libgomp.so`` 是存在的。看起来像是之前在 :ref:`debian` 12 中编译的配置残留导致的。

所以，我删除源代码目录下的 ``build`` 子目录重新编译:

.. literalinclude:: install_llama.cpp_cpu_lfs/cmake_cpu_again
   :caption: 删除 ``build`` 目录重新配置编译， ``成功``

终于成功了

运行
========

- :ref:`deploy_deepseek-r1_locally_cpu_arch_lfs`

参考
======

- `unsloth/DeepSeek-R1-GGUF/README.md <https://huggingface.co/unsloth/DeepSeek-R1-GGUF/blob/main/README.md>`_
- `Build llama.cpp locally <https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#hip>`_
- `Running LLaMA Locally with Llama.cpp: A Complete Guide <https://medium.com/hydroinformatics/running-llama-locally-with-llama-cpp-a-complete-guide-adb5f7a2e2ec>`_
- `How can I separately build and develop libgomp (openMP runtime)? <https://stackoverflow.com/questions/35534168/how-can-i-separately-build-and-develop-libgomp-openmp-runtime>`_
