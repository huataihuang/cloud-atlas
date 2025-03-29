.. _intro_vllm:

===================
vLLM简介
===================

.. _ollama_vs_vllm:

Ollama vs. vLLM
===================

- Ollama可以易于使用，几乎不需要配置
- Ollama支持不同架构，可以使用GPU也可以使用CPU; vLLM :strike:`只支持GPU` 主要支持GPU，但是也可以使用CPU( :ref:`avx` 512)

  - 如果有合适的GPU硬件，使用vLLM效率更高
  - vLLM主要使用 :ref:`python` 编写，核心则使用CUDA编程，代码据说非常高效整洁(待验证学习)

- vLLM速度快于Ollama(待验证)

参考
======

- `Ollama vs VLLM: Which Tool Handles AI Models Better? <https://medium.com/@naman1011/ollama-vs-vllm-which-tool-handles-ai-models-better-a93345b911e6>`_
- `Ollama or vllm for serving <https://www.reddit.com/r/LocalLLaMA/comments/1g7c4k5/ollama_or_vllm_for_serving/>`_
