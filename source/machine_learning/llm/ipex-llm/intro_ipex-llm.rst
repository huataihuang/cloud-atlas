.. _intro_ipex-llm:

=====================
ipex-llm简介
=====================

``ipex-llm`` 是一个将大语言模型高效运行于Intel GPU、NPU和CPU上的达模型XPU加速库。已经有大量模型( :ref:`llama` , :ref:`ollama` , HuggingFace transformers, LangChain, Llamaindex, :ref:`vllm` 等)70+模型在 ``ipex-llm`` 上得到优化和验证。

硬件要求:  Intel Core Ultra 和 Core 11-14 代集成的 GPUs (iGPUs)，以及 Intel Arc 系列 GPU

.. note::

   我在选购组装 :ref:`nasse_c246` 选择差错，便宜但只支持8代的Intel处理器，很遗憾暂时不能实践intel PGU技术栈

参考
=====

- `ipex-llm/README.zh-CN.md <https://github.com/intel/ipex-llm/blob/main/README.zh-CN.md>`_
