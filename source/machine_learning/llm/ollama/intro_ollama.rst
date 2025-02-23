.. _intro_ollama:

===============
ollama简介
===============

``Ollama`` 是一个使用 :ref:`golang` 开发的大模型运行工具，支持不同的后端 `Ollama Library <https://ollama.com/library>`_ 。由于使用方便，跨平台，目前很受入门用户的欢迎。

对比
========

Hacker News上有一个讨论 `Reminder: You don't need ollama, running llamacpp is as easy as ollama. Ollama is just a wrapper over llamacpp. <https://news.ycombinator.com/item?id=40693391>`_ :

- ``ollama`` 实际上是 ``llama.cpp`` 的包装，虽然提供了更为简单的使用方法，但也导致无法在细粒度上控制 ``llama.cpp``
- ``ollama`` 的模型文件需要通过 ``import`` 导入，而不是直接使用下载的 ``.gguf``
- 既然 ``llama.cpp`` 现在已经提供了 ``llama-server`` 输出服务，并且能够兼容 ``OpenAI`` 的API，是否还需要再运行 ``ollama`` 这个包装层?

.. note::

   我感觉深入学习 ``llama.cpp`` 的部署可能更可以控制底层技术，并且减轻中间层的消耗。但是也带来很多细节需要花费精力。这是一个投入产出的平衡，有待探索。

参考
======

- `如何在服务器上通过ollama部署本地大模型 <https://www.cnblogs.com/sxxs/p/18473835>`_
- `Ollama 架构解析 <https://blog.inoki.cc/2024/04/16/Ollama-cn/>`_ 分析ollma代码结构以及和llama.cpp的关系，非常好
