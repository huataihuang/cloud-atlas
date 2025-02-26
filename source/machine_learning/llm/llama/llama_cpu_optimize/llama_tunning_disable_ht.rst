.. _llama_tunning_disable_ht:

===================================
关闭CPU超线程(HT)优化LLaMA推理速度
===================================

结论
======

- 我在 :ref:`hpe_dl380_gen9` 上关闭超线程HT对比测试，很遗憾没有看到推理性能的明显提高( ``0.66~0.7 token/s`` )
- 但是感觉整个答复过程时间缩短，消耗的token减少了(why?)

----

- DeepSeek R1的推理确实厉害，特别是重复创意的文字类

  - 玄幻小说套路明显，对于训练后的结果就比较符合既定风格，没有漏洞
  - 影评类验证准确，看起来训练文本覆盖到了之后就能成功"推理"( ``概率`` )，那么如果给DeepSeek看一个全新从未见过的电影，能总结影评么?

实践
=====

在网上曾经看到过不少人提及CPU超线程会拖累基于CPU的LLM推理速度，所以我关闭了 :ref:`hpe_dl380_gen9` BIOS中CPU超线程成功能进行对比。运行命令和测试命令不变:

.. literalinclude:: llama_tunning_disable_ht/run_model
   :caption: 运行LLaMA
   :emphasize-lines: 5

这里使用了指定线程数量 ``24`` ，是指定运行 ``llama.cpp`` 的使用CPU数量?对运行有影响么?

从运行提示来看:

.. literalinclude:: llama_tunning_disable_ht/run_model_parameter
   :caption: ``llama.cpp`` 运行参数显示
   :emphasize-lines: 3

``llama.cpp`` 激活了CPU运行的硬件加速: 

- ``SSE3`` 
- ``SSSE3`` 
- ``AVX`` 
- ``AVX2`` 
- ``F16C`` 
- ``FMA`` 
- ``LLAMAFILE``
- ``OPENMP``
- ``AARCH64_REPACK``

完整的server端启动信息

.. literalinclude:: llama_tunning_disable_ht/run_llama_console
   :caption: 完整 ``llama.cpp`` 服务端控制台信息

运行1
============

**比较奇怪** 这次关闭了超线程之后同样的问题，返回的结果中少了开头一大段所谓"思考过程"，简洁了很多: 消耗了更少的token就返回了结果。也就是说，答复的时间大为缩短(只用了15分钟)，虽然速度变化不大()。

- 运行结果:

.. literalinclude:: llama_tunning_disable_ht/run_llama_console_result
   :caption: 完整 ``llama.cpp`` 服务端控制台信息显示的统计结果
   :emphasize-lines: 10

可以看到推理速度是 ``0.707token/s``

运行1返回结果
--------------

.. include:: llama_tunning_disable_ht/result1.md
   :parser: myst_parser.sphinx_

运行2
===========

- 运行2问题:

.. literalinclude:: llama_tunning_disable_ht/question2
   :caption: 运行2问题

- 运行2控制台统计:

.. literalinclude:: llama_tunning_disable_ht/run_llama_console_result2
   :caption: ``llama.cpp`` 服务端控制台统计结果
   :emphasize-lines: 11

推理速率是 ``0.711 token/s``

运行2返回结果
---------------

.. include:: llama_tunning_disable_ht/result2.md
   :parser: myst_parser.sphinx_

这里回答夏威夷州花 "木槿" 看来是对的，我在网上查了，夏威夷州花是 「黃色扶桑花」(Hibiscus) ，又稱「木槿」的扶桑花。

运行3
===========

- 运行3问题:

.. literalinclude:: llama_tunning_disable_ht/question3
   :caption: 运行3问题


- 运行3控制台统计:

.. literalinclude:: llama_tunning_disable_ht/run_llama_console_result3
   :caption: ``llama.cpp`` 服务端控制台统计结果
   :emphasize-lines: 10

推理速率是 ``0.659 token/s``

这个影评结果写得很好，但我不知道这是从哪些影评中提炼出来的

运行3返回结果
---------------

.. include:: llama_tunning_disable_ht/result3.md
   :parser: myst_parser.sphinx_

运行4
==========

- 运行4问题:

.. literalinclude:: llama_tunning_disable_ht/question4
   :caption: 运行4问题

- 运行4控制台统计:

.. literalinclude:: llama_tunning_disable_ht/run_llama_console_result4
   :caption: ``llama.cpp`` 服务端控制台统计结果
   :emphasize-lines: 10

推理速率是 ``0.666 token/s``

运行4返回结果
---------------

.. include:: llama_tunning_disable_ht/result4.md
   :parser: myst_parser.sphinx_


