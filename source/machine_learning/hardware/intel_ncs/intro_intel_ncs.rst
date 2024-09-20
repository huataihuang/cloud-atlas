.. _intro_intel_ncs:

==========================================
Intel Neural Compute Stick(神经计算棒)简介
==========================================

.. note::

   我在很久很久以前购买过 Intel Movidius Neural Compute Stick 一代，很可惜没有很好使用。我现在准备系统学习和使用这款产品，至少能够帮助自己在 :ref:`machine_learning` 做出一些进步。

Intel 2016年9月收购了Movidius，这家被收购的Movidius公司的产品Neural Compute Stick(ncs神经计算棒)是专注于图像识别的AI计算加速器，一共出过两代产品(2023年6月终止技术支持):

- `Intel Movidius Neural Compute Stick <https://www.intel.com/content/www/us/en/products/sku/125743/intel-movidius-neural-compute-stick/specifications.html>`_ (2017年第三季度发布) :

  - 处理器: `Intel® Movidius™ Myriad™ 2 Vision Processing Unit 4GB <https://www.intel.com/content/www/us/en/products/sku/122461/intel-movidius-myriad-2-vision-processing-unit-4gb/specifications.html>`_ 

    - 光刻(Lithography): 28 nm
    - 处理器主频: 933 MHz
    - 具有12个可编程shave core，可用于视觉神经网络加速
    - 内存: 4GB LP-DDR3 with 32-bit interface at 733MHz

- `Intel Movidius Neural Compute Stick 2 <https://www.intel.com/content/www/us/en/developer/articles/tool/neural-compute-stick.html>`_ ( `NCS2 brief <file:///Users/huatai/Downloads/neural-compute-stick2-product-brief.pdf>`_ )

  - 处理器: Intel Movidius Myriad X Vision Processing Unit (号称比上一代产品快8倍)

    - 光刻(Lithography): 16 nm FinFET工艺
    - 全新深度神经网络(deep neural network, DNN)
    - 通过 Intel Distribution of OpenVINO toolkit支持
    - 16个可编程 128位 流式混合架构矢量引擎(SHAVE) 处理器内核
    - 2.5MB片上内存
    - 两个通用 RISC 内核
    - 包含了新的低功耗视觉加速器:

      - 一个可以处理高达180Hz的双720p立体声模块
      - 一个可调的集成信号处理管道(带有基于硬件的编码，可以在8个传感器上实现高达4k的视频分辨率) (之前的Myriad 2只有6个)

    - 专用硬件加速器，原生 FP16 和 定点8位(fixed-point 8-bit) 支持

  - 支持Intel计算视觉SDK和Movidius计算SDK，以及 OpenVINO (开放视觉推理和神经网络优化: 与 Facebook 的 Caffe2 和 Google 的 TensorFlow 等框架兼容，并带有用于对象检测、面部识别和对象跟踪的预训练 AI 模型)
  - 支持框架: :ref:`tensorflow` , Caffe, MXNet, ONNX, PyTorch, 以及 通过 ONNX 转换的 PaddlePaddle(百度的开源深度学习系统)

Intel NCS 适合运行卷积神经网络(CNN)，是很多图像识别系统的核心支柱，主要用途是用于 **测试** 智能相机、无人机、工业机器人和智能家居设备。

.. note::

   Intel现在(2024年)演进技术是 OpenVINO ，转向了 大语言模型(LLM) 和 生成式AI(genAI) ，具体参考 `OpenVINO 概述 <https://www.intel.cn/content/www/cn/zh/developer/tools/openvino-toolkit/overview.html>`_

参考
========

- `Intel’s Neural Compute Stick 2 is 8 times faster than its predecessor <https://venturebeat.com/business/intels-neural-compute-stick-2-is-8-times-faster-than-its-predecessor/>`_
- 
