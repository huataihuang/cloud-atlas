.. _tesla_p100:

===============================
Nvidia Tesla P100 GPU运算卡
===============================

P40 vs. P100
=================

P40( :ref:`tesla_p10` ) 和 P100 都采用了相同的 Pascal微架构，同属Telsa数据中心运算卡系列，然而这两块卡定位上是不同的:

- P40具有更多CUDA core以及更快的时钟速度，但是P100的高速内存带宽远超P40(P100的732GB/s vs P40的480GB/s)
- P100适合训练(制作 LoRA/嵌入/微调模型等) 而 P40适合推理(生成图像)
- P100提供了FP16以及更快的内存带宽(适合训练)，相反P40则具备更快的int8能力(适合推理) 
- 两者上市时起始售价相同($5699)，但是目前在二手市场上P100(1450元)略胜P40(1300元)一筹

参考
======

- `Nvidia Tesla P40 vs P100 for Stable Diffusion <https://www.reddit.com/r/StableDiffusion/comments/135ewnq/nvidia_tesla_p40_vs_p100_for_stable_diffusion/?onetap_auto=true>`_
- `Why are the NVIDIA Pascal P4 and P40 better for machine learning inference, and the P100 better for training? <https://www.quora.com/Why-are-the-NVIDIA-Pascal-P4-and-P40-better-for-machine-learning-inference-and-the-P100-better-for-training>`_
