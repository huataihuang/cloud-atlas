.. _llm_token:

==================
大模型Token
==================

大语言模型 :ref:`llm` 在训练语料数量、上下文限制、生成速度都使用 ``Token`` 表示:

- Token指语言模型中用来表示中文汉字、英文单词或者中英文短语的符号
- Token可以是单个字符，也可以是多个字符组成的序列

ChatGPT模型使用 ``Byte Pair Encoding`` (BPE)，一种子词分词方法，可以将赐予进一步划分为更小的可重复部分，进行文本编码。这种编码方式在处理不同语言是的效率可能有所不同。

对于汉语等字形语言，一个token可能只包含一个字符，但是对于英文等语素语言，一个token可能包含一个或多个单词。

OpenAI官方文档介绍: 1000个token通常代表750个英文单词或者500个汉字。一个token大约为4个字符或0.75个单词。

一个Token有多少个汉字，具体取决于分词器的设计。目前各种tokenization技术，涉及到将文本分割为有意义的单元，以捕捉其中语义和句法结构，如字级、子字级或字符集。

大模型的输出速度
===================

生成token的速度分为两个阶段:

- ``prefill`` : 预填充，并行处理输入的tokens
- ``decoding`` : 解码，逐个生成下一个token

评估方法:

- 首token延迟, Time To First Token (TTFT), prefill, Prefilling:

从输入到输出第一个token 的延迟

- 每个输出 token 的延迟（不含首个Token）,Time Per Output Token (TPOT)

第二个token开始的吐出速度

- 延迟Lantency

理论上即从输入到输出最后一个 token 的时间，原则上的计算公式是：Latency = (TTFT) + (TPOT) * (the number of tokens to be generated)

- Tokens Per Second (TPS)

(the number of tokens to be generated) / Latency

一种提升速度的方法：KV Cache
=============================

KV Cache 采用以空间换时间的思想，复用上次推理的 KV 缓存，可以极大降低内存压力、提高推理性能，而且不会影响任何计算精度。

decoder架构里面最主要的就是 transformer 中的 self-attention 结构的堆叠，KV-cache的实质是用之前计算过的 key-value 以及当前的 query 来生成下一个 token。

参考
=====

- `大模型中的Token,一文读懂 <http://www.360doc.com/content/24/0713/11/78025769_1128658686.shtml>`_
- `如何评判大模型的输出速度？首Token延迟和其余Token延迟有什么不同？ <https://juejin.cn/post/7401828147090817039>`_
