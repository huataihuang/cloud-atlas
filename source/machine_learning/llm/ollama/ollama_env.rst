.. _ollama_env:

==========================
Ollama环境变量
==========================

.. _ollama_sched_spread:

``OLLAMA_SCHED_SPREAD``
==========================

``OLLAMA_SCHED_SPREAD=1`` 强制将模型按层切分/流水线并行(Pipeline Parallelism / Layer-based Splitting)并且按照多张卡的显存比例分布到多张卡上。这个层分布是 :ref:`llama.cpp` 采用的方案，做法是以完整的 Transformer 层为基本单位。例如我在 :ref:`podman_compose_ollama_amd_mi50` 选用了 ``qwen3-coder-next:q4_K_M`` 模型，该模型大约52GB超出了单张 :ref:`amd_mi50` 显存，并且该模型有 ``49层`` ，此时 **GPU 0 完整承载前 25 层，GPU 1 完整承载后 24 层** 。

这个参数并不是必须的，因为 Ollama 实际上会自动触发超过单卡大模型的自动按层切分。

使用这个 ``OLLAMA_SCHED_SPREAD=true`` 对于小于 32GB 的小模型（如 7B、14B）不友好，反而是负优化。因为会强制把原本能够在一个GPU卡装载的小模型切分到多个卡上，对于没有高速互联(NVLink)的环境，PCIe接口带宽延迟会影响驱动层同步性能。

.. _ollama_max_loaded_models:

``OLLAMA_MAX_LOADED_MODELS``
==================================

``OLLAMA_MAX_LOADED_MODELS=1`` 锁定单模型驻留，该参数对大模型友好，能够确保整个系统在加载大模型之后，即使剩余显存能够装载其他小模型也不会并发加载模型。因为这样能够保留所有显存给大模型用于KV缓存，不会因为并发加载模型而直接导致大模型的 KV Cache 空间被严重挤压(进而导致频繁触发上下文截断或显存页表置换)。

代价是 **丧失了多模型秒级切换的便利性** 。不过，如果以大代码模型主力推理为主的工作流来说，这个代价完全可以忽略。

.. _ollama_keep_alive:

``OLLAMA_KEEP_ALIVE``
=========================

``OLLAMA_KEEP_ALIVE=24h`` 核心作用就是让模型在显存中长驻（Pin in VRAM），即使在长时间没有任何推理请求（Inference Request）的情况下，Ollama 也不会将其从双卡 MI50 的显存中卸载。

这个参数可以避免繁重的"冷加载(Cold Load)": 例如我使用 ``qwen3-coder-next:q4_K_M`` 高达50+GB模型，如果被卸载后重新加载，系统需要将数十 GB 的权重文件从磁盘（或系统缓存）重新读取、分配虚拟地址，并重新初始化双卡的 KFD 映射。这个过程会消耗数秒甚至数十秒的时间，并且会瞬间拉满 CPU 和 I/O。设置 ``24h`` 后，模型在第一次加载完成就会一直驻留在显存中，随时处于"热备"状态。

如果不设置该参数，Ollama 的默认 ``keep_alive`` 时间通常是 ``5分钟(5m)`` 。也就是说，只要你 5 分钟不和它对话，它就会自动释放显存，下次再用时又得重新加载。对于大模型来说，这个默认值频繁触发显然是不合适的。

参考
========

- `Ollama Environment Variables — Complete Reference <https://medium.com/@smrati.katiyar/ollama-environment-variables-complete-reference-909fe2533786>`_
