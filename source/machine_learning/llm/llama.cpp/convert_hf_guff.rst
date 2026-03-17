.. _convert_hf_guff:

=======================
将HF转为GUFF
=======================

为了解决 :ref:`docker_compose_ollama` 运行时GUFF兼容问题，我使用 :ref:`huggingface-cli` 下载官方原始的HF文件，自行采用旧版 :ref:`llama.cpp` 工具链进行转换:



