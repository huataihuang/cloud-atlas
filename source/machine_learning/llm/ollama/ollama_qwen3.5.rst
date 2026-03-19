.. _ollama_qwen3.5:

==================
Ollama运行Qwen3.5
==================

2026年初Qwen 3.5推出，作为多模态大模型，能够处理文本和图像，并且采用了最新的MoE(Mixture of Experts)架构优化。

我通过 :ref:`modelscope` 从阿里的魔搭平台下载模型文件，尝试在Ollama中运行

模型下载和导入
===============

- 下载模型文件:

.. literalinclude:: ../../hugging_face/modelscope/download_qwen3.5
   :caption: 下载Qwen3.5模型

需要注意 ：

- Qwen3.5 这种多模态模型在 GGUF 格式下，通常是分体式的:

  - ``.gguf``` 文件：包含 LLM 的语言模型权重
  - ``mmproj`` 文件: 即 ``Multi-Model Projector`` ，专门负责将图片像素转为LLM能理解的Token

在 ``Modelfile`` 中必须同时导入 ``.gguf`` 文件和配套的 ``mmproj`` 文件(推荐采用fp16)，这样才能让Ollama能够处理图片，否则就会报错 ``500: Failed to create new sequence: failed to process inputs: this model is missing data required for image input``

- 编辑 ``Qwen3.5-35B-A3B.Modelfile``

.. literalinclude:: ../../hugging_face/modelscope/Qwen3.5-35B-A3B.Modelfile
   :caption: 用于导入模型的 Modelfile

- 执行导入:

.. literalinclude:: ../../hugging_face/modelscope/ollama_create_qwen3.5
   :caption: 导入Qwen3.5

异常排查
===========

当通过

.. literalinclude:: ollama_qwen3.5/model_load_fail
   :caption: Ollama加载 ``qwen35moe`` 模型架构失败

从错误日志可以看到 Ollama 不能处理 ``qwen35moe`` 模型架构，这是因为我当前使用的Ollama镜像不是最新版本，无法识别 Qwen3.5 最新的 MoE (Mixture of Experts) 架构优化。

参考 `qwen35/qwen35moe models downloaded from HuggingFace are unsupported. #14503 <https://github.com/ollama/ollama/issues/14503>`_ 可以看到目前Ollama只支持 f32/f16/bf16/q8/q6/q4 tensors，而 :ref:`llama.cpp` 则支持更广泛的tensor量化类型。当在Ollama引擎上运行多模态，目前只支持safetensors导入并量化为包含上述量化类型的 **单个GGUF文件** 。而llama.cpp引擎运行多模态模型，从safetensors导入并量化为更多数据类型是， **权重会被拆分为两个文件** : 文本文件和视觉文件。此时拆分后的模型只能在 :ref:`llama.cpp` 引擎上运行。

需要等 `Revert revert vendor update (Vendor Update to b8353)#14134 <https://github.com/ollama/ollama/pull/14134>`_ 合并以后，Ollama才会同时支持融合模型(由Ollama从safetensors量化的模型)和 **拆分模型** (由 :ref:`llama.cpp` 从safetensors量化的模型)

当前在 ollama Docker官方镜像 ``latest`` 刚推送的版本是 0.18.2 ，是大约16小时前更新的，所以通过以下方法尝试更新到最新版本:

.. literalinclude:: ollama_qwen3.5/pull_ollama_latest
   :caption: 更新最新的ollama镜像

然后再次以最新镜像再次创建ollama容器(见 :ref:`ollama_nvidia_a2_gpu_docker` ):

.. literalinclude:: ollama_qwen3.5/run
   :caption: 再次重建运行Ollama

不过，实践发现这个问题尚未解决。目前还需要等待官方合并补丁以后更新镜像，待解决...
