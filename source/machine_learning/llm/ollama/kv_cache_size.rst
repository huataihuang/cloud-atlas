.. _kv_cache_size:

====================
KV Cache显存大小
====================

在大语言模型中，KV Cache（Key-Value Cache） 的显存开销可以通过一个精确的数学公式来计算。这个公式由模型的层数、注意力头数、隐藏层维度以及你设定的上下文长度（Token 数）共同决定。

KV Cache 开销计算公式
======================

对于单次请求（Batch Size = 1），在 FP16（半精度，每个参数 2 字节） 原生状态下，KV Cache 的总显存开销公式为:

.. literalinclude:: kv_cache_size/caculate
   :caption: KV缓存大小计算

符号说明:

- 第一个 ``2`` : 因为同时需要缓存 Key (K) 和 Value (V) 两个矩阵
- L (Layers)：模型的层数（例如 Qwen3.8-27B 有多层 Transformer Block）
- H(kv)(Key-Value Heads)：键值注意力头数。如果模型使用了 GQA（Grouped-Query Attention，分组查询注意力，如现代 Qwen 系列），H(kv) 会远小于总注意力头数 H，这也是节省显存的关键。
- D(head)(Head Dimension): 每个注意力头的维度（通常为 D=HiddenSize/H）
- S (Sequence Length / Token 数)：当前的上下文长度（例如 65536 或 131072）
- BytesPerParam：每个数值占用的字节数:

  - FP16 / BF16 = 2 字节
  - Q8_0 量化 (OLLAMA_KV_CACHE_TYPE=q8_0) = 1 字节
  - Q4_0 量化 (OLLAMA_KV_CACHE_TYPE=q4_0) = 0.5 字节

- 最后一个 2：代表 Key 和 Value 分别双向占用（在大多数标准实现中，包含双向存储或因果掩码对齐的冗余分配系数）

Qwen3.8:27b 为例
------------------

.. note::

   gemini计算和说明，仅供参考，待实践

Qwen/Qwen3.8-27B 的底层架构参数，它采用的是 **混合注意力架构（Hybrid Attention：64层中只有16层是 Full Attention，其余48层是线性注意力 Linear Attention）** 。这导致它实际的 KV Cache 显存开销远低于传统的纯 Full Attention 稠密模型。

根据 Qwen3.8-27B 的模型结构（64层中仅 16 层 Full Attention，4 个 KV Heads，head_dim=256）:

- 原生 FP16 状态下：每个 Token 仅占用 64 KiB 的 KV Cache（即每 64K 上下文仅需 4 GB，哪怕 256K 也只需要 16 GB）
- 开启 OLLAMA_KV_CACHE_TYPE=q8_0 后：显存占用直接再砍一半，每 64K 上下文仅需 ~2 GB（256K 也仅需 ~8 GB）

.. csv-table:: Qwen3.8-27B不同上下文KV缓存大小
   :file: kv_cache_size/size.csv
   :widths: 15,15,15,15,15,25
   :header-rows: 1

量化
-----

配置的 ``OLLAMA_KV_CACHE_TYPE=q8_0`` 时:

- BytesPerParam 直接从 2（FP16）降到了 1（8-bit）。
- KV缓存大小会减半

Modelfile 设置128K
======================

受益于 Qwen3.8 的混合线性注意力架构:

- 设置 64K (65536) 是绝对的黄金甜点：总占用仅约 36GB，每张 Tesla A2 均摊约 12GB，还有 4GB 单卡安全余量，既不会 OOM，也不会因为上下文过大导致线性推理速度明显下降。
- 分析大型代码库，甚至可以直接设 128K (131072)：总占用约 39.5GB，只要确保环境变量中开启了 OLLAMA_SCHED_SPREAD=1（三卡均匀分配）和 OLLAMA_KV_CACHE_TYPE=q8_0，依然可以稳稳全部装入 100% GPU。
- 不建议直接拉满 256K：虽然理论总显存约 45GB 看似小于 48GB，但因为 3 张卡张量切分时各卡权重和状态缓存不可能做到绝对 1:1:1 平均，很容易出现某一张卡突破 16GB 单卡上限导致部分层掉回 CPU。

.. note::

   我准备看实际情况再决定，如果频繁出现OOM，则调整为 ``128k``

- 创建 ``Modelfile``

.. literalinclude:: kv_cache_size/Modelfile
   :caption: 调整kv缓存上下文128K

- 创建自定义模型(命名 ``qwen3.8:27b-q8_0-128k`` )

.. literalinclude:: kv_cache_size/create_model
   :caption: 创建自定义模型

- 启动并验证模型:

.. literalinclude:: kv_cache_size/run_model
   :caption: 运行模型

- 在另一个终端窗口验证显存占用:

.. literalinclude:: kv_cache_size/ps
   :caption: 检查模型显存

参考
======

- gemini
