.. _modelscope:

==========================
ModelScope
==========================

由于Hugging Face下载非常缓慢，虽然使用 HF-Mirror 能够加速，但是如果某些模型认证拒绝(例如我在Hugging Face上注册为China用户，就会拒绝下载 :ref:`llama` 模型)，即使使用 HF-Mirror 也无法下载。此时就需要换国内的模型网站来下载，例如使用魔搭，也就是使用 ``modelscope`` 来下载。

下载
========

- 安装 Modelscope:

.. literalinclude:: modelscope/install
   :caption: 安装modelscope

- 下载 `ModelScope: LLM-Research/Llama-3.3-70B-Instruct <https://modelscope.cn/models/LLM-Research/Llama-3.3-70B-Instruct/files>`_

.. literalinclude:: modelscope/download
   :caption: 下载

这个下载是并发执行，能够跑满整个带宽，所以下载非常迅速

导入Ollama
===========

- 编写 ``Llama3.3.Modelfile`` :

.. literalinclude:: modelscope/Llama3.3.Modelfile
   :caption: Modelfile

- 编写 ``Mistral.Modelfile``

.. literalinclude:: modelscope/Mistral.Modelfile
   :caption: Modelfile

这里的 ``From`` 配置必须是Ollama容器内部的路径，我这里采用了 :ref:`ollama_nvidia_a2_gpu_docker` 方法，在容器内部

- 执行导入:

.. literalinclude:: modelscope/ollama_create
   :caption: 导入模型
