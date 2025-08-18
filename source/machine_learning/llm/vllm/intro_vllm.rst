.. _intro_vllm:

===================
vLLM简介
===================

``vLLM`` 是一个快速、易用但LLM推理和服务库。最初由加州大学伯克利分校但Sky计算机实验室开发，目前已经发展成一个社区驱动的项目，得到学术界和业界的广泛贡献。

vLLM快速的原因如下:

- 领先的服务吞吐量
- 使用 ``PagedAttention`` 高效管理注意力机制的键值内存(Efficient management of attention key and value memory with PagedAttention)
- 持续批处理传入请求(Continuous batching of incoming requests)
- 使用 CUDA/HIP graph 实现模型加速
- 支持量化(Quantization): GPTQ, AWQ, INT4, INT8, 和 FP8
- 优化的 CUDA 内核: 可与 FlashAttention 和 FlashInfer 集成
- 推测解码(Speculative decoding)
- 分块预填充(Chunked prefill)

vLLM 灵活易用的原因如下:

- 与流行的 HuggingFace 模型无缝集成
- 高吞吐量服务，支持各种解码算法，包括并行采样(parallel sampling)、波束搜索(beam search)等
- 支持分布式推理(distributed inference)的张量(Tensor)、流水线(pipeline、数据和专家并行性(data and expert parallelism)
- 流式输出
- 兼容 OpenAI 的 API 服务器
- 支持 NVIDIA GPU、AMD CPU 和 GPU、Intel CPU、Gaudi 加速器和 GPU、IBM Power CPU、TPU 以及 AWS Trainium 和 Inferentia 加速器
- 前缀缓存(Prefix Caching)支持
- 多 LoRA 支持

.. note::

   前缀缓存(Prefix Caching):

   一种大语言模型推理优化技术，它的核心思想是缓存历史对话中的KV Cache，以便后续请求能直接重用这些中间结果。 这样可以显著降低首token 延迟，提升整体推理效率。 Prefix Caching 尤其适用于多轮对话、长文档问答等高前缀复用场景。

.. note::

   LoRA(Low-Rank Adaptation):

   大模型参数高效微调的一种方法，通过在预训练模型的基础上，添加低秩矩阵来适应特定任务，从而减少了需要训练的参数数量，降低了计算和存储需求，同时保持了模型性能。

vLLM和其他LLM工具对比
========================

.. _ollama_vs_vllm:

Ollama vs. vLLM
-------------------

- Ollama可以易于使用，几乎不需要配置
- Ollama支持不同架构，可以使用GPU也可以使用CPU; vLLM :strike:`只支持GPU` 主要支持GPU，但是也可以使用CPU( :ref:`avx` 512)

  - 如果有合适的GPU硬件，使用vLLM效率更高
  - vLLM主要使用 :ref:`python` 编写，核心则使用CUDA编程，代码据说非常高效整洁(待验证学习)

- vLLM速度快于Ollama

.. _llama.cpp_vs_vllm:

Llama.cpp vs. vLLM
-----------------------

在运行 :ref:`llama` , :ref:`qwen` 这样的大语言模型时，需要使用合适的工具， ``vLLM`` 和 :ref:`llama.cpp` 是两个非常流行的工具:

- vLLM是一个 :ref:`python` 库，设计用于服务于大语言模型，高速处理请求分发给GPU运行:

  - 高吞吐服务( **High Throughput Serving** ): vLLM擅长同时处理批量请求，即使上百个用户同时提交请求也能快速处理
  - 分页注意力机制( **Paged Attention** ): 只能的内存管理技术，不会一次性将所有内容加载到GPU内存中(可能导致系统崩溃)，而是在需要时分页加载和调出数据
  - GPU 优化( **GPU Optimization** ): 支持不同厂商GPU，最大限度提高GPU效率，使其成为处理高负载任务的理想选择
  - 可扩展性( **Scalability** ): 适合企业级应用，可以支撑起整个公司的AI客户服务系统

- :ref:`llama.cpp` 是一个在日常硬件上高效运行LLM的轻量级C++框架:

  - 轻量级高效推理( **Lightweight and Efficient Inference** ): ``llama.cpp`` 专为消费级设备(如笔记本电脑或小型边缘设备，如 :ref:`raspberry_pi` )上进行推理而设计
  - 混合CPU/GPU支持( **Hybrid CPU/GPU Support** ): ``llama.cpp`` 可以同时使用计算机的CPU和GPU，或者哎没有GPU的情况下只使用CPU
  - 灵活量化( **Flexible Quantization** ): ``llama.cpp`` 通过压缩数据(例如，从32位压缩微4位)来减小模型的大小，节约内存并使其运行在低资源配置下
  - 跨平台兼容性( **Cross-Platform Compatibility** ): ``llama.cpp`` 支持各种系统，包括使用GPU的NVIDIA CUDA，或者使用Mac的Apple Metal，甚至使用普通的CPU

总之:

  - ``vLLM`` 适合大型企业级环境(云计算服务、企业应用)，需要强大的GPU硬件来运行，并且通过批量处理能够获得2-3倍吞吐量(在GPU服务器上加载模型，部署为API，能够并发处理100+请求)
  - ``llama.cpp`` 则非常适合个人项目或者性能有限的设备，非常灵活但是不具备伸缩性，所以无法像 ``vLLM`` 处理规模化服务(在本地运行量化模型，能够测试单个查询)

参考
======

- `docs.vllm.ai <https://docs.vllm.ai/>`_
- `Ollama vs VLLM: Which Tool Handles AI Models Better? <https://medium.com/@naman1011/ollama-vs-vllm-which-tool-handles-ai-models-better-a93345b911e6>`_
- `Ollama or vllm for serving <https://www.reddit.com/r/LocalLLaMA/comments/1g7c4k5/ollama_or_vllm_for_serving/>`_
- `Which Performs Better for LLMs, VLLM or Llama.cpp? <https://medium.com/@tam.tamanna18/which-performs-better-for-llms-vllm-or-llama-cpp-eff62b5e25da>`_
