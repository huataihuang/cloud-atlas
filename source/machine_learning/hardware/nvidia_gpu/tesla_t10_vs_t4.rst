.. _tesla_t10_vs_t4:

=================================
Nvidia Tesla T10 vs T4 GPU运算卡
=================================

.. _tesla_t10:

Tesla T10
============

Tesla T10 16GB是NVIDIA于2020年推出的专业图形卡，采用12nmg工艺制造，基于TU102图形处理器，其 TU102-890-KCD-A1 版本支持 DirectX 12 Ultimate。

TU102图形处理器芯片面积为 754 mm²，包含18600 million(186亿)晶体管。

与完全解锁的TITAN RTX(使用相同的GPU，但启用了所有4608个着色器(shader)，NVIDIA禁用了Tesla T10 16GB上的某些着色单元，以达到产品的目标着色器数量:

- 3072个着色单元(shading units)
- 192个纹理单元(texture mapping units)
- 92个ROP
- 384个tensor cores(机器学习加速)
- 48个光线追踪加速核心(raytracing acceleration cores)
- 16 GB GDDR6 内存，使用 256 位内存接口连接
- GPU工作频率为 1065 MHz, 可提升(bootst up)到 1395MHz
- 内存运行频率 1575MHz(12.6 Gbps有效)
- 使用1x8针电源获取电力，最大额定功耗为 150w
- PCI-Express 3.0 x16
- 尺寸: 267mm长， 111mm宽，单插槽被动冷却

实际使用
----------

2025年春节入手了 Tesla T10，采用以下方案实践:

- :ref:`blfs_qemu` 运行 :ref:`ovmf_tesla_t10`
- :ref:`qemu_docker_tesla_t10` 在QEMU虚拟机中运行docker容器化使用Tesla T10，分别安装 ``CUDA driver`` 和 ``CUDA``
- :ref:`vgpu` 方式将 :ref:`tesla_p10` 和 :ref:`tesla_t10` 划分为多块vGPU，分别提供给不同虚拟机
- 构建 :ref:`kubernetes` 集群，实现规模化部署以及监控维护

Tesla T4
===========

Tesla T4 16GB是NVIDIA于2018年9月13日发布的专业图形卡，采用12nm工艺制造，基于TU104图形处理器，其TU104-895-A1 版本支持DirectX 12 Ultimate。

TU04图形处理器芯片面积 545 mm²，包含13600 million(136亿)晶体管。

与完全解锁的 GeForce RTX 2080 SUPER 不同(使用相同的 GPU，但启用了所有 3072 个着色器)，NVIDIA 已禁用 Tesla T4 上的一些着色单元，以达到产品的目标着色器数量:

- 2560个着色单元(shading units)
- 160个纹理单元(texture mapping units)
- 64个ROP
- 320个tensore cores(机器学习加速)
- 40个光线追踪加速核心(raytracing acceleration cores)
- 16GB GDDR6 内存，使用 256 位内存接口连接
- GPU工作皮女了为 585 MHz, 可提升(bootst up)到 1590MHz
- 内存运行频率 1250MHz(10 Gbps有效)
- 无需额外电源连接，最大额定功耗为 70W
- PCI-Express 3.0 x16
- 尺寸: 168mm长，单插槽被动冷却

对比
=======

- Tesla T10 可以看成 T4 在 2020年 的重制版本，但是增加了芯片面积(晶体管):

  - 增加晶体管 +36.8%
  - 增加着色单元 +20%
  - 增加ROP +43.8%
  - 增加tensor cores +20%
  - 增加管线追踪加速核心 +20%

- 带来的不利点(也可以忽略): ``功耗翻倍``

  - GPU工作频率 +82.1%
  - 内存频率 +26%

- 由于 T10 和 T4 的 ``GPU核心架构`` 都是 Turing ， ``GPU处理器`` 都是 Volta，所以两者其实是同一代产品:

  - 具备Tensor Cores (第一代)
  - 从NVIDIA 510.39 驱动开始，NVIDIA激活了基于Ampere和Turing架构的Tesla数据中心GPU卡的GSP功能: GSP功能可以将传统由CPU执行的GPU初始化和管理功能offload到GPU上处理(默认启用，由 ``/lib/firmware/nvidia/510.39.01/gsp.bin`` firmware驱动)，提升了GPU性能(降低了GPU硬件访问延迟)

- 差别在于:

  - T4更为节能(低功耗)，适合特定的运行场合进行训练推理
  - T4则功率全开且机器学习能力提升 +20%
  - 二手市场T4的售价大约是T10的2.5倍

    - T10 和 :ref:`tesla_p10` 类似，网上资料极少，似乎是数据中心大批量采购用于 :ref:`cloud_gaming`
    - Google云计算使用了 L4, T4 和 P4 作为云桌面(NVIDIA RTX Virtual Workstation, vWS)，可能更看中GPU节能

技术规格
==========

.. csv-table:: Tesla T10 vs. T4 vs. P100 vs. P10
   :file: tesla_t10_vs_t4/tesla_spec.csv
   :widths: 20, 20, 20, 20, 20
   :header-rows: 1

参考
======

- `techpowerup GPU Database - NVIDIA Tesla T10 16 GB <https://www.techpowerup.com/gpu-specs/tesla-t10-16-gb.c4036>`_
- `techpowerup GPU Database - NVIDIA Tesla T4 16 GB <https://www.techpowerup.com/gpu-specs/tesla-t4.c3316>`_
- `reddit: Why T4's price is similar to 4070? <https://www.reddit.com/r/nvidia/comments/17l27n3/why_t4s_price_is_similar_to_4070/>`_
- `reddit: Tesla T10 Server GPU <https://www.reddit.com/r/homelab/comments/180ox3v/tesla_t10_server_gpu/>`_
- `NVIDIA enables GPU System Processor (GSP) on select Tesla/Data Center accelerators <https://videocardz.com/newz/nvidia-enables-gpu-system-processor-gsp-on-select-tesla-data-center-accelerators>`_ 提到了Tesla T10使用了GPU System Processor可以写在GPU初始化和管理任务(将传统的CPU执行任务卸载到GPU上提升性能和降低延迟)
- `NVIDIA官网: Tesla T4 <https://www.nvidia.com/en-us/data-center/tesla-t4/>`_ 提供 T4 信息
