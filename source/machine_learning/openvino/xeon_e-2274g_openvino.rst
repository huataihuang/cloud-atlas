.. _xeon_e-2274g_openvino:

================================
Intel Xeon E-2274G环境OpenVINO
================================

.. note::

   本文和gemini进行讨论后整理

:ref:`xeon_e-2274g` (Coffee Lake 架构，第 8 代) 与 :ref:`xeon_w-2235` ( :ref:`xeon_w-2225_openvino` Cascade Lake 架构，第 10 代) 在底层架构、性能定位以及指令集扩展上有很大差异:

.. csv-table:: Intel Xeon E-2274G vs. W-2235
   :file: xeon_e-2274g_openvino/e-2274g_vs_w-2235.csv
   :widths: 10,30,30,30
   :header-rows: 1

分析
======

OpenVINO 能够完全兼容并运行在 :ref:`xeon_e-2274g` 和 :ref:`xeon_w-2235` ，但 **加速原理和性能表现截然不同** :

- :ref:`dell_t5820` 上的 :ref:`xeon_w-2235` (CPU 纯算力推理极佳)

  - **指令集优势(DL Boost / VNNI)** : Cascade Lake 架构首次引入了 ``Vector Neural Network Instructions(VNNI)`` 。OpenVINO对量化模型(如 ``INT8`` / ``INT4`` 活化的LLM)有深度优化，W-2235能够通过一条VNNI指令并行完成传统的多次乘加运算， ``INT8`` 推理吞吐量提升可达2-3倍
  - **内存带宽优势** : W-2235 支持 **DDR4 四通道** ，内存带宽高达 ``94 GB/s`` (E-2274G双通道仅约 ``41.6 GB/s`` )。LLM的Token生成阶段(Decode阶段)是典型的内存带宽受限型(Memory-Bound)任务，更高的内存带宽意味着在CPU上跑量化大模型时，首字母延迟和每秒生成Token速度会明显更快

- 兼容机上的 :ref:`xeon_e-2274g` (CPU+iGPU协同)

  - **CPU 端限制** : 由于 Coffee Lake 架构 **缺乏 AVX-512 和 VNNI 指令集** ，CPU在处理 ``INT8`` / ``FP16`` 量化矩阵运算时只能依赖传统的 ``AVX2/FMA3`` 指令，计算效率较低，且受限于双通道内存带宽
  - **iGPU(HUD P630)补充** : E-2274G 集成了 UHD P630 核显。OpenVINO允许直接将推理设备指定为核显( ``-d GPU`` )。虽然P630执行单元(EU)较少、算力有限，但是使用OpenVINO将轻量级模型(如 Embedding 模型、小型视觉模型或1B~3B的小语言模型)挂载到核显运行，可以卸载CPU负载

总之:

- **用于 CPU 端 OpenVINO 大模型推理** : :ref:`dell_t5820` ( :ref:`xeon_w-2235` )是更好的选择，凭借四通道内存带宽与AVX-512 VNNI硬件减速，它在纯CPU跑 :ref:`openvino` 或 :ref:`ollama` / :ref:`llama.cpp` 时的性能远超 :ref:`xeon_e-2274g`
- :ref:`intel_c246` 兼容机则使用3块 :ref:`tesla_a2` 的Tensor Core进行CUDA/TensorRT推理， :ref:`xeon_e-2274g` 主要负责调度，本地核显可辅助运行小型辅助AI任务

协同策略
===========

实际上由于 E-2274G 内置的 **UHD P630 只有 24 个执行单元（EU）** ，属于基础级核显，在协同推理时建议遵循以下原则:

- **不要用** ``MULTI:GPU,CPU`` 让核显和 CPU 共同跑大模型（LLM）: 因为 P630 的矩阵算力和共享内存带宽很弱，如果强行让它参与 LLM 的矩阵乘法，反而可能拉低 CPU 整体的生成吞吐量率（TPS）。
- 最佳策略是"各司其职":

  - 核显 P630：单独运行 **OpenVINO Embedding / Clip / OCR / 小型视觉模型** （通过 ``-d GPU`` 指定）。
  - CPU E-2274G：运行逻辑控制或少量轻量算子。
  - 3x Tesla A2 独显：通过 CUDA/TensorRT/vLLM 承担主要的卡级算力开销。


参考
======

- gemini
