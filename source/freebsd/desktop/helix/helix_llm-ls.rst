.. _helix_llm-ls:

=================================
Helix结合llm-ls实现AI辅助编程
=================================

:ref:`hugging_face` 使用 :ref:`rust` 开发了一个 `huggingface/llm-ls <https://github.com/huggingface/llm-ls>`_ ，提供基于LLM来实现的LSP服务器，负责将编辑器的补全请求发送给 :ref:`ollama` 等后端:

- Hugging Face's Inference API
- Hugging Face's text-generation-inference
- :ref:`ollama`
- OpenAI compatible APIs (如 :ref:`llama-cpp-python` 提供模拟OpenAO API的web服务器`)


