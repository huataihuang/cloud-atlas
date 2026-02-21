.. _ollama_amd_gpu_docker:

========================================
在Docker中Ollama使用AMD GPU运行大模型
========================================

我之前在物理服务器上直接 :ref:`ollama_amd_gpu` ，现在由于在服务器上安装了多块NVIDIA和AMD的计算卡，所以我改进为采用 :ref:`docker` 容器化运行，以便能够隔离不同的GPU设备并且能够灵活调用。

准备工作
==============

- 两块32GB的 :ref:`amd_radeon_instinct_mi50` 能够运行32B推理模型，甚至可以运行量化版70B模型
- :ref:`container_direct_access_amd_gpu` 为运行Ollama准备好 :ref:`docker` 运行环境

运行Ollama容器
===============

.. literalinclude:: ../../../docker/gpu/container_direct_access_amd_gpu/docker_run
   :caption: 授权docker容器访问host主机的AMD GPU

此时容器运行了Ollama服务( ``/bin/ollama serve`` )

模型选择
==============

.. note::

   本段模型对比选择由gemini推荐

由于服务器安装了 两块32GB的 :ref:`amd_radeon_instinct_mi50` ，合计 **64GB** 显存适合运行 70B 级别（大模型门槛）和 MoE（混合专家）架构模型

通用类型
---------

- Qwen3-Next-30B-A3B (Reasoning 版): Qwen3 系列中的 30B 专家模型，采用了 A3B（Advanced Attention Architecture）架构，是2026年初最适合64GB显存环境的全能型模型

  - 完美适配显存：在 Q8（8-bit）量化下仅占用约 34GB 显存，留有充足空间（约 30GB）给 KV Cache，这意味着你可以处理长达 64k-128k 的长文本对话而不爆显存。
  - 双模式切换：支持“思维模式（Thinking）”，在处理复杂逻辑、翻译和常识推理时，智力表现逼近 GPT-4o。
  - 在极短文本的响应速度上，可能略慢于非推理版的 14B 模型。

- Llama-3.3-70B (Q4_K_M量化): 全球生态最稳固的模型。在 64GB 显存上，可以跑起 4-bit 量化的 70B 模型

  - 知识面极其广博：在法律、医学和通用常识上非常稳健，回答风格更有“人性”。
  - 双卡均衡：在 Ollama 中，70B 会非常均匀地分布在两块 MI50 上，充分利用 HBM2 带宽。
  - 显存吃紧：4-bit 量化的 70B 模型大约占用 42GB-45GB。剩下的显存只能支持约 8k-16k 的上下文。如果你发给它的文档太长，模型会变笨或报错。

- DeepSeek-V3-Lite / GPT-OSS-20B: 追求极速生成（例如每秒输出 50-80 个字），MoE 架构是首选

  - 推理速度极快：MoE 架构每次只激活部分参数，在 MI50 上的吞吐量远超同体积的 Dense 模型。
  - 支持超长上下文：这类模型通常针对 RAG（检索增强生成）优化，适合处理你刚才提到的“全项目代码分析”。
  - 缺点: 在极少数情况下，MoE 模型可能会出现“幻觉”，逻辑连贯性在超长对话中偶尔不如 70B 模型。

代码开发
------------

代码开发可以采用 :ref:`ollama_integrations_coding` :

- ollama launch claude (行为模拟模式): 模拟 Anthropic Claude 系列的对话风格和逻辑思维

  - 强解释性：它不仅给出代码，还会详细解释每一行代码的意图，适合学习和 Code Review
  - 防御性编程：更倾向于在代码中加入错误处理和边界检查
  - 对话记忆：对上下文的长程关联优化得更好，适合处理多文件的大型架构讨论

- ollama launch codex (纯净补全模式): 模拟最初的 OpenAI Codex 或 GitHub Copilot 的底层逻辑

  - 极简输出：通常不废话，直接给出代码块
  - IDE 对齐：它的输出格式经过优化，可以直接被你的 VS Code 或 Cursor 插件无缝解析
  - 性能优先：减少了自然语言生成的 Token 消耗，推理速度（TPS）通常比 claude 模式更快

可行方案:

- 长上下文开发 (claude 模式): ``ollama launch claude --model qwen3-coder-next:70b``

  - Qwen3-Coder 的 70B 版本在模拟 Claude 的复杂逻辑时表现最强

