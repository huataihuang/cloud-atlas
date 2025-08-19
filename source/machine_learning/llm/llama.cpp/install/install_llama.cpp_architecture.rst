.. _install_llama.cpp_architecture:

==============================
不同架构安装 LLaMA.cpp
==============================

llama.cpp编译支持不同环境，需要使用不同的编译方式:

- CPU Build

  - OpenBLAS - 只用于CPU的BLAS加速
  - BLIS - 软件框架，用于实例化高性能BLAS类密集线性代数库
  - Intel oneMKL - tongguo oneAPI编译器进行构建将使用支持 ``avx_vnni`` 来加速不支持 ``avx512`` 和 ``avx512_vnni`` 的Intel处理器，如果要支持Intel GPU，则使用 ``SYCL`` )

    - 需要安装Intel提供的oneAPI(后续优化性能，待实践)

- GPU Build

  - Metal - 当在macOS上编译时默认激活 ``Metal``
  - SYCL (基于SYCL主要可以支持Intel GPU,也支持其他厂商GPU，如Nvidia/AMD)
  - CUDA - 加速 :ref:`nvidia_gpu`
  - MUSA - Moore Threads MTT GPU
  - HIP - 支持HIP的 :ref:`amd_gpu` ，需要确保安装了ROCm (需要单独编译?)
  - Vulkan - 支持不同GPU,CPU和操作系统的底层跨平台3D图形和计算 API，在Linux下(如果不使用 :ref:`docker` )需要安装 ``Vulkan SDK``

- CANN - 使用华为昇腾NPU(Ascend NPU)的CANN(Compute Architecture for Neural Networks)神经网络计算架构的加速
- Android - 居然可以在Android中使用 :ref:`termux` 完成编译，Amazing，待实践 :ref:`install_llama.cpp_android`

GPU加速后端
=============

- 如果需要完全禁止GPU加速，运行时使用 ``--device none`` 参数
- 很多情况下， ``llama.cpp`` 可以同时编译和使用多种后端:

  - 可以同时使用参数 ``-DGGML_CUDA=ON -DGGML_VULKAN=ON`` 执行CMake来编译同时支持CUDA和Vulkan
  - 运行时可以使用 ``--device`` 参数来指定(多个)后端设备
  - 使用 ``--list-devices`` 可以查看可以使用的设备

- 后端可以编译为动态库以便能够在运行时动态加载: 能够可以使用相同的 ``liama.cpp`` 执行程序在不同主机使用不同GPUs。为激活这个特性，可以在编译时使用 ``GGML_BACKEND_DL`` 选项

我的实践
==========

- :ref:`install_llama.cpp_cpu`
- :ref:`install_llama.cpp_cuda`
- :ref:`install_llama.cpp_hip`
- :ref:`install_llama.cpp_vulkan`
- :ref:`install_llama.cpp_android`

参考
==========

- `Build llama.cpp locally <https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md>`_
