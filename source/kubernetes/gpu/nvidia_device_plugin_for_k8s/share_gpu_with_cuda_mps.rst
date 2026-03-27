.. _share_gpu_with_cuda_mps:

=================================
通过CUDA MPS共享GPU
=================================

Time-Slicing vs. MPS
======================

虽然NVIDIA的显卡虚拟化不仅提供了 :ref:`vgpu` (需要Licence) 和 :ref:`nvidia_mig` (需要高端硬件如 ``NVIDIA Tesla A100`` )，而且也提供了低端硬件也能够使用的 Time-Slicing 和 MPS技术。

不过，Time-Slicing 和 MPS的技术细节完全不同，对构建 :ref:`kind` 模拟多GPU集群有不同影响:

.. csv-table:: Time-Slicing vs. MPS
   :file: share_gpu_with_cuda_mps/time-slicing_vs_mps.csv
   :widths: 20,40,40
   :header-rows: 1

我规划采用 :ref:`vllm` 来构建一个基于 :ref:`kind` 模拟集群，来实践分布式推理的架构

参考
=========

- `NVIDIA device plugin for Kubernetes > Shared Access to GPUs > With CUDA MPS <https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file#with-cuda-mps>`_
