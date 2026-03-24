.. _intro_llama-cpp-python:

====================================
Python Bindings for llama.cpp简介
====================================

``llama-cpp-python`` 是基于 :ref:`llama.cpp` 库的Python binding，提供了:

- 通过 ``ctypes`` 接口底层访问C API
- 为文本完成实现的高层Python API

  - 类似OpenAI的API
  - 兼容LangChain
  - 兼容LlamaIndex

- OpenAI兼容web服务器

  - 本地Copilot替代
  - 函数调用支持
  - 版本API支持
  - 多模态

简单来说， ``llama-cpp-python`` 通过对 ``llama.cpp`` 的Python封装，实现了:

- 无依赖WEB服务器: 自带基于FastAPI的服务器，可以直接模拟OpenAI的API接口。这样任何支持OpenAI后端的插件(如 :ref:`vscode` 的Continue,Cursor,Copilot等)都可以无缝切换
- 极致的硬件控制:

  - 异构计算: 可以精确指定多少Layer跑在 :ref:`amd_radeon_instinct_mi50` ，多少Layer跑在 :ref:`tesla_a2` 上(通过不同的 ``n_gpu_layers`` 参数)
  - 内存压缩: 支持GGUF格式的所有量化级别(从Q2_K到Q8_O)，这对于管理显存非常重要

- 不仅是服务器，也是库: 可以直接在Python脚本中 ``import llama_cpp`` ，就像普通函数一样进行推理，而不需要通过HTTP协议绕一圈

.. csv-table:: ``llama-cpp-python`` 和 Ollama对比
   :file: intro_llama-cpp-python/compare.csv
   :widths: 20, 40, 40
   :header-rows: 1
