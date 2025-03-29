.. _tensorflow_nvidia:

===========================
NVIDIA GPU加速TensorFlow
===========================

.. note::

   尝试使用 :ref:`tesla_p10` 加速TensorFlow，具体待实践

   `NVIDIA Tesla GPU系列P40参数性能——不支持半精度(FP16)模型训练 <https://blog.csdn.net/pearl8899/article/details/112875396>`_

NVIDIA开发的 `apex <https://github.com/nvidia/apex>`_ PyTorch扩展，可以在Pytorch中进行 :ref:`mixed_precision_training` 和分布式训练 (distributed training) : `Introducing Apex: PyTorch Extension with Tools to Realize the Power of Tensor Cores <https://developer.nvidia.com/blog/introducing-apex-pytorch-extension-with-tools-to-realize-the-power-of-tensor-cores/>`_

参考
=======

- `TensorRT Integration Speeds Up TensorFlow Inference <https://developer.nvidia.com/blog/tensorrt-integration-speeds-tensorflow-inference/>`_
