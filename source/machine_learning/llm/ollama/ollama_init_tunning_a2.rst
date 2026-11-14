.. _ollama_init_tunning_a2:

=========================================
Ollama的启动参数调整(NVIDIA Tesla A2)
=========================================

iommu优化
==========

在 :ref:`ollama_workqueue_optimize` 实践中，激活内核 :ref:`iommu` 能够增强内存复制性能:

.. literalinclude:: ../../../kvm/iommu/iommu_grub_config/iommu_grub_config/grub
   :caption: 修订 ``/etc/default/grub`` 添加 IOMMU 配置

更新Grub并重启:

.. literalinclude:: ../../../kvm/iommu/iommu_grub_config/iommu_grub_config/update-grub
   :caption: 更新grub

通过 Modelfile 优化
=====================

- 导出当前模型的 ``Modelfile`` :

.. literalinclude:: ollama_init_tunning_a2/show_modelfile
   :caption: 导出当前Modelfile

- 可以看到初始的 ``Modelfile`` 内容是:

.. literalinclude:: ollama_init_tunning_a2/modelfile_origin
   :caption: 当前Modelfile

- 优化后的 ``Modelfile`` 配置

.. literalinclude:: ollama_init_tunning_a2/modelfile
   :caption: 优化Modelfile

说明
------

- 软件开发温度 ( ``temperature 0.1`` )

  - 写代码和日常闲聊不同，代码对准确性、语法规范和逻辑闭环的要求极高。将温度压低至 ``0.1`` (或 ``0.2`` )，能够最大程度地消除大模型的“发散性”，让生成的代码片段、架构重构建议和 Bug 排查更具确定性与严谨性。

- 超大上下文支持 ( ``num_ctx 262144 / 256k`` )

  - 为了满足 "对大量程序代码进行全局分析、跨文件引用追踪" 的需求，开启 256k 上下文至关重要。
  - ``qwen3.8:27b-q8_0`` 模型权重本身占用约 **30GB** 在 3x Tesla A2（总计 ``48GB VRAM`` ）上，剩余的 ``18GB`` 显存需要用来存放 KV Cache（上下文缓存）。

    - 如果不加限制地塞满 256k 上下文，未经量化的 KV Cache 会瞬间吃光数十 GB 显存，导致显存溢出(OOM)或被迫触发系统 Swap 换页，从而引发严重的 PCIe 总线卡顿和页错误(Page Fault)。
    - Ollama 服务中强制开启 KV Cache 量化(推荐 ``q4_0`` 或 ``q8_0`` )，以压缩 KV Cache 内存占用:

.. literalinclude:: ollama_init_tunning_a2/docker-compose.yml
   :language: yaml
   :caption: 强制KV Cache量化

- 批处理大小降级 ( ``num_batch 128`` )

  - 默认的大 ``num_batch`` (如 ``512`` 或 ``2048`` )在处理超大段代码输入（Prompt Evaluation）时，会在瞬间向显卡和 PCIe 总线抛出巨量数据并发请求。对于没有 NVLink、仅依赖标准 PCIe 互联的 3x Tesla A2 集群来说，这会造成总线瞬时拥堵。
  - 将 ``num_batch`` 下调至 ``128`` ，虽然会稍微增加一点点大文本输入的预填充（ ``Prefill`` ）耗时，但它能极其有效地平抑总线突发峰值，彻底解决多卡流水线并行切片时的显存页错误和通信阻塞。

创建优化参数的模型
-------------------

- 构建优化后的本地模型

.. literalinclude:: ollama_init_tunning_a2/create_code-opt_model
   :caption: 创建优化后的本地模型

- 启动验证:

.. literalinclude:: ollama_init_tunning_a2/run_model
   :caption: 启动验证参数

- 测试性能: 推理速度大约 ``4.7 t/s`` (比之前默认配置的速率 ``5.5 t/s`` 慢了)

.. literalinclude:: ollama_init_tunning_a2/speed
   :caption: 调优后的推理速录降低到 ``4.7 t/s``

32k上下文
-----------