- 实时代码自动补全 (codex 模式): ``ollama launch codex --model qwen3-coder-next:14b``

  - 14B 模型在 MI50 上的推理几乎是瞬间的，适合作为 IDE 后端，实现零延迟的 Tab 补全(也可以选择32B模型)

加载模型
==========

Qwen3-Next
-----------

.. literalinclude:: ollama_amd_gpu_docker/ollama_run_qwen3
   :caption: 运行 ``qwen3-next`` 模型

.. note::

   注意 :ref:`model_name_means`

   由于 Qwen3-Next 采用了 Gated DeltaNet (线性注意力的变体) 架构，它处理长文本的效率极高。在 12GB 的 KV 缓存下，它能支持比普通 Llama 模型多出数倍的上下文长度。

Qwen3-Coder-Next
------------------

.. literalinclude:: ollama_amd_gpu_docker/ollama_run_qwen3-coder-next
   :caption: 运行 ``qwen3-coder-next`` 模型

- ``--set parameter num_ctx 32768`` (上下文窗口)

  - 默认的 4k 或 8k无法处理大量文件，所以设置为32k
  - 硬件对齐：Qwen3 系列支持超长上下文，但在 64GB 显存中，扣除模型占用的 50GB 左右，32k 是一个非常稳妥的平衡点。它能保证你在处理中大型代码文件时，AI 不会因为“忘记”前面的内容而产生幻觉。

- ``--set parameter num_gpu 999`` (强制全层加载)

  - 作用：确保将模型的所有层（Layers）全部推入两块 MI50。
  - 效果：如果不设置，Ollama 可能会保守地将几层留在 CPU (768GB RAM) 里，这会导致推理速度瞬间从“秒出”降到“字蹦”。

- ``--set parameter repeat_penalty 1.1`` (重复惩罚)

  - 编程专用：Qwen3 在生成超长代码时，偶尔会陷入某种循环。稍微调高惩罚值（默认 1.0）可以有效避免 AI 反复输出同一行注释或代码。

- 要让它一次性分析整个项目，除了上述命令，还需要调整 ``num_predict`` （最大生成长度）: ``--set parameter num_predict 4096`` (需要 AI 帮你写一个超长的完整文件，例如超过 1000 行代码)

配置文件
~~~~~~~~~

为了能够不必每次都输入大量参数，可以将参数写入文件:

- 在Host主机创建 ``Coder.Modelfile``

.. literalinclude:: ollama_amd_gpu_docker/Coder.Modelfile
   :caption: 配置 ``Coder.Modelfile``

- 导入并运行:

.. literalinclude:: ollama_amd_gpu_docker/MyCoder
   :caption: 导入并运行



Llama3
-------

.. literalinclude:: ollama_amd_gpu_docker/ollama_run_llama3
   :caption: 运行 ``llama3`` 模型

Llama 3.3 是典型的 Dense（稠密）模型，对显存的占用和计算资源的消耗更加“扎实" (参数及说明由gemini推荐):

- 块 MI50 (64GB) 上，由于 Llama 3.3-70B (q4_K_M) 自身已经占据了约 42GB - 45GB 的空间，留给上下文（KV Cache）的余量比 Qwen3 要稍微紧凑一些
- ``num_ctx 24576`` (约 24k 上下文): 在 70B 规模下，32k 上下文可能会将显存撑到 60GB 以上。为了留出一些缓冲空间防止 OOM（显存溢出）导致容器崩溃，24k 是一个极度稳定的上限(大约能一次性放入15-20 个标准长度的 Python 文件进行分析)
- ``num_gpu 999`` (全显卡加速): Llama 3.3-70B 有 80 层（Layers）。强制设为 999 可以确保 Ollama 将这 80 层均匀分布在两块 MI50 上（每块卡约负担 40 层）
- ``num_thread 16`` (多线程预处理): 虽然推理靠 GPU，但模型加载和 Prompt 的初步解析（Prefill 阶段）会用到 CPU，设置 16 线程可以显著加快按下回车到 AI 开始出字之间的响应速度



参考
======

- `Ollama is now available as an official Docker image <https://ollama.com/blog/ollama-is-now-available-as-an-official-docker-image>`_
- `Docker hub: ollama <https://hub.docker.com/r/ollama/ollama>`_ 官方镜像提供了使用NVIDIA和AMD GPU容器的方法，非常实用 
