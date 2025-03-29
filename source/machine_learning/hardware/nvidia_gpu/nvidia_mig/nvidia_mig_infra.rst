.. _nvidia_mig_infra:

=====================================
NVIDIA Multi-Instance GPU(MIG) 架构
=====================================

NVIDIA多实例GPU(Multi-Instance GPU, MIG)技术扩展了 NVIDIA H100, :ref:`nvidia_a100` 和 A30 Tensore Core GPU的性能和价值:

- MIG可以将 ``单个GPU`` 划分为多达 ``7个实例``

  - 每个实例完全隔离: 具有独立的高带宽内存、缓存和计算核心
  - 支持从最小到最大的每个工作负载
  - 确保服务质量保证(guaranteed quality of service (QoS))为独立每个用户提供计算加速

- 优化GPU使用率

  - MIG提供了不同实例大小的灵活性: 可以为每个工作负载配置合适大小的GPU实例，最终优化利用率并最大化数据中心投资

- 运行并发工作负载

  - MIG 使 **推理、训练和高性能计算(HPC)** 工作负载能够在具有确定性延迟和吞吐量的 ``单个GPU`` 上 **同时运行**

NVIDIA MIG技术和 :ref:`vgpu` 辨析
==================================



参考
======

- `NVIDIA Multi-Instance GPU <https://www.nvidia.com/en-us/technologies/multi-instance-gpu/>`_
- `NVIDIA Multi-Instance GPU and NVIDIA Virtual Compute Server (GPU Partitioning) Technical Brief <https://www.nvidia.com/content/dam/en-zz/Solutions/design-visualization/solutions/resources/documents1/Technical-Brief-Multi-Instance-GPU-NVIDIA-Virtual-Compute-Server.pdf>`_
- `MIG or vGPU Mode for NVIDIA Ampere GPU: Which One Should I Use? (Part 1 of 3) <https://blogs.vmware.com/performance/2021/09/mig-or-vgpu-part1.html>`_
- `Extreme Performance Series 2022: Time Sliced vGPU vs MIG vGPU for Machine Learning Workloads <https://www.youtube.com/watch?v=GL9fghrSwMk>`_ VMware公司在发vSPhere上使用NVIDIA vGPU的方案介绍，对比了 time sliced vGPU 和 Multi Instance vGPU 。在视频的说明中还提供了一些延伸阅读资料
- `NVIDIA Multi-Instance GPU User Guide <https://docs.nvidia.com/datacenter/tesla/mig-user-guide/#partitioning>`_ NVIDIA官方使用手册，介绍了从ampere架构开始引入的Multi-Instance GPU功能
