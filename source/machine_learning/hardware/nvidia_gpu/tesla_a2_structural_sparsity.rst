.. _tesla_a2_structural_sparsity:

=============================================
Tesla A2 结构化稀疏(Structural Sparsity)技术
=============================================

.. note::

   :ref:`tesla_a2` 原生支持结构化稀疏技术，能够在几乎不损失模型精度的前提下，将算力吞吐量和推理速度提升高达 2 倍（2x）。

.. warning::

   本文整理记录一些资料信息，为后续实践做准备

结构化稀疏（2:4 Sparsity）
===========================

在深度学习中，"剪枝(Pruning)"通常分为非结构化剪枝和结构化剪枝:

- **非结构化稀疏** : 随机剔除矩阵中的零值。虽然压缩了模型体积，但数据分布零散，GPU 并行计算引擎无法有效加载，因此无法带来真正的硬件加速。
- **传统结构化剪枝** : 直接裁掉整行、整列或整个 Channel。虽然能加速，但极其容易破坏模型结构，导致精度大幅下降。

NVIDIA 2:4 稀疏模式的物理逻辑
--------------------------------

NVIDIA 在 Ampere 架构中提出了 ``2:4 结构化稀疏`` (2:4 Sparse Pattern)，直接在硬件级做了约定:

- 规则：在权重的矩阵中，每连续 4 个元素里，必须且只能有 2 个元素为 0（即 50% 的稀疏度）。
- 硬件级加速：A2 的 Tensor Core 硬件内部内置了稀疏元素选择电路。在执行 ``A x B`` 矩阵乘法时，硬件会自动跳过那 2 个 0 值，仅对剩下的 2 个非零元素进行 MAC(乘加)运算，同时只需要从显存中加载压缩后的权重数据(节省 50% 的显存带宽)。

发挥 A2 结构化稀疏特性
=======================

要在实际开发中将 A2 的算力吞吐拉满，需要遵循 ``剪枝/微调 -> 导出 -> 部署加速`` 的完整工作流:

- 算法层面：生成符合 2:4 规则的稀疏模型

普通的 PyTorch/TensorFlow 模型是没有 2:4 结构的，必须经过剪枝微调:

使用 NVIDIA ASP (Automatic SParsity): NVIDIA 官方在 PyTorch (apex.contrib.sparsity 或 torch.ao.pruning) 和 torchao 中提供了 ASP 工具。它可以自动扫描模型的权重矩阵，自动将每 4 个数中绝对值最小的 2 个置零，然后进行数轮微调恢复精度（Typically只需重训几个 Epoch 即可恢复 99%+ 的原有精度）。

- 推理部署层面：配合 TensorRT 启用硬件引擎（核心步骤）

PyTorch 原生运行模型时默认依然走 Dense 计算路线，必须使用 NVIDIA TensorRT 或 Triton Inference Server 进行 Engine 编译，才能彻底激活 A2 的 Sparse Tensor Core:

使用 TensorRT 命令行工具 ( ``trtexec`` )，在将 ONNX 转成 TensorRT ``.engine`` 引擎时，明确加上 ``--sparsity=enable`` （或者 ``--sparsity=force`` ）标记

- 结合量化（INT8 + 2:4 Sparsity 叠加效应）

A2 的功耗极低（仅 40W–60W），要想榨干它的最大效能，最顶级的策略是"INT8 量化 + 2:4 稀疏":

  - 先进行 2:4 结构化稀疏剪枝
  - 使用 TensorRT PTQ（训练后量化）或 QAT（量化感知训练）转换为 INT8
  - 此时 A2 的理论峰值计算性能将从初始 FP32 的 4.5 TFLOPS 飙升至 72 TOPS（提升高达 16 倍）

- 部署栈首选： **NVIDIA Triton Inference Server**

在边缘侧部署视觉分析（IVA）或 NLP/LLM 服务，建议使用 Triton: Triton 能够感知 A2 的稀疏引擎，配合 Dynamic Batching（动态批处理），可以把 A2 低功耗卡在大并发场景下的吞吐量发挥到极致。

注意事项
===========

- 适用场景：对推理延时敏感、吞吐量要求高的场景（如视频流多路分析、边缘端大模型/Transformer 类推理）。
- 硬件局限：2:4 稀疏仅适用于矩阵乘法/全连接层（Linear / Gemm）和卷积层（Conv2D），对 Element-wise（逐元素加减）、LayerNorm 等非矩阵计算无加速效果。
- 最佳实践路线： ``PyTorch Dense 模型 -> ASP 工具一键 2:4 剪枝与微调 -> 导出 ONNX -> TensorRT 开启 --sparsity 构建引擎 -> 在 A2 上获得 1.5x ~ 2x 的实际测速提升`` 。

参考
======

- gemini