考虑到这里 ``num_ctx`` 拉满到 ``256k`` 虽然能够处理数十万行的超大单个文件，但是超大上下文实际案例较少，但性能影响明显，所以考虑调整为 ``64k`` 或 ``32k``

- 调整为32k上下文:

.. literalinclude:: ollama_init_tunning_a2/modelfile_32k
   :caption: 创建优化后的本地模型(32k上下文)

- 构建优化后的本地模型

.. literalinclude:: ollama_init_tunning_a2/create_code-opt_model_32k
   :caption: 创建优化后的本地模型(32k上下文)

- 测试性能: 推理速度大约 ``5.25 ~ 5.40 t/s`` (接近之前默认配置的速度 ``5.5 t/s`` )

.. wanging::

   新问题出现: 上述参数组合导致了 ``过度思考`` ，整个推理过程时间暴涨数倍，甚至一直无法完成推理: 同样的问题，默认设置半小时完成，现在优化上述参数后已经思考了两个小时还没有结束迹象...

上述 ``Modelfile`` **采样参数修改触发了 Qwen3.8 推理模式的“过度思考（Over-thinking）”与绕圈行为** ，我发现现在在3块 :ref:`tesla_a2` 上推理思考无法结束，反复打转:

- ``temperature 0.1`` 导致“强迫症式死磕”且难以输出结束符:

  - 传统非推理模型用 ``0.1`` 能让输出更稳定，但具备 **强化学习思维链（CoT）的模型在极低温度下会变得极度保守和吹毛求疵** 。
  - 在 ``<think>`` 阶段，模型会对每一个微不足道的假设反复自我怀疑（例如不断生成 ``"Wait, let me double check..."`` ），并且由于概率分布过于尖锐，模型很难采样到结束思考的 ``</think>`` 标记，导致思考链条被无限拉长。

- ``repeat_penalty 1.05`` 迫使推理过程"绕远路" :

  - 最初导出的默认配置中 repeat_penalty 是 ``1`` (完全关闭)。
  - 在逻辑推导和代码分析中，模型必须高频重复同一个变量名、函数名或逻辑前提才能得出结论。一旦开启 ``1.05`` 的重复惩罚，引擎就会强迫模型避开已出现过的关键词，导致它不断换说法、绕弯子重新推导，思考 Token 数量随之翻倍。

- ``num_ctx`` 扩大解除了长度封印:

  - 原本默认上下文较小时，思维链很快会触及窗口上限而被迫收敛；调整到 ``32768`` 后，配合上述两个参数，模型有了充足的空间进行长达数千 Token 的发散推演。

调整采样参数
~~~~~~~~~~~~~~

- 修正 ``Modelfile`` 中的推理采样参数 - 保留针对 3x Tesla A2 硬件优化的 ``num_ctx 32768`` 和 ``num_batch 128`` ，但将采样参数恢复为适合 Qwen3.8 推理模式的区间(temperature 建议 ``0.6`` ，repeat_penalty 必须改回 ``1`` ):

- 修订为合适的温度并关闭重复惩罚:

.. literalinclude:: ollama_init_tunning_a2/modelfile_32k_temp0.6
   :caption: 创建优化后的本地模型(32k上下文，温度0.6)

- 重新创建模型(32k上下文，温度0.6)

.. literalinclude:: ollama_init_tunning_a2/create_code-opt_model_32k_temp0.6
   :caption: 创建优化后的本地模型(32k上下文，温度0.6)

- 测试性能为 ``5.67 t/s`` ，效果还算不错，但是:

  - 思考时间放大了3倍，原先默认配置的 ``qwen3.8:27b-q8_0`` 模型思考约8分钟，调整了温度之后(从1.0调整到0.6)，思考时间变成3倍长度达到了25分钟
  - 推理性能略有提高，达到了 ``5.67 t/s``
  - 回答确实比较严谨，提供了很多思路和内容，但是也感觉模型抓用户的意图有点问题，需要你再次纠正和有意识引导它再思考(通过给出更详细的prompt)
