.. _model_choice:

==================
模型选择
==================

.. note::

   本文整理一些我准备采用的模型说明，针对我现有的硬件架构:

   - **3块** :ref:`tesla_a2` (16GB)总计48GB显存，单卡显存带宽200GB/s(极弱) ，支持 :ref:`tesla_a2_structural_sparsity`
   - **2块** :ref:`amd_mi50` (32GB) 总计64GB显存，单卡显存带宽(1.02TB/s)惊人 ，但 **没有** ``INFINITY FABRIC LINK 桥接器`` 连接情况下受限于主板PCIe 3带宽

   选择和说明综合gemini以及网上资料，不一定准确，后续会逐步补充更新

3块 :ref:`tesla_a2` 配套
============================

``qwen3-coder:30b-a3b-q4_K_M``
--------------------------------



2块 :ref:`amd_mi50` 配套
===========================

``qwen3-coder-next:q4_K_M``
----------------------------

2026年2月4日阿里巴巴(Qwen团队)正式发布了开源权重编程智能体模型 Qwen3-Coder-Next。

核心规格与架构:

- 基础架构：基于 Qwen3-Next-80B-A3B-Base 构建，采用 Gated DeltaNet 与 Gated Attention 相结合的混合注意力（Hybrid Attention）与 MoE（混合专家）架构。
- 参数规模：总参数量约 80B，但单次推理激活参数仅约 3B（超低推理成本与极快运行速度）。
- 上下文窗口：支持高达 256K（262,144） 原生长上下文长度。
- 运行模式：仅支持非思考模式（non-thinking mode only）。
- 量化与部署：支持在消费级硬件上通过量化进行高效推理，适配 SGLang 和 vLLM 框架。

主要特点与能力:

- 专为 Coding Agent 打造：针对长程推理、复杂工具调用、执行失败恢复及全库（repository-scale）代码理解进行了强化训练。
- 生态兼容：开箱即用支持多种主流编码智能体和工具，如 Claude Code、OpenCode、Hermes Agent、OpenClaw、Cline 等。

从 Ollama 官网可以看到通过Agent模式加载 ``qwen3-coder-next`` ，我准备尝试一下agent是否真能实现较少的人工干预来完成软件开发。
