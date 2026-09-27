.. _tesla_a2:

=============================
NVIDIA Tesla A2 GPU运算卡
=============================

NVIDIA A2 Tensor Core GPU是NVIDIA 2021年11月10日推出的低功耗边缘计算推理设备。

A2参数:

- GPU架构: NVIDIA Ampere
- 核心代号: GA107
- 核心频率: 基础频率 1440 MHz, Boost频率最高 1770 MHz
- CUDA核心数: 1280
- Tensor核心数: 40个(第三代Tensor Core)，支持TF32, BFLOAT16, INT8 和 INT4精度加速
- RT核心数: 10个(第二代RT Core)，用于加速光线追踪任务
- 制造工艺: 三星8nm
- 显存容量: 16GB GDDR6，支持ECC
- 显存带宽: 200GB/s
- 系统接口: :ref:`pcie` Gen4 x8
- 媒体引擎: 1个硬件视频编码器(NVENC)和2个硬件视频解码器(NVDEC,包含AV1解码支持)

A2的特点是:

- 低功耗: 功耗只有40-60W(TDP)
- 小尺寸: 半高无风扇(安装在机架服务器,被动散热)，支持大规模部署
- 高性能: 入门级推理，适合边缘部署(空间和散热受限的边缘服务器和工业环境)
- 全栈软件支持: 支持NVIDIA AI Enterprise 软件套件及多种虚拟化软件(如 vPC, vWS, vCS)

结构化稀疏（Structural Sparsity）技术
=======================================

:ref:`tesla_a2_structural_sparsity` 开启后算力通常可翻倍:

.. csv-table:: NVIDIA A2峰值计算性能
   :file: tesla_a2/structural_sparsity.csv
   :widths: 30,35,35
   :header-rows: 1


参考
=====

- `NVIDIA A2 Tensor Core GPU <https://www.nvidia.com/en-us/data-center/products/a2/>`_
- `NVIDIA A2 datasheet <https://www.nvidia.com/content/dam/en-zz/solutions/data-center/a2/pdf/a2-datasheet.pdf>`_
- `NVIDIA A2 product brief <https://www.nvidia.com/content/dam/en-zz/solutions/data-center/a2/pdf/a2-product-brief.pdf>`_
- `NVIDIA A2 PCIe <https://www.techpowerup.com/gpu-specs/a2-pcie.c4112>`_
- gemini
