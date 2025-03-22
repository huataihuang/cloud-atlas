.. _tesla_p4:

===============================
Nvidia Tesla P4 GPU运算卡
===============================

.. _egpu_tesla_p4:

eGPU(外置GPU)使用Tesla P4
===========================

很久以前我在考虑如何让自己能够移动工作中使用GPU来完成 :ref:`machine_learning` 学习，考虑使用外置GPU(eGPU):

- 可以用自己的笔记本来完成机器学习，不需要重复投资主机，例如 :ref:`hpe_dl360_gen9`
- 可以随身携带 :ref:`mobile_work`

不过，常规显卡非常沉重庞大，功耗惊人，所以上述想法可能性较低。

NVIDIA的低功耗产品线 P4/T4/A2 给这个想法带来一些希望:

- 淘宝上能够买到比较廉价的 ``OCuLink`` Dock，大约只需要300RMB
- 二手的P4价格较低，虽然显存和主频受限，但是低功耗(70W)也为配合树莓派运行带来便利(省电呀)

我发现类似的想法其实国外网友已经有一些实践案例，例如 `Jeff Geerling博客: #gpu <https://www.jeffgeerling.com/tags/gpu>`_ 有几篇关于外置显卡(eGPU)的文章，提供了借鉴。而我的想法是不求最高性能，力求在有限的功耗下实现基本的 :ref:`llm` 推理。

最终我购买了 Tesla P4 + 散热风扇，和 :ref:`tesla_p10` 一同安装在 :ref:`nasse_c246` 所使用的ITX小机箱中:

- NVIDIA Tesla P10具备 ``24GB`` 显存，能够运行较大规模的LLM ( ``deepseek-r1 32b`` )，连接 :ref:`nasse_c246` 的PCIe插槽，通过 :ref:`freebsd` 构建一个 :ref:`freebsd_machine_learning`
- NVIDIA Tesla P4低功耗但 INT8 性能卓越，通过 ``OCuLink`` 连接 :ref:`pi_5` 用于AI生图和尝试边缘推理

参考
======

- `LLMs accelerated with eGPU on a Raspberry Pi 5 <https://www.jeffgeerling.com/blog/2024/llms-accelerated-egpu-on-raspberry-pi-5>`_
