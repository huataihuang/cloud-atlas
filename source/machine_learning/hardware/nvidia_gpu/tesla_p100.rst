.. _tesla_p100:

===============================
Nvidia Tesla P100 GPU运算卡
===============================

NVidia Tesla P100 PCIe 16 GB 是 NVIDIA 于 2016 年 6 月 20 日推出数据中心计算卡:

- 16nm工艺
- 基于 GP100 图形处理器，其 GP100-893-A1 变体为 支持 DirectX 12
- 大型芯片，裸片面积为 610 平方毫米，拥有 153 亿个晶体管
- 3584 个着色单元、224 个纹理映射单元和 96 个 ROP
- 16 GB HBM2 内存，4096 位内存接口连接
- GPU 的运行频率为 1190 MHz，最高可提升至 1329 MHz，内存运行频率为 715 MHz

P40 vs. P100
=================

P40( :ref:`tesla_p10` ) 和 P100 都采用了相同的 Pascal微架构，同属Telsa数据中心运算卡系列，然而这两块卡定位上是不同的:

- P40具有更多CUDA core以及更快的时钟速度，但是P100的高速内存带宽远超P40(P100的732GB/s vs P40的480GB/s)
- P100适合训练(提供FP16以及更快的内存带宽)，P40/P4适合推理(备更快的int8能力):

  - P100适合训练 - 专为机器学习训练而涉及，针对更密集的计算进行优化，例如制作 LoRA/嵌入/微调模型等，可以
  - P40适合推理 - 针对需要快速分析大量数据的应用程序进行性能优化，非常适合图像识别和自然语言处理等应用

- 两者上市时起始售价相同($5699)，但是目前在二手市场上 :strike:`P100(1450元)略胜P40(1300元)一筹` 大家对P40的24G显存更为看中，短短一周时间P40已经卖断货导致P40售价飙升到1600元反超P100(1450元)，疯了...

.. csv-table:: Tesla P10 vs. P40 vs. P100 vs. GeForce GTX 1080 Ti
   :file: tesla_p10/tesla_spec.csv
   :widths: 20, 20, 20, 20, 20
   :header-rows: 1

.. note::

   ChartGPT的狂潮愈演愈烈，现在二手GPU卡的售价不断上升，甚至赶超了当年的挖矿

参考
======

- `Nvidia Tesla P40 vs P100 for Stable Diffusion <https://www.reddit.com/r/StableDiffusion/comments/135ewnq/nvidia_tesla_p40_vs_p100_for_stable_diffusion/?onetap_auto=true>`_
- `Why are the NVIDIA Pascal P4 and P40 better for machine learning inference, and the P100 better for training? <https://www.quora.com/Why-are-the-NVIDIA-Pascal-P4-and-P40-better-for-machine-learning-inference-and-the-P100-better-for-training>`_
- `Why are the NVIDIA Pascal P4 and P40 better for machine learning inference, and the P100 better for training? <https://www.quora.com/Why-are-the-NVIDIA-Pascal-P4-and-P40-better-for-machine-learning-inference-and-the-P100-better-for-training>`_
