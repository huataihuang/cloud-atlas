.. _cuda_cores_vs._tensor_cores:

=============================
CUDA Cores vs. Tensor Cores
=============================

在机器学习领域，训练一个ML model(机器学习模型)需要对大型数据进行筛选。但是随着数据集的数量、复杂度和交叉关系的增加，处理能力的需求呈指数级增长(surges exponentially)。

深度学习(DL)是机器学习(ML)的一个重要子集，使用人工神经网络(ANN)进推理研究。因此，深度学习本质上更加依赖于大量数据来为模型提供输入。传统的 :ref:`cpu` 无法处理庞大的机器学习数据集，也无法提供ML模型训练的计算能力，所以ML通常采用高级GPU，通过内置的CUDA core和Tensor core 阵列来完成机器学习任务(训练和推理)。

GPU
=======

徒刑处理但愿(Graphical Processing Units, GPUs)是用于沉浸式视频游戏(immersive video games)，电影和其他视觉媒体中用于呈现丰富2D/3D图形和动画的专用硬件。由于GPU能够超高效进行并行的浮点计算，已经成为海量数据处理和ML模型训练的最佳选择。NVIDIA开发了用于通用和专用处理的 :ref:`cuda` 和 Tesnor 核心GPU，成为ML领域主要的硬件供应商。

CUDA Cores
-------------

CUDA(Compute Unified Device Architecture,
计算统一设备架构)是NVIDIA于2007年发布的专有、特殊设计的GPU核心，大致相当于CPU核心。虽然不如CPU核心通用和强大，但是CUDA的核心优势是数量巨大，并且能够同时并行地对不同数据集进行计算。由于高级GPU具备数百甚至数千CUDA核心，尽管每个CUDA核心和CPU一样只能在每个时钟周期执行一个操作，但是GPU的SIMD架构使得成百上千个CUDA核心能够同时处理一个数据集，从而在更短时间内完成数据处理。CUDA技术对数据分析、数据可视化以及AI/ML开发场景带来极大改进。CUDA代码支持多种语言开发:C, C++, Fortran, OpenCL 和 Direct
Compute等语言，以支持CUDA的GPU进行通用计算和数据处理。CUDA指令集还提供对NVIDIA GPU的虚拟指令的直接访问软件和程序，CUDA core GPU还支持Direct 3D, OpenGL等徒刑API，以及OpenCL和OpenMP等编程框架。

CUDA Cores是实时计算、计算密集型3D徒刑、游戏开发、密码散列(cryptographic hashing)、物理引擎和数据科学计算的主要硬件，在机器学习和深度学习领域，以及TB级别数据训练上，GPU也是重要核心硬件。

Tensor Cores
---------------

.. youtube:: yyR0ZoCeBO8

.. note::

   上述视频通过 :ref:`sphinx_embed_youtube` 实现，很有用的一个 :ref:`sphinx_doc` 插件；类似还有 :ref:`sphinx_embed_video`

Tensor Cores是特殊设计的NVIDIA GPU核心，用于动态计算(dynamic calculations)和混合精度计算(mixed-precision computing)。Tensore cores可以在提供整体性能的同时保持准确性(accelerate the overall performance while simultaneously preserving accuracy)。

属于 ``Tensor`` (张量) 定义了一种数据类型，可以保存或表示所有形式的数据，可以将其视为存储多维数据集的容器(a container to store multi-dimensional datasets)。

Tensor cores利用融合乘加算法(fused multiply-addition algorithms)，将两个FP16 和/或 FP32 矩阵相乘并相加，从而显著加快计算速度，而且对模型的最终效果几乎没有损失。虽然矩阵乘法在逻辑上很简单，但是每次计算都需要寄存器和缓存来存储临时计算(interim calculations)，从而使得整个计算量非常庞大。所以Tensore cores特别适合训练庞大的ML/DL模型。

目前已经发布了4代Tensor cores:

- 第一代Tensor cores使用Volta(伏打) GPU微架构(V100): 第一代Tensor cores提供了FP16数字格式的混合精度计算，通过V100的640个Tensor Cores，比早期的Pascal系列GPU相比，第一代Tensor cores可以提供高达5倍的性能提升。
- 第二代Tensor cores使用Turing(图灵) GPU微架构(T100?): 第二代Tensor cores执行速度是Pascal GPU的32倍，并且将FP16计算扩展到Int8, Int4 和 Int1，从而提高计算精度
- 第三代Tensor cores使用Ampere(安培) GPU微架构(A100): 第三代Tensor cores增加了对bfloat16, TF32和FP64精度的支持，进一步扩展了Volta和Turing微架构的潜力
- 第四代Tensor cores使用Hopper(霍波) GPU微架构(H100): 第四代Tensor cores可以处理FP8精度，在FP16、FP32和FP64计算方面比上一代A100快三倍，在8位浮点数学运算方面快六倍

.. note::

   NVIDIA的GPU微架构都是以历史上著名的科学家、数学家和计算机科学家命名:

   - Volta(伏打): 1799年，意大利物理学家Alessandro Volta发明了第一款电池（Vlotaic Pile 伏特堆）
   - Truing(图灵): 艾伦·麦席森·图灵（Alan Mathison Turing，1912年6月23日~1954年6月7日），英国数学家、逻辑学家，被称为计算机科学之父，人工智能之父。
   - Ampere(安培): 安德烈·玛丽·安培（André-Marie Ampère，1775年1月20日 — 1836年6月10日），法国物理学家、化学家和数学家，在电磁作用方面的研究成就卓著，被麦克斯韦誉为“电学中的牛顿”
   - Hopper(霍波): 格蕾丝·霍波 (Grace Hopper，1906-1992)，是计算机语言领域的开拓者，发明了世界上第一个编译器——A-0 系统，被称为“计算机软件工程第一夫人”。1945年，Grace Hopper在 Mark Ⅱ中发现了一只导致机器故障的飞蛾，从此“bug” 和 “debug” （除虫） 便成为计算机领域的专用词汇。

CUDA Cores 和 Tensor Cores的差别
=================================

随着越来越依赖海量数据集来进行更准确的模型训练和推理，CUDA cores GPU 被发现处于中等水平。 因此，Nvidia 引入了 Tensor cores。 Tensor cores 在一个时钟周期内执行多项操作表现出色。 因此，在机器学习操作方面，Tensor cores 优于 CUDA cores。

参考
=====

- `CUDA Cores vs. Tensor Cores – Which One Is Right For Machine Learning <https://www.acecloudhosting.com/blog/cuda-cores-vs-tensor-cores/>`_
- `Understanding Tensor Cores <https://blog.paperspace.com/understanding-tensor-cores/>`_
