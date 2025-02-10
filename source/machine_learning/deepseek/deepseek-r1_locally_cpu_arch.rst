.. _deepseek-r1_locally_arch:

=================================
本地化部署DeepSeek-R1架构
=================================

深度求索(DeepSeek)
====================

2024年12月26日，深度求索公司推出的DeepSeek-V3震动了世界:

- DeepSeek表示该大模型的训练系基于2048块英伟达H800型GPU（针对中国大陆市场的低配版GPU）集群上运行55天完成，训练耗资557.6万美元
- DeepSeek-V3的评测成绩超越Qwen2.5-72B（阿里自研大模型）和LLaMA 3.1-405B（Meta自研大模型）等开源模型，能与GPT-4o、Claude 3.5-Sonnet（Anthropic自研大模型）等闭源模型相抗衡
- 由于训练费用仅为业界标杆OpenAI的几十分之一，而性能比肩，迅速在业内外引起震动， :strike:`并导致英伟达股股价大跌18%`

2025年1月20日， DeepSeek发布并开源了DeepSeek-R1模型:

- DeepSeek-R1模型在数学、代码、自然语言推理等任务上，性能与OpenAI o1正式版相当
- (1月10日)DeepSeek为iOS和安卓系统发布其首款免费的基于DeepSeek-R1模型聊天机器人程序
- DeepSeek开源其生成式人工智能算法、模型和训练细节，允许其代码可被免费地使用、修改、浏览和构建使用文档

尽管毁誉参半，但是这是目前大陆人民能够使用的最好的国产模型，能够以低廉的价格享受到接近GPT-4的服务。

本地部署DeepSeek-R1
=====================

.. note::

   我是逐步在实践部署中摸索学习，所以初始文档比较简陋也不一定正确，有待逐步完善。

GPU硬件架构
-------------

- R1 或 R1-Zero满血版(671B): 大约需要16-18张H100 GPU卡
- R1-distill-Qwen14B: RTX4060S(16GB)显卡

由于我只有 :ref:`tesla_t10` (16GB) 和 :ref:`tesla_p10` (24GB)，所以可行的是部署 DeepSeek 蒸馏LLama-8B 或 Qwen 2.5 32b


CPU硬件架构
-------------

在X上有一个 `768GB内存，双AMD EPYC处理器本地化部署DeepSeek-R1的讨论(X) <https://x.com/carrigmat/status/1884244369907278106?s=46&t=5DsSie6D9vxgUafSFmo6EQ>`_ 提供部署案例以及使用经验:

- 可行: 能够加载完整模型
- LLM生成的瓶颈是内存带宽，所以CPU不需要最高端的

- 系统调优:

参考
=======

- `768GB内存，双AMD EPYC处理器本地化部署DeepSeek-R1的讨论(X) <https://x.com/carrigmat/status/1884244369907278106?s=46&t=5DsSie6D9vxgUafSFmo6EQ>`_ huggingface工程师Matthew Carrigan在 **本地CPU** 上运行Deepseek-R1 670B模型，无蒸馏，Q8量化，实现全质量，总成本6000美元(GPU版本得10万美元+)
- `一文速览DeepSeek-R1的本地部署——可联网、可实现本地知识库问答：包括671B满血版和各个蒸馏版的部署 <https://blog.csdn.net/v_JULY_v/article/details/145429696>`_ 好文
- `wikipedia: 深度求索 <https://zh.wikipedia.org/wiki/%E6%B7%B1%E5%BA%A6%E6%B1%82%E7%B4%A2>`_
- 知乎 `保姆级教程 Ollama 部署 DeepSeek-R1 本地模型 <https://zhuanlan.zhihu.com/p/20921319481>`_
