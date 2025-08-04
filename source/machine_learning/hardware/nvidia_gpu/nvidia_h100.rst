.. _nvidia_h100:

====================
NVIDIA H100
====================

``NVIDIA H100 Tensor Core GPU`` 基于Hopper架构，是第九代数据中心GPU:

- 基于5nm工艺
- GH100图形处理器
- Hopper架构
- 800亿晶体管
- 两种接口形式

  - PCIe Gen5: 连接高性能x86 CPUs以及SmartNICs/DPUs(Data Processing Units)

    - NVIDIA BlueField-3 DPUs for 400 Gb/s Ethernet
    - NDR (Next Data Rate) 400 Gb/s InfiniBand networking acceleration

  - SXM5

- 内存带宽: 2 TB/s
- 支持 :ref:`sr-iov`

  - 单PCIe连接的GPU虚拟化成多个处理器或虚拟机
  - 从一个SR-IOV PCIe连接的GPU虚拟出的VF/PF 能够直接通过NVLink访问对端GPU

- Transformer引擎

  - 软件和定制的 NVIDIA Hopper Tensor Core 技术，加速基于 Transformer 构建的模型的训练
  - 动态精度: 定制的、NVIDIA 调校的启发式算法可以实现 FP8 和 FP16 之间动态选择，并自动处理每层中这些精度之间的re-casting 和 scaling
  - 针对PyTorch 代码无缝集成的自动化混合精度 API
  - 与框架无关的 C++ API 为 Transformer 提供 FP8 支持

- :ref:`nvidia_mig` 技术

  - 适应不需要完整 GPU 的工作负载(有利于土里负载)
  - 第二代 MIG 分区技术: 每个 GPU 实例的计算能力提升了约 3 倍，内存带宽提升了近 2 倍
  - 支持动态更改 MIG 配置文件，无需重置 GPU

- :ref:`nvidia_mig` 级可行执行环境(Trusted Execution Environments, TEE)机密计算

  - 最多支持七个独立的 GPU 实例，每个实例都配备专用的 NVDEC 和 NVJPG 单元
  - 每个实例包含一组独立的性能监视器，可与 NVIDIA 开发者工具配合使用
  - CPU 和 GPU 之间进行加密传输
  - GPU 硬件虚拟化通过 PCIe SR-IOV 实现: 每个 MIG 实例对应一个 **Virtual Function** ( ``VF`` )
  - 基于硬件的安全功能确保机密性和数据完整性
  - 硬件防火墙在 GPU 实例之间提供内存隔离

.. figure:: ../../../_static/machine_learning/hardware/nvidia_gpu/nvidia_mig/mig_sr-iov.png

   MIG结合sr-iov实现虚拟机的vGPU隔离

.. note::

   MIG提供了硬件级别的隔离，能够加强虚拟化的数据安全性

参考
=======

- `NVIDIA H100 Tensor Core GPU Product <https://www.nvidia.com/en-us/data-center/h100/>`_
- `NVIDIA H100 NVL GPU Product Brief <https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/h100/PB-11773-001_v01.pdf>`_
- `NVIDIA H100 Tensor Core GPU Datasheet <https://resources.nvidia.com/en-us-hopper-architecture/nvidia-tensor-core-gpu-datasheet?ncid=no-ncid>`_
- `NVIDIA H100 GPU Whitepaper <https://resources.nvidia.com/en-us-hopper-architecture/nvidia-h100-tensor-c?ncid=no-ncid>`_
- `techpowerup: GPU Database>H100 PCIe 80 GB Specs <https://www.techpowerup.com/gpu-specs/h100-pcie-80-gb.c3899>`_
